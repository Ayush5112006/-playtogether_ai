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
 * Converts a Supabase `questions` row into the camelCase API Question object
 * expected by Flutter's Question.fromJson.
 */
export function questionRowToApi(row: QuestionRow): Question {
  return {
    id: row.id,
    category: row.category,
    categoryEmoji: row.category_emoji,
    difficulty: row.difficulty,
    question: row.question,
    quoteHighlight: row.quote_highlight,
    options: row.options as QuestionOption[],
    correctOptionId: row.correct_option_id,
    explanation: row.explanation,
    pointValue: row.point_value,
  };
}

// -----------------------------------------------------------------------------
// Questions
// -----------------------------------------------------------------------------

/**
 * Fetch questions from the database, filtered by difficulty and/or category.
 * Excludes questions already answered in this session.
 */
export async function fetchQuestions(params: {
  difficulty?: string;
  category?: string;
  excludeIds?: string[];
  limit?: number;
}): Promise<Question[]> {
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

  return (data as QuestionRow[]).map(questionRowToApi);
}

/**
 * Fetch a single question by its ID.
 */
export async function fetchQuestionById(questionId: string): Promise<Question | null> {
  const client = getSupabaseClient();
  if (!client) return null;

  const { data, error } = await client
    .from('questions')
    .select('*')
    .eq('id', questionId)
    .single();

  if (error || !data) return null;
  return questionRowToApi(data as QuestionRow);
}

// -----------------------------------------------------------------------------
// Sessions
// -----------------------------------------------------------------------------

/**
 * Create a new session in the database.
 */
export async function createSession(session: {
  id: string;
  settings: any;
  currentDifficulty?: string;
}): Promise<SessionRow | null> {
  const client = getSupabaseClient();
  if (!client) return null;

  const { data, error } = await client
    .from('sessions')
    .insert({
      id: session.id,
      status: 'active',
      current_difficulty: session.currentDifficulty || 'MEDIUM',
      settings: session.settings || {},
      current_round: 1,
    })
    .select()
    .single();

  if (error || !data) return null;
  return data as SessionRow;
}

/**
 * Fetch a session by ID.
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

// -----------------------------------------------------------------------------
// Session Players
// -----------------------------------------------------------------------------

/**
 * Add players to a session.
 */
export async function addPlayersToSession(
  sessionId: string,
  players: Array<{ playerId: string; name: string; avatarName?: string }>
): Promise<SessionPlayerRow[]> {
  const client = getSupabaseClient();
  if (!client) return [];

  const rows = players.map((p) => ({
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

  const { data, error } = await client
    .from('session_players')
    .insert(rows)
    .select();

  if (error || !data) return [];
  return data as SessionPlayerRow[];
}

/**
 * Get all players in a session.
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
 * Update a player's score, streak, and answer counts.
 */
export async function updatePlayerStats(
  sessionId: string,
  playerId: string,
  updates: {
    scoreDelta: number;
    isCorrect: boolean;
  }
): Promise<boolean> {
  const client = getSupabaseClient();
  if (!client) return false;

  // Fetch current player state
  const { data: player, error: fetchErr } = await client
    .from('session_players')
    .select('*')
    .eq('session_id', sessionId)
    .eq('player_id', playerId)
    .single();

  if (fetchErr || !player) return false;

  const newStreak = updates.isCorrect ? (player.streak + 1) : 0;
  const newBestStreak = Math.max(player.best_streak, newStreak);

  const { error } = await client
    .from('session_players')
    .update({
      score: player.score + updates.scoreDelta,
      streak: newStreak,
      best_streak: newBestStreak,
      correct_count: player.correct_count + (updates.isCorrect ? 1 : 0),
      total_answered: player.total_answered + 1,
    })
    .eq('session_id', sessionId)
    .eq('player_id', playerId);

  return !error;
}

// -----------------------------------------------------------------------------
// Player Answers
// -----------------------------------------------------------------------------

/**
 * Record a player's answer in the database.
 */
export async function recordAnswer(answer: {
  sessionId: string;
  playerId: string;
  questionId: string;
  selectedOptionId: string;
  isCorrect: boolean;
  pointsEarned: number;
  responseTimeSeconds?: number;
}): Promise<PlayerAnswerRow | null> {
  const client = getSupabaseClient();
  if (!client) return null;

  const { data, error } = await client
    .from('player_answers')
    .insert({
      session_id: answer.sessionId,
      player_id: answer.playerId,
      question_id: answer.questionId,
      selected_option_id: answer.selectedOptionId,
      is_correct: answer.isCorrect,
      points_earned: answer.pointsEarned,
      response_time_seconds: answer.responseTimeSeconds || 0,
    })
    .select()
    .single();

  if (error || !data) return null;
  return data as PlayerAnswerRow;
}

/**
 * Get IDs of questions already answered in a session.
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

// -----------------------------------------------------------------------------
// Game Recaps
// -----------------------------------------------------------------------------

/**
 * Store a game recap for a session.
 */
export async function createRecap(recap: {
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
    .upsert({
      session_id: recap.sessionId,
      host_insight: recap.hostInsight,
      family_synergy_percent: recap.familySynergyPercent,
      avg_speed_sec: recap.avgSpeedSec,
      next_game_recommendation: recap.nextGameRecommendation,
      standings: recap.standings || [],
    }, { onConflict: 'session_id' })
    .select()
    .single();

  if (error || !data) return null;
  return data as GameRecapRow;
}

/**
 * Fetch an existing recap for a session.
 */
export async function fetchRecap(sessionId: string): Promise<GameRecapRow | null> {
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
