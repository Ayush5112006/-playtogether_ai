import { NextRequest, NextResponse } from 'next/server';
import { SubmitAnswerSchema } from '@/lib/security/validation';
import { checkRateLimit } from '@/lib/security/rate-limit';
import { validateMutationOrigin } from '@/lib/security/csrf';
import { calculateAuthoritativeScore } from '@/lib/game-engine/scoring';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';
import { SEED_QUESTIONS } from '@/lib/game-engine/seed-questions';

export const dynamic = 'force-dynamic';

export async function POST(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  // CSRF validation
  const originCheck = validateMutationOrigin(req);
  if (!originCheck.valid) {
    return NextResponse.json({ error: originCheck.reason }, { status: 403 });
  }

  // Rate Limiting
  const ip = req.headers.get('x-forwarded-for') || '127.0.0.1';
  const rateLimit = checkRateLimit(ip, 'answer:submit', 60, 60);
  if (!rateLimit.allowed) {
    return NextResponse.json(
      { error: 'Rate limit exceeded for answers' },
      { status: 429 }
    );
  }

  const sessionId = params.id;
  const adminClient = getAdminSupabaseClient();
  if (!adminClient) {
    return NextResponse.json({ error: 'Database service unavailable' }, { status: 503 });
  }

  try {
    const body = await req.json();
    const parseResult = SubmitAnswerSchema.safeParse({
      ...body,
      sessionId,
    });

    if (!parseResult.success) {
      return NextResponse.json(
        { error: 'Invalid answer payload', details: parseResult.error.format() },
        { status: 400 }
      );
    }

    const { playerId, questionId, selectedOptionId, responseTimeSeconds } = parseResult.data;

    let session: any = null;
    let existingAnswer: any = null;
    let playerRow: any = null;

    if (adminClient) {
      try {
        const { data: s } = await adminClient
          .from('sessions')
          .select('id, current_difficulty')
          .eq('id', sessionId)
          .single();
        session = s;

        const { data: ea } = await adminClient
          .from('player_answers')
          .select('id')
          .eq('session_id', sessionId)
          .eq('player_id', playerId)
          .eq('question_id', questionId)
          .maybeSingle();
        existingAnswer = ea;

        const { data: pr } = await adminClient
          .from('session_players')
          .select('streak, score, best_streak, correct_count, total_answered')
          .eq('session_id', sessionId)
          .eq('player_id', playerId)
          .single();
        playerRow = pr;
      } catch (dbErr) {
        console.warn('DB session check warning:', dbErr);
      }
    }

    if (existingAnswer) {
      return NextResponse.json(
        { error: 'DuplicateSubmission', message: 'Player has already answered this question in this session.' },
        { status: 409 }
      );
    }

    // 3. Retrieve authoritative question details and real correctOptionId
    let questionRow: any = null;
    if (adminClient) {
      try {
        const { data: dbQ } = await adminClient
          .from('questions')
          .select('*')
          .eq('id', questionId)
          .single();
        if (dbQ) questionRow = dbQ;
      } catch {
        // Fallback to seeds
      }
    }

    if (!questionRow) {
      questionRow = SEED_QUESTIONS.find((q) => q.id === questionId) || SEED_QUESTIONS[0];
    }

    const correctOptionId = questionRow.correct_option_id || questionRow.correctOptionId || 'A';
    const isCorrect = selectedOptionId.toUpperCase() === correctOptionId.toUpperCase();
    const explanation = questionRow.explanation || 'Great effort!';
    const basePoints = questionRow.point_value || questionRow.pointValue || 100;

    const currentStreak = playerRow?.streak || 0;

    // 5. Authoritative server calculation
    const scoreResult = calculateAuthoritativeScore({
      isCorrect,
      basePointValue: basePoints,
      currentStreak,
      responseTimeSeconds,
    });

    const newScore = (playerRow?.score || 0) + scoreResult.pointsEarned;
    const newBestStreak = Math.max(playerRow?.best_streak || 0, scoreResult.newStreak);

    if (adminClient) {
      try {
        await adminClient.from('player_answers').insert({
          session_id: sessionId,
          player_id: playerId,
          question_id: questionId,
          selected_option_id: selectedOptionId,
          is_correct: isCorrect,
          points_earned: scoreResult.pointsEarned,
          response_time_seconds: responseTimeSeconds,
        });

        if (playerRow) {
          await adminClient
            .from('session_players')
            .update({
              score: newScore,
              streak: scoreResult.newStreak,
              best_streak: newBestStreak,
              correct_count: isCorrect ? (playerRow.correct_count || 0) + 1 : (playerRow.correct_count || 0),
              total_answered: (playerRow.total_answered || 0) + 1,
              updated_at: new Date().toISOString(),
            })
            .eq('session_id', sessionId)
            .eq('player_id', playerId);
        }
      } catch (logErr) {
        console.warn('DB answer log warning:', logErr);
      }
    }

    return NextResponse.json({
      success: true,
      correct: isCorrect,
      isCorrect,
      correctOptionId,
      scoreDelta: scoreResult.pointsEarned,
      pointsEarned: scoreResult.pointsEarned,
      streak: scoreResult.newStreak,
      newStreak: scoreResult.newStreak,
      newScore,
      bestStreak: newBestStreak,
      explanation,
      speedBonusApplied: scoreResult.speedBonusApplied,
      streakBonusApplied: scoreResult.streakBonusApplied,
    });
  } catch (err: any) {
    return NextResponse.json({ error: 'Failed to process answer', message: err.message }, { status: 500 });
  }

}
