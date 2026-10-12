import { describe, it, expect } from 'vitest';
import {
  computeAdaptiveDifficulty,
  resolveTargetDifficulty,
  HIGH_ACCURACY_THRESHOLD,
  LOW_ACCURACY_THRESHOLD,
} from '@/lib/game-engine/difficulty';

describe('Adaptive Difficulty Engine', () => {
  it('promotes EASY to MEDIUM when accuracy >= 75%', () => {
    const result = computeAdaptiveDifficulty(80, 'EASY');
    expect(result.newDifficulty).toBe('MEDIUM');
    expect(result.formula).toBe('Turbo Overdrive');
    expect(result.underdogBoostActive).toBe(false);
  });

  it('promotes MEDIUM to HARD when accuracy >= 75%', () => {
    const result = computeAdaptiveDifficulty(75, 'MEDIUM');
    expect(result.newDifficulty).toBe('HARD');
    expect(result.formula).toBe('Turbo Overdrive');
    expect(result.underdogBoostActive).toBe(false);
  });

  it('caps at HARD tier when already at HARD and accuracy is high', () => {
    const result = computeAdaptiveDifficulty(95, 'HARD');
    expect(result.newDifficulty).toBe('HARD');
    expect(result.formula).toBe('Peak Performance');
  });

  it('demotes HARD to MEDIUM when accuracy <= 40%', () => {
    const result = computeAdaptiveDifficulty(35, 'HARD');
    expect(result.newDifficulty).toBe('MEDIUM');
    expect(result.formula).toBe('Family Harmony');
    expect(result.underdogBoostActive).toBe(true);
  });

  it('demotes MEDIUM to EASY when accuracy <= 40%', () => {
    const result = computeAdaptiveDifficulty(40, 'MEDIUM');
    expect(result.newDifficulty).toBe('EASY');
    expect(result.formula).toBe('Catch-Up+');
    expect(result.underdogBoostActive).toBe(true);
  });

  it('maintains EASY floor when already at EASY and accuracy is low', () => {
    const result = computeAdaptiveDifficulty(20, 'EASY');
    expect(result.newDifficulty).toBe('EASY');
    expect(result.formula).toBe('Gentle Pacing');
    expect(result.underdogBoostActive).toBe(true);
  });

  it('maintains current difficulty when accuracy is in balanced zone (41% - 74%)', () => {
    const result = computeAdaptiveDifficulty(60, 'MEDIUM');
    expect(result.newDifficulty).toBe('MEDIUM');
    expect(result.formula).toBe('Adaptive Pace');
    expect(result.underdogBoostActive).toBe(false);
  });

  it('resolves target difficulty according to strategy', () => {
    expect(resolveTargetDifficulty('EASY', 'HARD')).toBe('EASY');
    expect(resolveTargetDifficulty('HARD', 'EASY')).toBe('HARD');
    expect(resolveTargetDifficulty('ADAPTIVE', 'MEDIUM')).toBe('MEDIUM');
  });
});
