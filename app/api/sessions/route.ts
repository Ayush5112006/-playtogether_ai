import { NextRequest, NextResponse } from 'next/server';
import { CreateSessionSchema } from '@/lib/security/validation';
import { checkRateLimit } from '@/lib/security/rate-limit';
import { validateMutationOrigin } from '@/lib/security/csrf';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';

export const dynamic = 'force-dynamic';

export async function POST(req: NextRequest) {
  // CSRF verification
  const originCheck = validateMutationOrigin(req);
  if (!originCheck.valid) {
    return NextResponse.json({ error: originCheck.reason }, { status: 403 });
  }

  // Rate Limiting
  const ip = req.headers.get('x-forwarded-for') || '127.0.0.1';
  const rateLimit = checkRateLimit(ip, 'session:create', 20, 60);
  if (!rateLimit.allowed) {
    return NextResponse.json(
      { error: 'Too many session creation requests. Please wait a moment.' },
      { status: 429 }
    );
  }

  try {
    const body = await req.json();
    const parseResult = CreateSessionSchema.safeParse(body);

    if (!parseResult.success) {
      return NextResponse.json(
        { error: 'Invalid session payload', details: parseResult.error.format() },
        { status: 400 }
      );
    }

    const { players, difficulty, settings } = parseResult.data;
    const sessionId = parseResult.data.sessionId || `session_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;

    const adminClient = getAdminSupabaseClient();
    if (adminClient) {
      try {
        // Try atomic RPC function first
        const rpcPlayersPayload = players.map((p) => ({
          playerId: p.id,
          name: p.name,
          avatarName: p.avatarName || p.name,
          roleTag: p.roleTag || 'Player',
        }));

        const { error: rpcError } = await adminClient.rpc('create_session_with_players', {
          p_session_id: sessionId,
          p_settings: settings || {},
          p_initial_difficulty: difficulty === 'ADAPTIVE' ? 'MEDIUM' : difficulty,
          p_players: rpcPlayersPayload,
        });

        if (rpcError) {
          // Fallback: Direct insert if RPC not installed
          const { error: sError } = await adminClient.from('sessions').insert({
            id: sessionId,
            status: 'active',
            current_difficulty: difficulty === 'ADAPTIVE' ? 'MEDIUM' : difficulty,
            settings: settings || {},
            current_round: 1,
          });

          if (!sError) {
            const playerRows = players.map((p) => ({
              session_id: sessionId,
              player_id: p.id,
              name: p.name,
              avatar_name: p.avatarName || p.name,
              role_tag: p.roleTag || 'Player',
              score: p.score || 0,
              streak: p.streak || 0,
              best_streak: p.bestStreak || 0,
              correct_count: p.correctCount || 0,
              total_answered: p.totalAnswered || 0,
            }));
            await adminClient.from('session_players').insert(playerRows);
          }
        }
      } catch (dbErr) {
        console.warn('Supabase session persistence fallback:', dbErr);
      }
    }

    return NextResponse.json({
      success: true,
      sessionId,
      difficulty,
      playerCount: players.length,
      session: {
        id: sessionId,
        joinCode: 'PLAY-26',
        mode: difficulty === 'EASY' ? 'trivia' : 'family-adaptive',
        status: 'in_progress',
        currentRound: 1,
        totalRounds: settings?.questionCount || 5,
        currentQuestionIndex: 0,
        currentDifficulty: 2,
        players: players.map((p) => ({
          id: p.id,
          name: p.name,
          avatar: p.avatarName || '👨‍💼',
          color: p.accentColor || '#3b82f6',
          score: 0,
          streak: 0,
        })),
        adaptivePacing: 'normal',
        createdAt: new Date().toISOString(),
      },
    });
  } catch (err: any) {
    return NextResponse.json({ error: 'Internal server error', message: err.message }, { status: 500 });
  }

}
