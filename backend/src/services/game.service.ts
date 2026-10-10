// =============================================================================
// PlayTogether AI — Game Business Logic Service
// Scoring, adaptive difficulty, surprise challenges, and recap generation.
// Pure domain logic operating on validated inputs.
// =============================================================================

import {
  Difficulty,
  GameRecap,
  SessionPlayerRow,
  PlayerAnswerRow,
} from '../types';

// -----------------------------------------------------------------------------
// Score Calculation
// Aligned with Flutter ScoreCalculator (lib/game/score_calculator.dart)
// -----------------------------------------------------------------------------

export const BASE_TRIVIA_POINTS = 100;
export const BONUS_ROUND_POINTS = 300;
export const STREAK_BONUS_MULTIPLIER = 25;

export interface ScoreParams {
  isCorrect: boolean;
  baseValue: number;
  newStreak: number; // The streak value AFTER this answer
  isBonusRound?: boolean;
  responseTimeSeconds?: number;
}

/**
 * Calculates score awarded for an answer.
 * Aligned with Flutter's ScoreCalculator.
 */
export function calculateScore(params: ScoreParams): number {
  if (!params.isCorrect) return 0;

  let points = params.isBonusRound
    ? BONUS_ROUND_POINTS
    : (params.baseValue > 0 ? params.baseValue : BASE_TRIVIA_POINTS);

  // Speed bonus (+50 if answered within 5 seconds, i.e. remainingSeconds >= 10 out of 15s)
  if (params.responseTimeSeconds !== undefined && params.responseTimeSeconds <= 5.0) {
    points += 50;
  }

  // Streak bonus (+25 per streak if streak > 1)
  if (params.newStreak > 1) {
    points += params.newStreak * STREAK_BONUS_MULTIPLIER;
  }

  return points;
}

// -----------------------------------------------------------------------------
// Adaptive Difficulty
// Evaluates real answer history to adapt difficulty up, down, or maintain.
// Aligned with Flutter AdaptiveDifficultyEngine (lib/game/adaptive_difficulty.dart)
// -----------------------------------------------------------------------------

export interface AdaptiveResult {
  newDifficulty: Difficulty;
  reason: string;
  calculatedAccuracy: number;
}

/**
 * Computes the new difficulty level based on recent answer history.
 *
 * Rules:
 * - Accuracy >= 75%: Increase difficulty (EASY -> MEDIUM, MEDIUM -> HARD, HARD stays HARD)
 * - Accuracy <= 40%: Decrease difficulty (HARD -> MEDIUM, MEDIUM -> EASY, EASY stays EASY)
 * - Otherwise: Maintain current difficulty
 */
export function calculateAdaptiveDifficultyFromHistory(
  recentAnswers: PlayerAnswerRow[],
  currentDifficulty: Difficulty,
  fallbackAccuracy?: number
): AdaptiveResult {
  // If no answers yet in history, use client hint or default
  if (recentAnswers.length === 0) {
    if (fallbackAccuracy !== undefined && fallbackAccuracy !== null) {
      return computeAdaptiveDifficultyFromAccuracy(fallbackAccuracy, currentDifficulty);
    }
    return {
      newDifficulty: currentDifficulty,
      reason: 'Session just started; maintaining initial difficulty.',
      calculatedAccuracy: 0,
    };
  }

  const correctCount = recentAnswers.filter((a) => a.is_correct).length;
  const accuracy = Math.round((correctCount / recentAnswers.length) * 100);

  return computeAdaptiveDifficultyFromAccuracy(accuracy, currentDifficulty);
}

/**
 * Deterministic helper to transition difficulty based on accuracy percentage.
 */
export function computeAdaptiveDifficultyFromAccuracy(
  accuracy: number,
  currentDifficulty: Difficulty
): AdaptiveResult {
  if (accuracy >= 75) {
    if (currentDifficulty === 'EASY') {
      return {
        newDifficulty: 'MEDIUM',
        reason: `Excellent recent performance (${accuracy}%)! Upgrading difficulty to MEDIUM.`,
        calculatedAccuracy: accuracy,
      };
    } else if (currentDifficulty === 'MEDIUM') {
      return {
        newDifficulty: 'HARD',
        reason: `Outstanding performance (${accuracy}%)! Upgrading difficulty to HARD.`,
        calculatedAccuracy: accuracy,
      };
    } else {
      return {
        newDifficulty: 'HARD',
        reason: `Mastery demonstrated (${accuracy}%)! Maintaining HARD difficulty.`,
        calculatedAccuracy: accuracy,
      };
    }
  } else if (accuracy <= 40) {
    if (currentDifficulty === 'HARD') {
      return {
        newDifficulty: 'MEDIUM',
        reason: `Recent accuracy dropped (${accuracy}%). Shifting difficulty back to MEDIUM.`,
        calculatedAccuracy: accuracy,
      };
    } else if (currentDifficulty === 'MEDIUM') {
      return {
        newDifficulty: 'EASY',
        reason: `Pacing adjusted (${accuracy}%). Shifting difficulty to EASY to rebuild momentum.`,
        calculatedAccuracy: accuracy,
      };
    } else {
      return {
        newDifficulty: 'EASY',
        reason: `Foundational pace active (${accuracy}%). Maintaining EASY difficulty.`,
        calculatedAccuracy: accuracy,
      };
    }
  }

  return {
    newDifficulty: currentDifficulty,
    reason: `Balanced gameplay active (${accuracy}% accuracy). Maintaining ${currentDifficulty} difficulty.`,
    calculatedAccuracy: accuracy,
  };
}

