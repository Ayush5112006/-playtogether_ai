// =============================================================================
// PlayTogether AI — Game Business Logic Service
// Scoring, adaptive difficulty, surprise challenges, and recap generation.
// Actual Supabase-backed implementations will be completed in Phase 4.
// =============================================================================

import { Difficulty, Question, GameRecap } from '../types';

// -----------------------------------------------------------------------------
// Score Calculation
// Mirrors Flutter ScoreCalculator (lib/game/score_calculator.dart)
// -----------------------------------------------------------------------------

const BASE_TRIVIA_POINTS = 100;
const BONUS_ROUND_POINTS = 300;
const STREAK_BONUS_MULTIPLIER = 25;

export function calculateScore(params: {
  isCorrect: boolean;
  baseValue: number;
  streak: number;
  isBonusRound?: boolean;
  remainingSeconds?: number;
}): number {
  if (!params.isCorrect) return 0;

  let points = params.isBonusRound
    ? BONUS_ROUND_POINTS
    : (params.baseValue > 0 ? params.baseValue : BASE_TRIVIA_POINTS);

  // Speed bonus (+50 if answered within 5 seconds → remainingSeconds >= 10)
  if ((params.remainingSeconds ?? 0) >= 10) {
    points += 50;
  }

  // Streak bonus
  if (params.streak > 1) {
    points += params.streak * STREAK_BONUS_MULTIPLIER;
  }

  return points;
}

// -----------------------------------------------------------------------------
// Adaptive Difficulty
// Mirrors Flutter AdaptiveDifficultyEngine (lib/game/adaptive_difficulty.dart)
// -----------------------------------------------------------------------------

export function computeAdaptiveDifficulty(recentAccuracy: number): {
  newDifficulty: Difficulty;
  reason: string;
} {
  if (recentAccuracy >= 80) {
    return {
      newDifficulty: 'HARD',
      reason: "You're on fire! Shifting difficulty up to HARD.",
    };
  } else if (recentAccuracy <= 40) {
    return {
      newDifficulty: 'EASY',
      reason: "Let's build momentum! Shifting difficulty to EASY.",
    };
  }
  return {
    newDifficulty: 'MEDIUM',
    reason: 'Balanced gameplay active.',
  };
}

// -----------------------------------------------------------------------------
// Surprise Round
// Generates a surprise/buzzer-blitz challenge.
// Phase 4 will add dynamic challenge selection from the database.
// -----------------------------------------------------------------------------

export function generateSurpriseChallenge(): {
  title: string;
  description: string;
  bonusPoints: number;
} {
  // TODO Phase 4: Pull random surprise-category questions from Supabase
  return {
    title: 'SURPRISE ROUND: BUZZER BLITZ!',
    description: 'First to buzz in gets exclusive rights to answer for Double Points!',
    bonusPoints: 300,
  };
}

// -----------------------------------------------------------------------------
// Recap Generation
// Generates post-game insights and recommendations.
// Phase 4 will compute actual stats from player_answers aggregate queries.
// -----------------------------------------------------------------------------

export function generateRecap(params: {
  players?: Array<{ name: string; score: number; correctCount: number; totalAnswered: number }>;
}): GameRecap {
  // TODO Phase 4: Compute real stats from Supabase player_answers & session_players
  const players = params.players || [];

  if (players.length === 0) {
    return {
      hostInsight: 'Your family excelled at 90s cinema and science trivia!',
      familySynergyPercent: '94%',
      avgSpeedSec: '1.9s',
      nextGameRecommendation: 'Space & Soundtracks (Co-op)',
    };
  }

  const totalCorrect = players.reduce((sum, p) => sum + p.correctCount, 0);
  const totalAnswered = players.reduce((sum, p) => sum + p.totalAnswered, 0);
  const synergyPercent = totalAnswered > 0
    ? Math.round((totalCorrect / totalAnswered) * 100)
    : 0;

  return {
    hostInsight: `Great teamwork! ${players.length} players competed across multiple rounds.`,
    familySynergyPercent: `${synergyPercent}%`,
    avgSpeedSec: '2.1s',
    nextGameRecommendation: 'Space & Soundtracks (Co-op)',
  };
}
