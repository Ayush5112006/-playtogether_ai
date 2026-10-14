// =============================================================================
// PlayTogether AI — Member 3: AI Service Unit Tests
// Tests AI Question generation, adaptive difficulty shifts, surprise round logic,
// and post-game synergy recap calculations.
// =============================================================================

import { describe, it, expect } from 'vitest';
import {
  getOrGenerateQuestion,
  getFallbackSeedQuestion,
  calculateAdaptiveShift,
  generateSurpriseChallenge,
  generateAIRecap,
  AIQuestionSchema,
} from '@/lib/ai/ai-service';
import { Player } from '@/lib/types';

describe('Member 3: AI Service & Game Logic', () => {
  const mockPlayers: Player[] = [
    { id: 'p1', name: 'Dad', score: 350, streak: 3 },
    { id: 'p2', name: 'Mom', score: 280, streak: 1 },
    { id: 'p3', name: 'Leo', score: 100, streak: 0 },
  ];

  describe('AI Question Generation & Seed Fallbacks', () => {
    it('returns a question strictly adhering to the 4-option schema', async () => {
      const q = await getOrGenerateQuestion({
        category: 'Science & Cosmos',
        difficulty: 'MEDIUM',
        roundNumber: 1,
      });

      expect(q).toBeDefined();
      expect(q.options).toHaveLength(4);
      expect(['A', 'B', 'C', 'D']).toContain(q.correctOptionId);
      expect(q.question.length).toBeGreaterThan(5);
      expect(q.pointValue).toBeGreaterThan(0);
    });

    it('getFallbackSeedQuestion returns question for requested category', () => {
      const q = getFallbackSeedQuestion('Cinema Clues', 'EASY');
      expect(q).toBeDefined();
      expect(q.options).toHaveLength(4);
      expect(['A', 'B', 'C', 'D']).toContain(q.correctOptionId);
    });

    it('avoids previously answered question IDs when picking fallbacks', () => {
      const q1 = getFallbackSeedQuestion('Science & Cosmos', 'MEDIUM', []);
      const q2 = getFallbackSeedQuestion('Science & Cosmos', 'MEDIUM', [q1.id]);
      expect(q2.id).not.toBe(q1.id);
    });
  });

  describe('Adaptive Difficulty Shift Reasoning', () => {
    it('promotes difficulty to HARD when accuracy is >= 75%', () => {
      const result = calculateAdaptiveShift(85, 'MEDIUM', 'Dad');
      expect(result.newDifficulty).toBe('HARD');
      expect(result.direction).toBe('PROMOTED');
      expect(result.rationale).toContain('Dad');
    });

    it('demotes difficulty to EASY when accuracy is <= 40%', () => {
      const result = calculateAdaptiveShift(30, 'MEDIUM');
      expect(result.newDifficulty).toBe('EASY');
      expect(result.direction).toBe('DEMOTED');
      expect(result.rationale).toContain('Tricky round');
    });

    it('maintains difficulty on balanced performance', () => {
      const result = calculateAdaptiveShift(55, 'MEDIUM');
      expect(result.newDifficulty).toBe('MEDIUM');
      expect(result.direction).toBe('MAINTAINED');
    });
  });

  describe('Surprise Challenge Generation', () => {
    it('generates a high-stakes lightning buzzer challenge', () => {
      const surprise = generateSurpriseChallenge(mockPlayers, 'Pop Culture');
      expect(surprise.buzzerBlitz).toBe(true);
      expect(surprise.bonusPoints).toBe(300);
      expect(surprise.multiplier).toBe(2.0);
      expect(surprise.title).toContain('LIGHTNING BUZZER BLITZ');
    });
  });

  describe('Post-Game AI Recap & Synergy Analysis', () => {
    it('computes realistic family synergy score and MVP award', () => {
      const recap = generateAIRecap(mockPlayers, 15, 2.4);
      expect(recap.familySynergyPercent).toMatch(/^[0-9]+%$/);
      expect(recap.avgSpeedSec).toBe('2.4s');
      expect(recap.mvpPlayerId).toBe('p1');
      expect(recap.nextGameRecommendation).toBeDefined();
      expect(recap.hostInsight).toContain('Dad');
    });

    it('handles empty player roster gracefully', () => {
      const recap = generateAIRecap([], 0, 0);
      expect(recap.familySynergyPercent).toBe('0%');
      expect(recap.hostInsight).toBeDefined();
    });
  });
});
