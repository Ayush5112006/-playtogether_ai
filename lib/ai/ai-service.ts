// =============================================================================
// PlayTogether AI — AI Game Master Service (Member 3: AI & Game Logic)
// Dynamic question generation, adaptive difficulty reasoning, surprise blitzes,
// and post-game family synergy recaps powered by Gemini / LLM with deterministic fallbacks.
// =============================================================================

import { z } from 'zod';
import { Difficulty, Question, Player, GameSettings } from '@/lib/types';
import { SEED_QUESTIONS } from '@/lib/game-engine/seed-questions';

export const AIQuestionSchema = z.object({
  id: z.string().default(() => `ai_q_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`),
  category: z.string().min(1),
  categoryEmoji: z.string().default('✨'),
  difficulty: z.enum(['EASY', 'MEDIUM', 'HARD']),
  question: z.string().min(5),
  options: z.array(
    z.object({
      id: z.enum(['A', 'B', 'C', 'D']),
      text: z.string().min(1),
    })
  ).length(4, 'Must have exactly 4 options'),
  correctOptionId: z.enum(['A', 'B', 'C', 'D']),
  explanation: z.string().min(5),
  pointValue: z.number().int().min(50).max(500).default(100),
  source: z.literal('AI_GENERATED').default('AI_GENERATED'),
});

export interface GenerateQuestionParams {
  category?: string;
  difficulty?: Difficulty;
  ageGroup?: string;
  roundNumber?: number;
  recentQuestionIds?: string[];
  settings?: Partial<GameSettings>;
}

export interface AdaptationResult {
  newDifficulty: Difficulty;
  direction: 'PROMOTED' | 'DEMOTED' | 'MAINTAINED';
  rationale: string;
  handicapAdjustment?: string;
}

export interface SurpriseChallenge {
  id: string;
  title: string;
  description: string;
  multiplier: number;
  bonusPoints: number;
  timeLimitSeconds: number;
  category: string;
  buzzerBlitz: boolean;
}

export interface GameRecapInsight {
  hostInsight: string;
  familySynergyPercent: string;
  avgSpeedSec: string;
  mvpPlayerId: string;
  mvpAwardName: string;
  nextGameRecommendation: string;
  nextGameReason: string;
}

/**
 * Generates or queries an AI-powered trivia question.
 * If external AI key is absent or request times out (4s), returns a validated seed question.
 */
