import { NextRequest, NextResponse } from 'next/server';
import { computeAdaptiveDifficulty } from '@/lib/game-engine/difficulty';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';
import { Difficulty } from '@/lib/types';

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

  // Fetch recent answers in session
  const { data: answers } = await adminClient
    .from('player_answers')
    .select('is_correct')
    .eq('session_id', sessionId);

  let accuracy = 50;
  if (answers && answers.length > 0) {
    const correct = answers.filter((a) => a.is_correct).length;
    accuracy = (correct / answers.length) * 100;
  } else {
    // Check if client provided fallback hint
    try {
      const body = await req.json();
      if (typeof body.recentAccuracy === 'number') accuracy = body.recentAccuracy;
    } catch {}
  }

  const currentDiff = (session.current_difficulty || 'MEDIUM') as Difficulty;
  const adaptiveResult = computeAdaptiveDifficulty(accuracy, currentDiff);

  // Update session in Supabase if changed
  if (adaptiveResult.newDifficulty !== currentDiff) {
    await adminClient
      .from('sessions')
      .update({
        current_difficulty: adaptiveResult.newDifficulty,
        updated_at: new Date().toISOString(),
      })
      .eq('id', sessionId);
  }

  // Audit AI Event
  try {
    await adminClient.from('ai_events').insert({
      session_id: sessionId,
      event_type: 'ADAPTATION',
      message: adaptiveResult.reason,
      old_difficulty: currentDiff,
      new_difficulty: adaptiveResult.newDifficulty,
    });
  } catch {}

  return NextResponse.json({
    success: true,
    previousDifficulty: currentDiff,
    newDifficulty: adaptiveResult.newDifficulty,
    reason: adaptiveResult.reason,
    formula: adaptiveResult.formula,
    calculatedAccuracy: adaptiveResult.calculatedAccuracy,
    underdogBoostActive: adaptiveResult.underdogBoostActive,
  });
}
