// =============================================================================
// PlayTogether AI — Supabase Database Service
// Centralizes all Supabase database access operations.
// Uses the singleton client from config/supabase.ts.
// =============================================================================

import { getSupabaseClient } from '../config/supabase';
import {
  QuestionRow,
  Question,
  QuestionOption,
  SessionRow,
  SessionPlayerRow,
  PlayerAnswerRow,
  GameRecapRow,
  Difficulty,
} from '../types';

// -----------------------------------------------------------------------------
// Row-to-API Transformers (snake_case DB → camelCase API response)
// -----------------------------------------------------------------------------

/**
 * Converts a Supabase `questions` row into the camelCase API Question object.
 * By default, masks `correctOptionId` before answer submission to prevent client cheating.
 */
export function questionRowToApi(row: QuestionRow, exposeCorrectAnswer = false): Question {
  return {
    id: row.id,
    category: row.category,
    categoryEmoji: row.category_emoji,
    difficulty: row.difficulty,
    question: row.question,
    quoteHighlight: row.quote_highlight,
    options: row.options as QuestionOption[],
    // If not exposing, leave empty to preserve security over the network
    correctOptionId: exposeCorrectAnswer ? row.correct_option_id : '',
    explanation: row.explanation,
    pointValue: row.point_value,
  };
}

// -----------------------------------------------------------------------------
// Questions
// -----------------------------------------------------------------------------

/**
 * Fetch questions from the database, filtered by difficulty and/or category.
 * Supports excluding question IDs already answered in the current session.
 */
export async function fetchQuestions(params: {
  difficulty?: string;
  category?: string;
  excludeIds?: string[];
  limit?: number;
}): Promise<QuestionRow[]> {
  const client = getSupabaseClient();
  if (!client) return [];

  let query = client
    .from('questions')
    .select('*')
    .eq('is_active', true);

  if (params.difficulty && ['EASY', 'MEDIUM', 'HARD'].includes(params.difficulty)) {
    query = query.eq('difficulty', params.difficulty);
  }
  if (params.category) {
    query = query.eq('category', params.category);
  }
  if (params.excludeIds && params.excludeIds.length > 0) {
    query = query.not('id', 'in', `(${params.excludeIds.join(',')})`);
  }

  query = query.limit(params.limit || 10);

  const { data, error } = await query;
  if (error || !data) return [];

  return data as QuestionRow[];
}

/**
 * Fetch a single question by its ID directly from database.
 */
export async function fetchQuestionById(questionId: string): Promise<QuestionRow | null> {
  const client = getSupabaseClient();
  if (!client) return null;

  const { data, error } = await client
    .from('questions')
    .select('*')
    .eq('id', questionId)
    .single();

  if (error || !data) return null;
  return data as QuestionRow;
}

// -----------------------------------------------------------------------------
// Sessions
// -----------------------------------------------------------------------------

/**
 * Fetch a session by its ID.
 */
export async function fetchSession(sessionId: string): Promise<SessionRow | null> {
  const client = getSupabaseClient();
  if (!client) return null;

  const { data, error } = await client
    .from('sessions')
    .select('*')
    .eq('id', sessionId)
    .single();

  if (error || !data) return null;
  return data as SessionRow;
}

/**
 * Deletes a session (used for rollback if player creation fails).
 */
export async function deleteSession(sessionId: string): Promise<boolean> {
  const client = getSupabaseClient();
  if (!client) return false;

  const { error } = await client.from('sessions').delete().eq('id', sessionId);
  return !error;
}

/**
 * Create a session with players atomically.
 * Tries the PostgreSQL RPC function first. If not installed, performs
 * safe insert with rollback on failure so no partial session remains.
 */