export async function getOrGenerateQuestion(params: GenerateQuestionParams): Promise<Question> {
  const targetCategory = params.category || 'Science & Cosmos';
  const targetDifficulty: Difficulty = params.difficulty || 'MEDIUM';

  const apiKey = process.env.GEMINI_API_KEY || process.env.AI_SERVICE_API_KEY;

  if (apiKey && !apiKey.startsWith('your-')) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 4000);

      const prompt = `You are the lively AI Game Show Host for PlayTogether AI on Amazon Fire TV.
Generate 1 family-friendly trivia question.
Category: "${targetCategory}"
Difficulty: "${targetDifficulty}"
Round: ${params.roundNumber || 1}

Respond strictly in raw JSON (no markdown formatting, no code fences, no extra text) matching this schema:
{
  "category": "${targetCategory}",
  "categoryEmoji": "🎯",
  "difficulty": "${targetDifficulty}",
  "question": "The question text here?",
  "options": [
    {"id": "A", "text": "Option A"},
    {"id": "B", "text": "Option B"},
    {"id": "C", "text": "Option C"},
    {"id": "D", "text": "Option D"}
  ],
  "correctOptionId": "A",
  "explanation": "Short 1-sentence fun fact explaining why.",
  "pointValue": ${targetDifficulty === 'HARD' ? 200 : targetDifficulty === 'EASY' ? 100 : 150}
}`;

      const res = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          signal: controller.signal,
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: {
              temperature: 0.7,
              responseMimeType: 'application/json',
            },
          }),
        }
      );

      clearTimeout(timeoutId);

      if (res.ok) {
        const data = await res.json();
        const rawJsonText = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (rawJsonText) {
          const parsed = JSON.parse(rawJsonText);
          const validated = AIQuestionSchema.safeParse(parsed);
          if (validated.success) {
            return {
              ...validated.data,
              id: `ai_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
              source: 'AI_GENERATED',
            };
          }
        }
      }
    } catch (err) {
      console.warn('[AI Service] Live generation fallback to seed bank:', err);
    }
  }

  // Resilient Seed Fallback
  return getFallbackSeedQuestion(targetCategory, targetDifficulty, params.recentQuestionIds);
}

/**
 * Selects an unused question from the seed pool matching category and difficulty.
 */
export function getFallbackSeedQuestion(
  category: string,
  difficulty: Difficulty,
  usedIds: string[] = []
): Question {
  const normCat = category.toLowerCase().trim();
  const usedSet = new Set(usedIds);

  const matched = SEED_QUESTIONS.filter(
    (q) =>
      !usedSet.has(q.id) &&
      (q.category.toLowerCase().includes(normCat) || normCat.includes(q.category.toLowerCase())) &&
      q.difficulty === difficulty
  );

  if (matched.length > 0) {
    const picked = matched[Math.floor(Math.random() * matched.length)];
    return { ...picked, source: 'FALLBACK' };
  }

  // Relax difficulty constraint
  const categoryFallback = SEED_QUESTIONS.filter(
    (q) =>
      !usedSet.has(q.id) &&
      (q.category.toLowerCase().includes(normCat) || normCat.includes(q.category.toLowerCase()))
  );

  if (categoryFallback.length > 0) {
    const picked = categoryFallback[Math.floor(Math.random() * categoryFallback.length)];
    return { ...picked, source: 'FALLBACK' };
  }

  // Any unused seed question
  const unused = SEED_QUESTIONS.filter((q) => !usedSet.has(q.id));
  const fallback = unused.length > 0 ? unused[0] : SEED_QUESTIONS[0];
  return { ...fallback, source: 'FALLBACK' };
}

/**
 * Calculates adaptive difficulty shift with AI Host commentary.
 */
export function calculateAdaptiveShift(
  recentAccuracyPercent: number,
  currentDifficulty: Difficulty,
  leadPlayerName?: string
): AdaptationResult {
  if (recentAccuracyPercent >= 75) {
    const newDifficulty: Difficulty = currentDifficulty === 'EASY' ? 'MEDIUM' : 'HARD';
    return {
      newDifficulty,
      direction: currentDifficulty === 'HARD' ? 'MAINTAINED' : 'PROMOTED',
      rationale: leadPlayerName
        ? `${leadPlayerName} and the family are on fire (${recentAccuracyPercent}% accuracy)! Shifting to ${newDifficulty} with high-value multipliers!`
        : `High accuracy detected (${recentAccuracyPercent}%). Shifting to ${newDifficulty} for a tighter competition.`,
      handicapAdjustment: 'Junior players receive 5-second bonus clock.',
    };
  }

  if (recentAccuracyPercent <= 40) {
    const newDifficulty: Difficulty = currentDifficulty === 'HARD' ? 'MEDIUM' : 'EASY';
    return {
      newDifficulty,
      direction: currentDifficulty === 'EASY' ? 'MAINTAINED' : 'DEMOTED',
      rationale: `Tricky round! Recalibrating to ${newDifficulty} questions to bring everyone back into the game.`,
      handicapAdjustment: 'Lifeline hints activated on the remote.',
    };
  }

  return {
    newDifficulty: currentDifficulty,
    direction: 'MAINTAINED',
    rationale: `Balanced match dynamics (${recentAccuracyPercent}% accuracy). Maintaining ${currentDifficulty} pacing.`,
  };
}

/**
 * Generates an exciting Surprise Round challenge.
 */
export function generateSurpriseChallenge(players: Player[], category: string): SurpriseChallenge {
  const sorted = [...players].sort((a, b) => b.score - a.score);
  const leader = sorted[0];
  const trailing = sorted[sorted.length - 1];

  const gap = leader && trailing ? leader.score - trailing.score : 0;

  return {
    id: `surprise_${Date.now()}`,
    title: '⚡ LIGHTNING BUZZER BLITZ',
    description:
      gap > 200
        ? `Comeback opportunity! ${trailing?.name || 'Trailing players'} can close the gap with a 300-point buzzer bonus!`
        : 'Double-stakes speed round! First player to buzz and answer correctly takes 300 bonus points!',
    multiplier: 2.0,
    bonusPoints: 300,
    timeLimitSeconds: 10,
    category: category || 'Surprise Buzzer Blitz',
    buzzerBlitz: true,
  };
}

/**
 * Computes AI post-game recap metrics, family synergy, and next game recommendation.
 */
export function generateAIRecap(players: Player[], answersCount: number, avgResponseTimeSec: number): GameRecapInsight {
  if (!players || players.length === 0) {
    return {
      hostInsight: 'Thank you for playing PlayTogether AI! Gather the family and jump back in anytime.',
      familySynergyPercent: '0%',
      avgSpeedSec: '0.0s',
      mvpPlayerId: '',
      mvpAwardName: 'Family Gamer',
      nextGameRecommendation: 'Cinema Clues',
      nextGameReason: 'A fun crowd-pleaser for all movie fans.',
    };
  }

  const sorted = [...players].sort((a, b) => b.score - a.score);
  const winner = sorted[0];

  // Synergy formula based on score dispersion and answer participation
  const scores = players.map((p) => p.score);
  const totalScore = scores.reduce((sum, s) => sum + s, 0);
  const maxScore = Math.max(...scores);
  const minScore = Math.min(...scores);
  const range = maxScore - minScore;

  // Closer games have higher synergy
  const synergyScore = range === 0 ? 98 : Math.max(68, Math.min(96, Math.round(100 - (range / (totalScore + 1)) * 40)));

  const recommendations = [
    { mode: 'Movie Guess (Cinema Clues)', reason: 'Great for mixed generations to solve quotes and iconic scenes together.' },
    { mode: 'Science & Cosmos Blitz', reason: 'High-speed challenges with visual planetary clues.' },
    { mode: 'Pop Culture & Music Anthems', reason: 'Sing-along trivia that levels the playing field across all ages.' },
    { mode: 'Animation & Family Universe', reason: 'Engaging themes for younger players and nostalgic adults alike.' },
  ];

  const pickedRec = recommendations[Math.floor(Math.random() * recommendations.length)];

  return {
    hostInsight: `Incredible showdown! ${winner.name} secured 1st place with ${winner.score} points, but the entire sofa maintained outstanding momentum throughout all rounds.`,
    familySynergyPercent: `${synergyScore}%`,
    avgSpeedSec: `${avgResponseTimeSec.toFixed(1)}s`,
    mvpPlayerId: winner.id,
    mvpAwardName: winner.streak >= 3 ? 'Unstoppable Streak Champion' : 'Sharp Shooter MVP',
    nextGameRecommendation: pickedRec.mode,
    nextGameReason: pickedRec.reason,
  };
}
