// =============================================================================
// PlayTogether AI — Session Controller (Phase 4: Real Supabase Integration)
// HTTP request/response handling for all session-related endpoints.
// Verifies session existence, performs input validation, and delegates to services.
// =============================================================================

import { Request, Response } from 'express';
import * as supabaseService from '../services/supabase.service';
import * as gameService from '../services/game.service';
import {
  CreateSessionRequest,
  FetchQuestionRequest,
  SubmitAnswerRequest,
  AdaptDifficultyRequest,
  Difficulty,
} from '../types';

// -----------------------------------------------------------------------------
// POST /api/sessions — Create a new game session
// -----------------------------------------------------------------------------
export async function createSession(req: Request, res: Response): Promise<void> {
  const { players, settings } = req.body as CreateSessionRequest;

  // 1. Validate player count (2 to 4 players required)
  if (!players || !Array.isArray(players) || players.length < 2 || players.length > 4) {
    res.status(400).json({
      success: false,
      error: 'ValidationError',
      message: 'A game session requires between 2 and 4 players.',
    });
    return;
  }

  // 2. Validate player entries
  const normalizedPlayers = players.map((p: any, idx: number) => {
    if (typeof p === 'string') {
      const name = p.trim();
      return {
        playerId: `p${idx + 1}`,
        name: name || `Player ${idx + 1}`,
        avatarName: name || `Player ${idx + 1}`,
      };
    }
    const name = (p.name || `Player ${idx + 1}`).trim();
    return {
      playerId: p.id || p.playerId || `p${idx + 1}`,
      name: name,
      avatarName: p.avatarName || name,
    };
  });

  for (const p of normalizedPlayers) {
    if (!p.name) {
      res.status(400).json({
        success: false,
        error: 'ValidationError',
        message: 'All players must have a non-empty name.',
      });
      return;
    }
  }

  // 3. Generate collision-resistant session ID
  const sessionId = `session_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;

  // Determine initial difficulty
  let initialDifficulty: Difficulty = 'MEDIUM';
  if (settings?.difficulty) {
    const diffUpper = settings.difficulty.toUpperCase();
    if (diffUpper === 'EASY' || diffUpper === 'MEDIUM' || diffUpper === 'HARD') {
      initialDifficulty = diffUpper as Difficulty;
    }
  }

  // 4. Create persistent session and players in Supabase atomically
  const result = await supabaseService.createSessionWithPlayers(
    sessionId,
    settings || {},
    initialDifficulty,
    normalizedPlayers
  );

  if (!result.success) {
    res.status(500).json({
      success: false,
      error: 'DatabaseError',
      message: `Failed to create session: ${result.error}`,
    });
    return;
  }

  const sessionResponse = {
    id: sessionId,
    players: normalizedPlayers,
    settings: settings || {},
    currentRound: 1,
    createdAt: new Date().toISOString(),
  };

  res.status(201).json({
    success: true,
    sessionId: sessionId,
    session: sessionResponse,
  });
}

// -----------------------------------------------------------------------------
// GET /api/sessions/:id — Retrieve existing session details
// -----------------------------------------------------------------------------
export async function getSession(req: Request, res: Response): Promise<void> {
  const sessionId = req.params.id;

  const session = await supabaseService.fetchSession(sessionId);
  if (!session) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: `Session ${sessionId} does not exist.`,
    });
    return;
  }

  const players = await supabaseService.getSessionPlayers(sessionId);

  res.json({
    success: true,
    session: {
      id: session.id,
      status: session.status,
      currentDifficulty: session.current_difficulty,
      settings: session.settings,
      currentRound: session.current_round,
      createdAt: session.created_at,
    },
    players,
  });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/question — Fetch next question
// -----------------------------------------------------------------------------
export async function getQuestion(req: Request, res: Response): Promise<void> {
  const sessionId = req.params.id;
  const { difficulty, category, index } = req.body as FetchQuestionRequest;
  const qIndex = index ?? 0;

  // 1. Verify session exists
  const session = await supabaseService.fetchSession(sessionId);
  if (!session) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: `Session ${sessionId} does not exist.`,
    });
    return;
  }

  // 2. Resolve requested difficulty (fallback to session's current difficulty)
  let targetDifficulty = difficulty?.toUpperCase();
  if (!targetDifficulty || !['EASY', 'MEDIUM', 'HARD'].includes(targetDifficulty)) {
    targetDifficulty = session.current_difficulty;
  }

  // 3. Avoid repeating questions already answered in this session
  const answeredQuestionIds = await supabaseService.getAnsweredQuestionIds(sessionId);

  // 4. Query questions from Supabase matching category & difficulty, excluding answered
  let questions = await supabaseService.fetchQuestions({
    difficulty: targetDifficulty,
    category: category,
    excludeIds: answeredQuestionIds,
    limit: 10,
  });

  // If no unused questions in this category, relax category filter
  if (questions.length === 0) {
    questions = await supabaseService.fetchQuestions({
      difficulty: targetDifficulty,
      excludeIds: answeredQuestionIds,
      limit: 10,
    });
  }

  // If all questions in this difficulty are answered, allow any active questions
  if (questions.length === 0) {
    questions = await supabaseService.fetchQuestions({
      limit: 10,
    });
  }

  if (questions.length === 0) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: 'No trivia questions available in database.',
    });
    return;
  }

  // Pick question deterministically by index
  const selectedQuestionRow = questions[qIndex % questions.length];

  // Check if caller requests exposing the answer (e.g. for testing or legacy mode)
  const exposeAnswer =
    req.query.exposeAnswer === 'true' ||
    process.env.EXPOSE_CORRECT_ANSWER_IN_QUESTION === 'true';

  const apiQuestion = supabaseService.questionRowToApi(selectedQuestionRow, exposeAnswer);

  res.json({
    success: true,
    question: apiQuestion,
  });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/answer — Submit an answer
// -----------------------------------------------------------------------------
export async function submitAnswer(req: Request, res: Response): Promise<void> {
  const sessionId = req.params.id;
  const { questionId, selectedOptionId, playerId, responseTimeSeconds } =
    req.body as SubmitAnswerRequest;

  // 1. Validate required fields
  if (!questionId || typeof questionId !== 'string') {
    res.status(400).json({
      success: false,
      error: 'ValidationError',
      message: 'questionId is required.',
    });
    return;
  }

  if (!selectedOptionId || !['A', 'B', 'C', 'D'].includes(selectedOptionId)) {
    res.status(400).json({
      success: false,
      error: 'ValidationError',
      message: 'selectedOptionId must be A, B, C, or D.',
    });
    return;
  }

  if (!playerId || typeof playerId !== 'string') {
    res.status(400).json({
      success: false,
      error: 'ValidationError',
      message: 'playerId is required.',
    });
    return;
  }

  // 2. Verify session exists
  const session = await supabaseService.fetchSession(sessionId);
  if (!session) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: `Session ${sessionId} does not exist.`,
    });
    return;
  }

  // 3. Verify player belongs to session
  const player = await supabaseService.getSessionPlayer(sessionId, playerId);
  if (!player) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: `Player ${playerId} not found in session ${sessionId}.`,
    });
    return;
  }

  // 4. Fetch question from database
  const questionRow = await supabaseService.fetchQuestionById(questionId);
  if (!questionRow) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: `Question ${questionId} not found.`,
    });
    return;
  }

  // 5. Check duplicate answer submission
  const isDuplicate = await supabaseService.checkAnswerAlreadySubmitted(
    sessionId,
    playerId,
    questionId
  );
  if (isDuplicate) {
    res.status(409).json({
      success: false,
      error: 'DuplicateSubmission',
      message: 'Player has already answered this question in this session.',
    });
    return;
  }

  // 6. Evaluate correctness against real database correct_option_id
  const isCorrect = selectedOptionId === questionRow.correct_option_id;

  // Calculate points using real score calculator
  const responseTime = Number(responseTimeSeconds) || 0;
  const newStreak = isCorrect ? player.streak + 1 : 0;
  const pointsEarned = gameService.calculateScore({
    isCorrect,
    baseValue: questionRow.point_value,
    newStreak,
    responseTimeSeconds: responseTime,
  });

  // 7. Atomic update in Supabase
  const atomicResult = await supabaseService.submitPlayerAnswerAtomic({
    sessionId,
    playerId,
    questionId,
    selectedOptionId,
    isCorrect,
    pointsEarned,
    responseTimeSeconds: responseTime,
    currentStreak: player.streak,
    currentBestStreak: player.best_streak,
    currentScore: player.score,
    currentCorrectCount: player.correct_count,
    currentTotalAnswered: player.total_answered,
  });

  if (atomicResult.isDuplicate) {
    res.status(409).json({
      success: false,
      error: 'DuplicateSubmission',
      message: atomicResult.error || 'Duplicate submission detected.',
    });
    return;
  }

  if (!atomicResult.success) {
    res.status(500).json({
      success: false,
      error: 'DatabaseError',
      message: `Failed to record answer: ${atomicResult.error}`,
    });
    return;
  }

  res.json({
    success: true,
    isCorrect,
    pointsEarned,
    explanation: questionRow.explanation,
  });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/adapt — Adaptive difficulty adjustment
// -----------------------------------------------------------------------------
export async function adaptDifficulty(req: Request, res: Response): Promise<void> {
  const sessionId = req.params.id;
  const { recentAccuracy } = req.body as AdaptDifficultyRequest;

  // 1. Verify session exists
  const session = await supabaseService.fetchSession(sessionId);
  if (!session) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: `Session ${sessionId} does not exist.`,
    });
    return;
  }

  // 2. Fetch real recent answers from Supabase
  const recentAnswers = await supabaseService.getRecentSessionAnswers(sessionId, 5);

  // 3. Compute adaptive difficulty
  const currentDiff = session.current_difficulty as Difficulty;
  const result = gameService.calculateAdaptiveDifficultyFromHistory(
    recentAnswers,
    currentDiff,
    recentAccuracy
  );

  // 4. Update session difficulty if it changed
  if (result.newDifficulty !== currentDiff) {
    await supabaseService.updateSessionDifficulty(sessionId, result.newDifficulty);
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
  const sessionId = req.params.id;

  // 1. Verify session exists
  const session = await supabaseService.fetchSession(sessionId);
  if (!session) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: `Session ${sessionId} does not exist.`,
    });
    return;
  }

  // 2. Pick surprise challenge
  const challenge = gameService.generateSurpriseChallenge(0);

  // 3. Update session settings to track surprise round state
  const updatedSettings = {
    ...(session.settings || {}),
    surpriseRound: {
      triggered: true,
      title: challenge.title,
      triggeredAt: new Date().toISOString(),
    },
  };
  await supabaseService.updateSessionSettings(sessionId, updatedSettings);

  res.json({
    success: true,
    challenge: {
      title: challenge.title,
      description: challenge.description,
      bonusPoints: challenge.bonusPoints,
    },
  });
}

// -----------------------------------------------------------------------------
// POST /api/sessions/:id/recap — Post-game recap & insights
// -----------------------------------------------------------------------------
export async function getRecap(req: Request, res: Response): Promise<void> {
  const sessionId = req.params.id;

  // 1. Verify session exists
  const session = await supabaseService.fetchSession(sessionId);
  if (!session) {
    res.status(404).json({
      success: false,
      error: 'NotFound',
      message: `Session ${sessionId} does not exist.`,
    });
    return;
  }

  // 2. Query all players and all answers from Supabase
  const players = await supabaseService.getSessionPlayers(sessionId);
  const answers = await supabaseService.getAllSessionAnswers(sessionId);

  // 3. Aggregate real statistics
  const recap = gameService.generateRecapFromSessionData({ players, answers });

  // 4. Persist recap in game_recaps table
  await supabaseService.saveGameRecap({
    sessionId,
    hostInsight: recap.hostInsight,
    familySynergyPercent: recap.familySynergyPercent,
    avgSpeedSec: recap.avgSpeedSec,
    nextGameRecommendation: recap.nextGameRecommendation,
    standings: recap.standings,
  });

  res.json({
    success: true,
    recap: {
      hostInsight: recap.hostInsight,
      familySynergyPercent: recap.familySynergyPercent,
      avgSpeedSec: recap.avgSpeedSec,
      nextGameRecommendation: recap.nextGameRecommendation,
    },
  });
}
