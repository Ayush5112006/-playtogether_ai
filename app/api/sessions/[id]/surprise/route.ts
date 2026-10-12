import { NextRequest, NextResponse } from 'next/server';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';

export const dynamic = 'force-dynamic';

export async function POST(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const sessionId = params.id;
  const adminClient = getAdminSupabaseClient();

  if (!adminClient) {
    return NextResponse.json({ error: 'Database service unavailable' }, { status: 503 });
  }

  const { data: session } = await adminClient
    .from('sessions')
    .select('id, current_difficulty')
    .eq('id', sessionId)
    .single();

  if (!session) {
    return NextResponse.json({ error: 'Session not found' }, { status: 404 });
  }

  const challenges = [
    {
      id: 'buzzer_blitz',
      title: 'SURPRISE ROUND: BUZZER BLITZ!',
      description: 'First player to buzz in gets exclusive rights to answer! Double Points awarded for speed.',
      stakes: 'STAKES: DOUBLE POINTS',
      bounty: 'BOUNTY: +300 PTS / Q',
      bonusPoints: 300,
      type: 'BUZZER_BLITZ',
    },
    {
      id: 'lightning_sprint',
      title: 'SURPRISE ROUND: LIGHTNING SPRINT!',
      description: 'Rapid 5-second countdown clock per player! Maximum speed bonus awarded for rapid fire recall.',
      stakes: 'STAKES: 5s RAPID CLOCK',
      bounty: 'BOUNTY: +400 PTS / Q',
      bonusPoints: 400,
      type: 'LIGHTNING_SPRINT',
    },
    {
      id: 'family_teamup',
      title: 'SURPRISE ROUND: FAMILY TEAM-UP!',
      description: 'Living room consensus round! Confer with everyone and lock in the collective answer.',
      stakes: 'STAKES: SHARED JACKPOT',
      bounty: 'BOUNTY: +500 PTS POOL',
      bonusPoints: 500,
      type: 'FAMILY_TEAMUP',
    },
  ];

  // Pick challenge based on session ID hash
  const hash = sessionId.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
  const challenge = challenges[hash % challenges.length];

  // Audit AI Event
  try {
    await adminClient.from('ai_events').insert({
      session_id: sessionId,
      event_type: 'SURPRISE_ROUND',
      message: `Launched ${challenge.title} (${challenge.stakes})`,
      old_difficulty: session.current_difficulty,
      new_difficulty: session.current_difficulty,
    });
  } catch {}

  return NextResponse.json({
    success: true,
    challenge,
  });
}