// -----------------------------------------------------------------------------
// Surprise Round
// Generates a surprise challenge round.
// -----------------------------------------------------------------------------

export interface SurpriseChallenge {
  title: string;
  description: string;
  bonusPoints: number;
}

const SURPRISE_CHALLENGES: SurpriseChallenge[] = [
  {
    title: 'SURPRISE ROUND: BUZZER BLITZ!',
    description: 'First to buzz in gets exclusive rights to answer for Double Points!',
    bonusPoints: 300,
  },
  {
    title: 'SURPRISE ROUND: LIGHTNING SPRINT!',
    description: 'Answer within 3 seconds for maximum streak bonus points!',
    bonusPoints: 300,
  },
  {
    title: 'SURPRISE ROUND: FAMILY TEAM-UP!',
    description: 'Confer with the family and lock in the collective answer!',
    bonusPoints: 300,
  },
];

export function generateSurpriseChallenge(index = 0): SurpriseChallenge {
  return SURPRISE_CHALLENGES[index % SURPRISE_CHALLENGES.length];
}

// -----------------------------------------------------------------------------
// Recap Generation
// Aggregates real session answers and players into Flutter-compatible SessionRecap.
// -----------------------------------------------------------------------------

export function generateRecapFromSessionData(params: {
  players: SessionPlayerRow[];
  answers: PlayerAnswerRow[];
}): GameRecap {
  const { players, answers } = params;

  // Safe handling for empty session
  if (players.length === 0 || answers.length === 0) {
    const defaultWinner = players[0]
      ? { playerId: players[0].player_id, name: players[0].name, score: players[0].score }
      : undefined;

    return {
      hostInsight: 'Session concluded! A great warm-up round for the whole family.',
      familySynergyPercent: '0%',
      avgSpeedSec: '0.0s',
      nextGameRecommendation: 'Cinema Clues & Animation (Family Edition)',
      winner: defaultWinner,
      standings: players.map((p, idx) => ({
        rank: idx + 1,
        playerId: p.player_id,
        name: p.name,
        score: p.score,
        accuracy: '0%',
        streak: p.best_streak,
      })),
    };
  }

  // 1. Calculate family synergy percentage
  const totalCorrect = answers.filter((a) => a.is_correct).length;
  const synergyNumber = Math.round((totalCorrect / answers.length) * 100);
  const synergyPercent = `${synergyNumber}%`;

  // 2. Calculate average response speed
  const sumSpeed = answers.reduce((sum, a) => sum + (Number(a.response_time_seconds) || 0), 0);
  const avgSpeedNum = answers.length > 0 ? (sumSpeed / answers.length).toFixed(1) : '2.0';
  const avgSpeedSec = `${avgSpeedNum}s`;

  // 3. Standings & Winner
  const sortedPlayers = [...players].sort((a, b) => b.score - a.score);
  const winner = sortedPlayers[0];

  const standings = sortedPlayers.map((p, idx) => {
    const acc = p.total_answered > 0
      ? `${Math.round((p.correct_count / p.total_answered) * 100)}%`
      : '0%';
    return {
      rank: idx + 1,
      playerId: p.player_id,
      name: p.name,
      score: p.score,
      accuracy: acc,
      streak: p.best_streak,
    };
  });

  // 4. Host Insight & Recommendation
  let hostInsight: string;
  if (synergyNumber >= 80) {
    hostInsight = `Sensational family synergy at ${synergyPercent}! ${winner.name} topped the leaderboard with ${winner.score} points and a peak streak of ${winner.best_streak}.`;
  } else if (synergyNumber >= 50) {
    hostInsight = `Impressive teamwork with ${synergyPercent} collective accuracy! ${winner.name} claimed 1st place with ${winner.score} points across ${answers.length} answers.`;
  } else {
    hostInsight = `Fierce family competition! ${winner.name} won with ${winner.score} points. A rematch will surely tilt the leaderboard!`;
  }

  let nextRecommendation: string;
  if (synergyNumber >= 75) {
    nextRecommendation = 'Science & Cosmos (Co-op Discovery)';
  } else if (parseFloat(avgSpeedNum) <= 3.0) {
    nextRecommendation = 'Pop Culture & Music (Lightning Buzzer Blitz)';
  } else {
    nextRecommendation = 'Cinema Clues & Animation (Family Edition)';
  }

  return {
    hostInsight,
    familySynergyPercent: synergyPercent,
    avgSpeedSec,
    nextGameRecommendation: nextRecommendation,
    winner: {
      playerId: winner.player_id,
      name: winner.name,
      score: winner.score,
    },
    standings,
  };
}
