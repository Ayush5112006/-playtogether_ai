import { NextRequest, NextResponse } from 'next/server';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';

export const dynamic = 'force-dynamic';

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const sessionId = params.id;
  const adminClient = getAdminSupabaseClient();

  if (!adminClient) {
    return NextResponse.json({ error: 'Database service unavailable' }, { status: 503 });
  }

  const { data: session, error: sError } = await adminClient
    .from('sessions')
    .select('*')
    .eq('id', sessionId)
    .single();

  if (sError || !session) {
    return NextResponse.json({ error: 'Session not found' }, { status: 404 });
  }

  const { data: players } = await adminClient
    .from('session_players')
    .select('*')
    .eq('session_id', sessionId)
    .order('score', { ascending: false });

  return NextResponse.json({
    session: {
      id: session.id,
      status: session.status,
      difficulty: session.current_difficulty,
      settings: session.settings,
      round: session.current_round,
      createdAt: session.created_at,
    },
    players: (players || []).map((p) => ({
      id: p.player_id,
      name: p.name,
      avatarName: p.avatar_name,
      roleTag: p.role_tag,
      score: p.score,
      streak: p.streak,
      bestStreak: p.best_streak,
      correctCount: p.correct_count,
      totalAnswered: p.total_answered,
    })),
  });
}
