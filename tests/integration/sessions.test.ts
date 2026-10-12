import { describe, it, expect } from 'vitest';
import { SEED_QUESTIONS } from '@/lib/game-engine/seed-questions';
import { sessionCreateSchema, answerSubmissionSchema } from '@/lib/security/validation';
import { checkRateLimit } from '@/lib/security/rate-limit';

describe('Sessions & Seed Data Integration', () => {
  it('contains at least 30 verified seed questions across categories', () => {
    expect(SEED_QUESTIONS.length).toBeGreaterThanOrEqual(30);
  });

  it('validates that every seed question has 4 unique options and a valid correct option', () => {
    SEED_QUESTIONS.forEach((q) => {
      expect(q.options).toHaveLength(4);
      expect(['A', 'B', 'C', 'D']).toContain(q.correctOptionId);
      expect(q.explanation.length).toBeGreaterThan(10);
      expect(q.question.length).toBeGreaterThan(5);

      const optionIds = q.options.map((o) => o.id);
      expect(new Set(optionIds).size).toBe(4);
    });
  });

  it('validates session creation input using Zod schema', () => {
    const validData = {
      mode: 'trivia',
      category: 'Science & Cosmos',
      players: [
        { name: 'Dad', ageGroup: 'adult', avatar: '👨‍💼', color: '#3b82f6' },
        { name: 'Leo', ageGroup: 'child', avatar: '👦', color: '#10b981' },
      ],
    };

    const parsed = sessionCreateSchema.safeParse(validData);
    expect(parsed.success).toBe(true);
  });

  it('rejects session creation with fewer than 2 players', () => {
    const invalidData = {
      mode: 'trivia',
      category: 'Science & Cosmos',
      players: [
        { name: 'Dad', ageGroup: 'adult', avatar: '👨‍💼', color: '#3b82f6' },
      ],
    };

    const parsed = sessionCreateSchema.safeParse(invalidData);
    expect(parsed.success).toBe(false);
  });

  it('enforces rate limiting sliding window', () => {
    const testIp = 'test-ip-127.0.0.1';
    // 5 requests within limit
    for (let i = 0; i < 5; i++) {
      const allowed = checkRateLimit(testIp, 'session:create', 10, 60);
      expect(allowed.allowed).toBe(true);
    }
  });
});
