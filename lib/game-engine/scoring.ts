// =============================================================================
// PlayTogether AI — Authoritative Server-Side Scoring Engine
// Pure domain scoring logic. Never trust a score delta from the browser.
// =============================================================================

import { Player } from '../types';

export const BASE_TRIVIA_POINTS = 100;
export const SPEED_BONUS_POINTS = 50;
export const SPEED_BONUS_THRESHOLD_SECONDS = 5.0; // Answered within 5 seconds
export const STREAK_BONUS_PER_LEVEL = 25; // +25 per streak count for streak > 1
export const SURPRISE_BONUS_POINTS = 300;
export const FINAL_ROUND_BONUS_POINTS = 500;

export interface ScoreCalculationInput {
  isCorrect: boolean;
  basePointValue?: number;
  currentStreak: number; // streak before this answer
  responseTimeSeconds?: number;
  isSurpriseRound?: boolean;
  isFinalRound?: boolean;
}

export interface ScoreCalculationOutput {
  pointsEarned: number;
  newStreak: number;
  speedBonusApplied: boolean;
  streakBonusApplied: boolean;
}

/**
 * Calculates authoritative score update for an answer submission.
 */
export function calculateAuthoritativeScore(
  input: ScoreCalculationInput
): ScoreCalculationOutput {
  if (!input.isCorrect) {
    return {
      pointsEarned: 0,
      newStreak: 0,
      speedBonusApplied: false,
      streakBonusApplied: false,
    };
  }

  const newStreak = input.currentStreak + 1;
  let points = 0;

  if (input.isFinalRound) {
    points = FINAL_ROUND_BONUS_POINTS;
  } else if (input.isSurpriseRound) {
    points = SURPRISE_BONUS_POINTS;
  } else {
    points = input.basePointValue && input.basePointValue > 0
      ? input.basePointValue
      : BASE_TRIVIA_POINTS;
  }

  // Speed Bonus: +50 PTS if answered in <= 5.0 seconds
  const speedBonusApplied =
    input.responseTimeSeconds !== undefined &&
    input.responseTimeSeconds > 0 &&
    input.responseTimeSeconds <= SPEED_BONUS_THRESHOLD_SECONDS;

  if (speedBonusApplied) {
    points += SPEED_BONUS_POINTS;
  }

  // Streak Bonus: +25 PTS per streak when streak >= 2
  const streakBonusApplied = newStreak > 1;
  if (streakBonusApplied) {
    points += newStreak * STREAK_BONUS_PER_LEVEL;
  }

  return {
    pointsEarned: points,
    newStreak,
    speedBonusApplied,
    streakBonusApplied,
  };
}

/**
 * Deterministic tie-breaking rule:
 * 1. Highest total score.
 * 2. If tied, highest bestStreak.
 * 3. If tied, highest correctCount.
 * 4. If tied, earliest created / alphabetical by name for deterministic ordering.
 */
export function sortPlayersDeterministically(players: Player[]): Player[] {
  return [...players].sort((a, b) => {
    if (b.score !== a.score) return b.score - a.score;
    const bBest = b.bestStreak ?? 0;
    const aBest = a.bestStreak ?? 0;
    if (bBest !== aBest) return bBest - aBest;
    const bCorrect = b.correctCount ?? 0;
    const aCorrect = a.correctCount ?? 0;
    if (bCorrect !== aCorrect) return bCorrect - aCorrect;
    return a.name.localeCompare(b.name);
  });
}