export async function createSessionWithPlayers(
  sessionId: string,
  settings: any,
  initialDifficulty: Difficulty,
  players: Array<{ playerId: string; name: string; avatarName?: string }>
): Promise<{ success: boolean; error?: string }> {
  const client = getSupabaseClient();
  if (!client) return { success: false, error: 'Supabase client not available' };

  // 1. Try atomic RPC function
  const { data: rpcData, error: rpcError } = await client.rpc('create_session_with_players', {
    p_session_id: sessionId,
    p_settings: settings || {},
    p_initial_difficulty: initialDifficulty,
    p_players: players,
  });

  if (!rpcError && rpcData?.success) {
    return { success: true };
  }

  // 2. Fallback to client-side insert with rollback on failure
  const { error: sessionError } = await client.from('sessions').insert({
    id: sessionId,
    status: 'active',
    current_difficulty: initialDifficulty,
    settings: settings || {},
    current_round: 1,
  });

  if (sessionError) {
    return { success: false, error: sessionError.message };
  }

  // Insert players
  const playerRows = players.map((p) => ({
    session_id: sessionId,
    player_id: p.playerId,
    name: p.name,
    avatar_name: p.avatarName || p.name,
    role_tag: 'Player',
    score: 0,
    streak: 0,
    best_streak: 0,
    correct_count: 0,
    total_answered: 0,
  }));

  const { error: playersError } = await client.from('session_players').insert(playerRows);

  if (playersError) {
    // Rollback session creation so partial session is never left behind
    await deleteSession(sessionId);
    return { success: false, error: `Failed to insert players: ${playersError.message}` };
  }

  return { success: true };
}

/**
 * Update session difficulty.
 */
export async function updateSessionDifficulty(
  sessionId: string,
  difficulty: Difficulty
): Promise<boolean> {
  const client = getSupabaseClient();
  if (!client) return false;

  const { error } = await client
    .from('sessions')
    .update({ current_difficulty: difficulty })
    .eq('id', sessionId);

  return !error;
}

/**
 * Update session settings JSONB (e.g. for surprise round tracking).
 */
export async function updateSessionSettings(
  sessionId: string,
  settings: any
): Promise<boolean> {
  const client = getSupabaseClient();
  if (!client) return false;

  const { error } = await client
    .from('sessions')
    .update({ settings })
    .eq('id', sessionId);

  return !error;
}

// -----------------------------------------------------------------------------
// Session Players
// -----------------------------------------------------------------------------

/**
 * Get all players in a session ordered by score descending.
 */
export async function getSessionPlayers(sessionId: string): Promise<SessionPlayerRow[]> {
  const client = getSupabaseClient();
  if (!client) return [];

  const { data, error } = await client
    .from('session_players')
    .select('*')
    .eq('session_id', sessionId)
    .order('score', { ascending: false });

  if (error || !data) return [];
  return data as SessionPlayerRow[];
}

/**
 * Fetch a single player in a session.
 */
export async function getSessionPlayer(
  sessionId: string,
  playerId: string
): Promise<SessionPlayerRow | null> {
  const client = getSupabaseClient();
  if (!client) return null;

  const { data, error } = await client
    .from('session_players')
    .select('*')
    .eq('session_id', sessionId)
    .eq('player_id', playerId)
    .single();

  if (error || !data) return null;
  return data as SessionPlayerRow;
}

// -----------------------------------------------------------------------------
// Player Answers
// -----------------------------------------------------------------------------

/**
 * Checks if a player has already submitted an answer for a specific question in this session.
 */
export async function checkAnswerAlreadySubmitted(
  sessionId: string,
  playerId: string,
  questionId: string
): Promise<boolean> {
  const client = getSupabaseClient();
  if (!client) return false;

  const { data, error } = await client
    .from('player_answers')
    .select('id')
    .eq('session_id', sessionId)
    .eq('player_id', playerId)
    .eq('question_id', questionId)
    .limit(1);

  if (error || !data) return false;
  return data.length > 0;
}

/**
 * Submits an answer atomically, updating score and streak.
 * Tries RPC function `submit_player_answer` first, falls back to safe client sequence.
 */
