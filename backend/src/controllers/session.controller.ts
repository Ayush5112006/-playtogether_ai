// =============================================================================
// PlayTogether AI — Session Controller
// HTTP request/response handling for all session-related endpoints.
// Business logic delegated to services. Phase 4 will complete Supabase integration.
// =============================================================================

import { Request, Response } from 'express';
import { isSupabaseConfigured } from '../config/supabase';
import * as supabaseService from '../services/supabase.service';
import * as gameService from '../services/game.service';
import {
  CreateSessionRequest,
  FetchQuestionRequest,
  SubmitAnswerRequest,
  AdaptDifficultyRequest,
} from '../types';

// In-memory session store (fallback when Supabase is unconfigured or tables are missing)
const sessions = new Map<string, any>();

// -----------------------------------------------------------------------------
// POST /api/sessions — Create a new game session
// -----------------------------------------------------------------------------
export async function createSession(req: Request, res: Response): Promise<void> {
  const { players, settings } = req.body as CreateSessionRequest;
  const sessionId = 'session_' + Math.floor(1000 + Math.random() * 9000);

  // Attempt Supabase persistence
  if (isSupabaseConfigured()) {
    try {
      const dbSession = await supabaseService.createSession({
        id: sessionId,
        settings: settings || {},
        currentDifficulty: 'MEDIUM',
      });

      if (dbSession && players && Array.isArray(players)) {
        // Normalize player data — accept either string names or {id, name} objects
        const playerEntries = players.map((p: any, idx: number) => {
          if (typeof p === 'string') {
            return { playerId: `p${idx + 1}`, name: p };
          }
          return { playerId: p.id || `p${idx + 1}`, name: p.name || `Player ${idx + 1}` };
        });
        await supabaseService.addPlayersToSession(sessionId, playerEntries);
      }
    } catch (_) {
      // Fallback to in-memory if DB write fails
    }
  }

  const session = {
    id: sessionId,
    players: players || [],
    settings: settings || {},
    currentRound: 1,
    createdAt: new Date(),
  };

  sessions.set(sessionId, session);

  res.status(201).json({
    success: true,
    sessionId: sessionId,
    session: session,
  });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/question — Fetch next question
// Phase 4: Full Supabase question querying with deduplication.
// Currently: Tries Supabase first, falls back to hardcoded sample questions.
// -----------------------------------------------------------------------------
export async function getQuestion(req: Request, res: Response): Promise<void> {
  const { difficulty, category, index } = req.body as FetchQuestionRequest;
  const qIndex = index || 0;

  // Attempt Supabase question fetch
  if (isSupabaseConfigured()) {
    try {
      const questions = await supabaseService.fetchQuestions({
        difficulty: difficulty,
        category: category,
        limit: 10,
      });

      if (questions.length > 0) {
        const selected = questions[qIndex % questions.length];
        res.json({ success: true, question: selected });
        return;
      }
    } catch (_) {
      // Fall through to hardcoded fallback
    }
  }

  // Hardcoded fallback (preserves original Phase 1 behavior)
  const sampleQuestions = [
    {
      id: 'q_001',
      category: category || 'Cinema Clues',
      categoryEmoji: '🎬',
      difficulty: difficulty || 'MEDIUM',
      question: 'Which movie character is famous for the line:',
      quoteHighlight: '"May the Force be with you"',
      options: [
        { id: 'A', text: 'Luke Skywalker' },
        { id: 'B', text: 'Han Solo' },
        { id: 'C', text: 'Obi-Wan Kenobi' },
        { id: 'D', text: 'Darth Vader' },
      ],
      correctOptionId: 'B',
      explanation: 'Han Solo says "May the Force be with you" to Luke before the Death Star battle.',
      pointValue: 150,
    },
    {
      id: 'q_002',
      category: 'Science & Cosmos',
      categoryEmoji: '🚀',
      difficulty: difficulty || 'MEDIUM',
      question: 'Which planet in our solar system has the highest surface temperature?',
      quoteHighlight: '"Surface temperature exceeds 860°F"',
      options: [
        { id: 'A', text: 'Mercury' },
        { id: 'B', text: 'Venus' },
        { id: 'C', text: 'Mars' },
        { id: 'D', text: 'Jupiter' },
      ],
      correctOptionId: 'B',
      explanation: 'Venus is the hottest planet due to its dense greenhouse-gas atmosphere trapping heat.',
      pointValue: 100,
    },
  ];

  const selected = sampleQuestions[qIndex % sampleQuestions.length];
  res.json({ success: true, question: selected });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/answer — Submit an answer
// Phase 4: Full answer validation against real question data from Supabase.
// Currently: Tries Supabase lookup, falls back to hardcoded validation.
// -----------------------------------------------------------------------------
export async function submitAnswer(req: Request, res: Response): Promise<void> {
  const sessionId = req.params.id;
  const { questionId, selectedOptionId, playerId, responseTimeSeconds } = req.body as SubmitAnswerRequest & { responseTimeSeconds?: number };

  // Attempt real validation from Supabase
  if (isSupabaseConfigured() && questionId) {
    try {
      const question = await supabaseService.fetchQuestionById(questionId);
      if (question) {
        const isCorrect = selectedOptionId === question.correctOptionId;
        const pointsEarned = gameService.calculateScore({
          isCorrect,
          baseValue: question.pointValue,
          streak: 0, // TODO Phase 4: fetch current player streak from session_players
          remainingSeconds: responseTimeSeconds ? (15 - responseTimeSeconds) : 0,
        });

        // Record the answer in the database
        await supabaseService.recordAnswer({
          sessionId,
          playerId: playerId || 'unknown',
          questionId,
          selectedOptionId,
          isCorrect,
          pointsEarned,
          responseTimeSeconds: responseTimeSeconds || 0,
        });

        // Update player stats
        if (playerId) {
          await supabaseService.updatePlayerStats(sessionId, playerId, {
            scoreDelta: pointsEarned,
            isCorrect,
          });
        }

        res.json({
          success: true,
          isCorrect: isCorrect,
          pointsEarned: pointsEarned,
          explanation: question.explanation,
        });
        return;
      }
    } catch (_) {
      // Fall through to hardcoded fallback
    }
  }

  // Hardcoded fallback (preserves original Phase 1 behavior)
  const isCorrect = selectedOptionId === 'B';
  const pointsEarned = isCorrect ? 150 : 0;

  res.json({
    success: true,
    isCorrect: isCorrect,
    pointsEarned: pointsEarned,
    explanation: 'Validated by PlayTogether AI Game Engine',
  });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/adapt — Adaptive difficulty adjustment
// -----------------------------------------------------------------------------
export async function adaptDifficulty(req: Request, res: Response): Promise<void> {
  const sessionId = req.params.id;
  const { recentAccuracy } = req.body as AdaptDifficultyRequest;

  const result = gameService.computeAdaptiveDifficulty(recentAccuracy);

  // Persist new difficulty to Supabase if configured
  if (isSupabaseConfigured()) {
    try {
      await supabaseService.updateSessionDifficulty(sessionId, result.newDifficulty);
    } catch (_) {
      // Non-critical: difficulty still returned in response
    }
  }

  res.json({
    success: true,
    newDifficulty: result.newDifficulty,
    reason: result.reason,
  });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/surprise — Surprise round challenge
// -----------------------------------------------------------------------------
export async function getSurpriseChallenge(req: Request, res: Response): Promise<void> {
  const challenge = gameService.generateSurpriseChallenge();

  res.json({
    success: true,
    challenge: challenge,
  });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/recap — Post-game recap & insights
// Phase 4: Compute real stats from Supabase session data.
// -----------------------------------------------------------------------------
export async function getRecap(req: Request, res: Response): Promise<void> {
  const sessionId = req.params.id;

  // Attempt to compute recap from real Supabase data
  if (isSupabaseConfigured()) {
    try {
      const players = await supabaseService.getSessionPlayers(sessionId);
      if (players.length > 0) {
        const recap = gameService.generateRecap({
          players: players.map((p) => ({
            name: p.name,
            score: p.score,
            correctCount: p.correct_count,
            totalAnswered: p.total_answered,
          })),
        });

        res.json({ success: true, recap });
        return;
      }
    } catch (_) {
      // Fall through to hardcoded
    }
  }

  // Hardcoded fallback (preserves original Phase 1 behavior)
  res.json({
    success: true,
    recap: {
      hostInsight: 'Your family excelled at 90s cinema and science trivia!',
      familySynergyPercent: '94%',
      avgSpeedSec: '1.9s',
      nextGameRecommendation: 'Space & Soundtracks (Co-op)',
    },
  });
}
