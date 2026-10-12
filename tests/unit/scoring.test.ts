import { describe, it, expect } from 'vitest';
import {
  calculateAuthoritativeScore,
  sortPlayersDeterministically,
  BASE_TRIVIA_POINTS,
  SPEED_BONUS_POINTS,
  STREAK_BONUS_PER_LEVEL,
  SURPRISE_BONUS_POINTS,
  FINAL_ROUND_BONUS_POINTS,
} from '@/lib/game-engine/scoring';
import { Player } from '@/lib/types';

describe('Authoritative Scoring Engine', () => {
  it('awards 0 points and resets streak to 0 on incorrect answer', () => {
    const result = calculateAuthoritativeScore({
      isCorrect: false,
      currentStreak: 3,
      responseTimeSeconds: 2.1,
    });

    expect(result.pointsEarned).toBe(0);
    expect(result.newStreak).toBe(0);
    expect(result.speedBonusApplied).toBe(false);
    expect(result.streakBonusApplied).toBe(false);
  });

  it('awards base 100 points for correct answer without speed bonus (>5s)', () => {
    const result = calculateAuthoritativeScore({
      isCorrect: true,
      currentStreak: 0,
      responseTimeSeconds: 6.5,
    });

    expect(result.pointsEarned).toBe(BASE_TRIVIA_POINTS);
    expect(result.newStreak).toBe(1);
    expect(result.speedBonusApplied).toBe(false);
    expect(result.streakBonusApplied).toBe(false);
  });

  it('awards +50 speed bonus points when answered within 5.0 seconds', () => {
    const result = calculateAuthoritativeScore({
      isCorrect: true,
      currentStreak: 0,
      responseTimeSeconds: 3.2,
    });

    expect(result.pointsEarned).toBe(BASE_TRIVIA_POINTS + SPEED_BONUS_POINTS);
    expect(result.newStreak).toBe(1);
    expect(result.speedBonusApplied).toBe(true);
    expect(result.streakBonusApplied).toBe(false);
  });

  it('awards streak bonus of +25 pts per level when new streak >= 2', () => {
    // Current streak is 1 -> new streak becomes 2 -> streak bonus is 2 * 25 = 50
    const result = calculateAuthoritativeScore({
      isCorrect: true,
      currentStreak: 1,
      responseTimeSeconds: 7.0, // no speed bonus
    });

    const expectedPoints = BASE_TRIVIA_POINTS + 2 * STREAK_BONUS_PER_LEVEL;
    expect(result.pointsEarned).toBe(expectedPoints);
    expect(result.newStreak).toBe(2);
    expect(result.speedBonusApplied).toBe(false);
    expect(result.streakBonusApplied).toBe(true);
  });

  it('combines speed bonus and streak bonus correctly', () => {
    // Current streak is 2 -> new streak is 3 -> streak bonus = 3 * 25 = 75
    // Speed bonus = 50
    // Base = 100
    // Total = 100 + 50 + 75 = 225
    const result = calculateAuthoritativeScore({
      isCorrect: true,
      currentStreak: 2,
      responseTimeSeconds: 2.5,
    });

    expect(result.pointsEarned).toBe(225);
    expect(result.newStreak).toBe(3);
    expect(result.speedBonusApplied).toBe(true);
    expect(result.streakBonusApplied).toBe(true);
  });

  it('awards surprise round points (300 pts) instead of base points', () => {
    const result = calculateAuthoritativeScore({
      isCorrect: true,
      currentStreak: 0,
      responseTimeSeconds: 8.0,
      isSurpriseRound: true,
    });

    expect(result.pointsEarned).toBe(SURPRISE_BONUS_POINTS);
    expect(result.newStreak).toBe(1);
  });

  it('awards final round points (500 pts) with speed bonus', () => {
    const result = calculateAuthoritativeScore({
      isCorrect: true,
      currentStreak: 0,
      responseTimeSeconds: 4.0,
      isFinalRound: true,
    });

    expect(result.pointsEarned).toBe(FINAL_ROUND_BONUS_POINTS + SPEED_BONUS_POINTS);
    expect(result.speedBonusApplied).toBe(true);
  });

  describe('Deterministic Tie-Breaking', () => {
    const mockPlayers: Player[] = [
      { id: '1', name: 'Sarah', score: 300, streak: 1, bestStreak: 2, correctCount: 3 },
      { id: '2', name: 'Mark', score: 500, streak: 2, bestStreak: 3, correctCount: 5 },
      { id: '3', name: 'Elena', score: 300, streak: 0, bestStreak: 3, correctCount: 3 },
      { id: '4', name: 'Leo', score: 300, streak: 1, bestStreak: 2, correctCount: 4 },
      { id: '5', name: 'Alex', score: 300, streak: 1, bestStreak: 2, correctCount: 3 },
    ];

    it('orders primarily by highest total score', () => {
      const sorted = sortPlayersDeterministically(mockPlayers);
      expect(sorted[0].id).toBe('2'); // Mark with 500 pts
    });

    it('breaks score ties using highest bestStreak', () => {
      const sorted = sortPlayersDeterministically(mockPlayers);
      // Elena has 300 pts and bestStreak 3 vs Leo/Sarah/Alex with bestStreak 2
      expect(sorted[1].id).toBe('3');
    });

    it('breaks bestStreak ties using correctCount', () => {
      const sorted = sortPlayersDeterministically(mockPlayers);
      // Leo has 300 pts, bestStreak 2, and correctCount 4 vs Sarah/Alex with 3
      expect(sorted[2].id).toBe('4');
    });

    it('breaks remaining ties alphabetically by player name', () => {
      const sorted = sortPlayersDeterministically(mockPlayers);
      // Alex vs Sarah: Alex comes first alphabetically
      expect(sorted[3].name).toBe('Alex');
      expect(sorted[4].name).toBe('Sarah');
    });
  });
});