export async function submitPlayerAnswerAtomic(params: {
  sessionId: string;
  playerId: string;
  questionId: string;
  selectedOptionId: string;
  isCorrect: boolean;
  pointsEarned: number;
  responseTimeSeconds: number;
  currentStreak: number;
  currentBestStreak: number;
  currentScore: number;
  currentCorrectCount: number;
  currentTotalAnswered: number;
}): Promise<{ success: boolean; error?: string; isDuplicate?: boolean }> {
  const client = getSupabaseClient();
  if (!client) return { success: false, error: 'Database unavailable' };

  // 1. Try atomic RPC
  const { data: rpcData, error: rpcError } = await client.rpc('submit_player_answer', {
    p_session_id: params.sessionId,
    p_player_id: params.playerId,
    p_question_id: params.questionId,
    p_selected_option_id: params.selectedOptionId,
    p_is_correct: params.isCorrect,
    p_points_earned: params.pointsEarned,
    p_response_time_seconds: params.responseTimeSeconds,
  });

  if (!rpcError && rpcData) {
    if (rpcData.error === 'DuplicateSubmission') {
      return { success: false, isDuplicate: true, error: rpcData.message };
    }
    if (rpcData.success) {
      return { success: true };
    }
  }

  // 2. Client-side safe execution: check duplicate first
  const isDuplicate = await checkAnswerAlreadySubmitted(
    params.sessionId,
    params.playerId,
    params.questionId
  );
  if (isDuplicate) {
    return { success: false, isDuplicate: true, error: 'Answer already submitted.' };
  }

  // Record answer in player_answers
  const { error: insertErr } = await client.from('player_answers').insert({
    session_id: params.sessionId,
    player_id: params.playerId,
    question_id: params.questionId,
    selected_option_id: params.selectedOptionId,
    is_correct: params.isCorrect,
    points_earned: params.pointsEarned,
    response_time_seconds: params.responseTimeSeconds,
  });

  if (insertErr) {
    return { success: false, error: insertErr.message };
  }

  // Update session_players stats
  const newStreak = params.isCorrect ? params.currentStreak + 1 : 0;
  const newBestStreak = Math.max(params.currentBestStreak, newStreak);

  const { error: updateErr } = await client
    .from('session_players')
    .update({
      score: params.currentScore + params.pointsEarned,
      streak: newStreak,
      best_streak: newBestStreak,
      correct_count: params.currentCorrectCount + (params.isCorrect ? 1 : 0),
      total_answered: params.currentTotalAnswered + 1,
    })
    .eq('session_id', params.sessionId)
    .eq('player_id', params.playerId);

  if (updateErr) {
    return { success: false, error: updateErr.message };
  }

  return { success: true };
}

/**
 * Get IDs of all questions answered so far in a session.
 */
export async function getAnsweredQuestionIds(sessionId: string): Promise<string[]> {
  const client = getSupabaseClient();
  if (!client) return [];

  const { data, error } = await client
    .from('player_answers')
    .select('question_id')
    .eq('session_id', sessionId);

  if (error || !data) return [];
  return [...new Set((data as Array<{ question_id: string }>).map((r) => r.question_id))];
}

/**
 * Fetch recent answers for a session (ordered by created_at DESC).
 */
export async function getRecentSessionAnswers(
  sessionId: string,
  limit = 5
): Promise<PlayerAnswerRow[]> {
  const client = getSupabaseClient();
  if (!client) return [];

  const { data, error } = await client
    .from('player_answers')
    .select('*')
    .eq('session_id', sessionId)
    .order('created_at', { ascending: false })
    .limit(limit);

  if (error || !data) return [];
  return data as PlayerAnswerRow[];
}

/**
 * Fetch all answers for a session (used for recap calculation).
 */
export async function getAllSessionAnswers(sessionId: string): Promise<PlayerAnswerRow[]> {
  const client = getSupabaseClient();
  if (!client) return [];

  const { data, error } = await client
    .from('player_answers')
    .select('*')
    .eq('session_id', sessionId)
    .order('created_at', { ascending: true });

  if (error || !data) return [];
  return data as PlayerAnswerRow[];
}

// -----------------------------------------------------------------------------
// Game Recaps
// -----------------------------------------------------------------------------

/**
 * Save or update game recap in `game_recaps` table.
 */
export async function saveGameRecap(recap: {
  sessionId: string;
  hostInsight: string;
  familySynergyPercent: string;
  avgSpeedSec: string;
  nextGameRecommendation: string;
  standings?: any[];
}): Promise<GameRecapRow | null> {
  const client = getSupabaseClient();
  if (!client) return null;

  const { data, error } = await client
    .from('game_recaps')
    .upsert(
      {
        session_id: recap.sessionId,
        host_insight: recap.hostInsight,
        family_synergy_percent: recap.familySynergyPercent,
        avg_speed_sec: recap.avgSpeedSec,
        next_game_recommendation: recap.nextGameRecommendation,
        standings: recap.standings || [],
      },
      { onConflict: 'session_id' }
    )
    .select()
    .single();

  if (error || !data) return null;
  return data as GameRecapRow;
}

/**
 * Fetch recap for a session.
 */
export async function fetchGameRecap(sessionId: string): Promise<GameRecapRow | null> {
  const client = getSupabaseClient();
  if (!client) return null;

  const { data, error } = await client
    .from('game_recaps')
    .select('*')
    .eq('session_id', sessionId)
    .single();

  if (error || !data) return null;
  return data as GameRecapRow;
}
