// =============================================================================
// PlayTogether AI — Adaptive Difficulty Engine
// Deterministic difficulty transition based on recent accuracy and living room dynamics.
// =============================================================================

import { Difficulty, DifficultyStrategy, AdaptiveResult } from '../types';

export const HIGH_ACCURACY_THRESHOLD = 75; // >= 75% accuracy -> shift up
export const LOW_ACCURACY_THRESHOLD = 40;  // <= 40% accuracy -> shift down

/**
 * Computes deterministic adaptive difficulty from accuracy percentage.
 * Prevents rapid oscillation by only transitioning one tier at a time.
 */
export function computeAdaptiveDifficulty(
  accuracyPercent: number,
  currentDifficulty: Difficulty
): AdaptiveResult {
  const roundedAccuracy = Math.round(accuracyPercent);

  if (roundedAccuracy >= HIGH_ACCURACY_THRESHOLD) {
    if (currentDifficulty === 'EASY') {
      return {
        newDifficulty: 'MEDIUM',
        reason: `High accuracy of ${roundedAccuracy}% observed. Elevating challenge to MEDIUM.`,
        calculatedAccuracy: roundedAccuracy,
        formula: 'Turbo Overdrive',
        underdogBoostActive: false,
      };
    }
    if (currentDifficulty === 'MEDIUM') {
      return {
        newDifficulty: 'HARD',
        reason: `Mastery level ${roundedAccuracy}% detected across players. Shifting up to HARD mode.`,
        calculatedAccuracy: roundedAccuracy,
        formula: 'Turbo Overdrive',
        underdogBoostActive: false,
      };
    }
    return {
      newDifficulty: 'HARD',
      reason: `Phenomenal run at ${roundedAccuracy}% accuracy! Capping at maximum HARD tier.`,
      calculatedAccuracy: roundedAccuracy,
      formula: 'Peak Performance',
      underdogBoostActive: false,
    };
  }

  if (roundedAccuracy <= LOW_ACCURACY_THRESHOLD) {
    if (currentDifficulty === 'HARD') {
      return {
        newDifficulty: 'MEDIUM',
        reason: `Recent accuracy dropped to ${roundedAccuracy}%. Easing questions down to MEDIUM to restore living room balance.`,
        calculatedAccuracy: roundedAccuracy,
        formula: 'Family Harmony',
        underdogBoostActive: true,
      };
    }
    if (currentDifficulty === 'MEDIUM') {
      return {
        newDifficulty: 'EASY',
        reason: `Accuracy at ${roundedAccuracy}%. Calibrating down to EASY for a fun comeback window.`,
        calculatedAccuracy: roundedAccuracy,
        formula: 'Catch-Up+',
        underdogBoostActive: true,
      };
    }
    return {
      newDifficulty: 'EASY',
      reason: `Accuracy at ${roundedAccuracy}%. Maintaining accessible EASY tier for family fun.`,
      calculatedAccuracy: roundedAccuracy,
      formula: 'Gentle Pacing',
      underdogBoostActive: true,
    };
  }

  return {
    newDifficulty: currentDifficulty,
    reason: `Balanced performance at ${roundedAccuracy}%. Maintaining current ${currentDifficulty} difficulty.`,
    calculatedAccuracy: roundedAccuracy,
    formula: 'Adaptive Pace',
    underdogBoostActive: false,
  };
}

/**
 * Resolves effective target difficulty from session strategy and current level.
 */
export function resolveTargetDifficulty(
  strategy: DifficultyStrategy,
  currentLevel: Difficulty
): Difficulty {
  if (strategy === 'ADAPTIVE') return currentLevel;
  return strategy;
}
