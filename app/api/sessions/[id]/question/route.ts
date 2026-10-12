import { NextRequest, NextResponse } from 'next/server';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';
import { SEED_QUESTIONS } from '@/lib/game-engine/seed-questions';

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

  // Verify session exists
  const { data: session } = await adminClient
    .from('sessions')
    .select('id, current_difficulty, settings')
    .eq('id', sessionId)
    .single();

  if (!session) {
    return NextResponse.json({ error: 'Session not found' }, { status: 404 });
  }

  // Parse optional query params / body filters
  let categoryFilter: string | undefined;
  let difficultyFilter: string = session.current_difficulty || 'MEDIUM';

  try {
    const body = await req.json();
    if (body.category) categoryFilter = body.category;
    if (body.difficulty) difficultyFilter = body.difficulty;
  } catch {
    // Body is optional
  }

  // Query answered questions to avoid repeating
  const { data: answeredRows } = await adminClient
    .from('player_answers')
    .select('question_id')
    .eq('session_id', sessionId);

  const answeredIds = new Set((answeredRows || []).map((r) => r.question_id));

  // Query database questions
  let query = adminClient
    .from('questions')
    .select('*')
    .eq('is_active', true);

  if (difficultyFilter && ['EASY', 'MEDIUM', 'HARD'].includes(difficultyFilter)) {
    query = query.eq('difficulty', difficultyFilter);
  }
  if (categoryFilter) {
    query = query.eq('category', categoryFilter);
  }

  const { data: dbQuestions, error: qError } = await query;

  let selectedQuestion = null;

  if (!qError && dbQuestions && dbQuestions.length > 0) {
    // Find first unanswered question
    selectedQuestion = dbQuestions.find((q) => !answeredIds.has(q.id)) || dbQuestions[0];
  }

  // Fallback to seed bank if database returns nothing or is depleted
  if (!selectedQuestion) {
    const filteredSeed = SEED_QUESTIONS.filter((q) => {
      const matchCat = categoryFilter ? q.category === categoryFilter : true;
      const matchDiff = difficultyFilter ? q.difficulty === difficultyFilter : true;
      return matchCat && matchDiff && !answeredIds.has(q.id);
    });

    selectedQuestion = filteredSeed[0] || SEED_QUESTIONS[0];
  }

  // CRITICAL SECURITY REQUIREMENT:
  // Mask correctOptionId before sending over the network!
  // Client only receives id, question, category, options, pointValue.
  return NextResponse.json({
    question: {
      id: selectedQuestion.id,
      category: selectedQuestion.category,
      categoryEmoji: selectedQuestion.category_emoji || '🧠',
      difficulty: selectedQuestion.difficulty,
      question: selectedQuestion.question,
      quoteHighlight: selectedQuestion.quote_highlight || '',
      options: selectedQuestion.options,
      correctOptionId: '', // MASKED FOR SECURITY
      pointValue: selectedQuestion.point_value || 100,
      source: dbQuestions && dbQuestions.length > 0 ? 'DATABASE' : 'FALLBACK',
    },
  });
}
