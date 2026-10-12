import { describe, it, expect } from 'vitest';
import { answerSubmissionSchema } from '@/lib/security/validation';
import { calculateAuthoritativeScore } from '@/lib/game-engine/scoring';

describe('Authoritative Answer Evaluation Integration', () => {
  it('validates answer submission payload schema', () => {
    const payload = {
      playerId: 'p1',
      questionId: 'q-seed-01',
      selectedOptionId: 'B',
      responseTimeMs: 3200,
    };

    const parsed = answerSubmissionSchema.safeParse(payload);
    expect(parsed.success).toBe(true);
  });

  it('rejects invalid option identifiers', () => {
    const invalidPayload = {
      playerId: 'p1',
      questionId: 'q-seed-01',
      selectedOptionId: 'Z',
      responseTimeMs: 3200,
    };

    const parsed = answerSubmissionSchema.safeParse(invalidPayload);
    expect(parsed.success).toBe(false);
  });

  it('calculates score based on server-evaluated correctness and response time', () => {
    const isCorrect = true;
    const responseSeconds = 2.8;
    const currentStreak = 2;

    const outcome = calculateAuthoritativeScore({
      isCorrect,
      currentStreak,
      responseTimeSeconds: responseSeconds,
    });

    // Base (100) + Speed Bonus (50) + Streak 3 * 25 (75) = 225
    expect(outcome.pointsEarned).toBe(225);
    expect(outcome.newStreak).toBe(3);
    expect(outcome.speedBonusApplied).toBe(true);
    expect(outcome.streakBonusApplied).toBe(true);
  });

  it('handles negative or invalid response times safely without awarding speed bonus', () => {
    const outcome = calculateAuthoritativeScore({
      isCorrect: true,
      currentStreak: 0,
      responseTimeSeconds: -1,
    });

    expect(outcome.pointsEarned).toBe(100);
    expect(outcome.speedBonusApplied).toBe(false);
  });
});
