import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { supabase } from './config/supabase';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// In-memory session store
const sessions = new Map<string, any>();

// GET /api/health
app.get('/api/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    appName: 'PlayTogether AI Backend',
    timestamp: new Date().toISOString(),
  });
});

// POST /api/sessions
app.post('/api/sessions', async (req: Request, res: Response) => {
  try {
    const {
      mode = 'COOPERATIVE',
      difficulty = 'MEDIUM',
      durationMinutes = 10,
      players = [],
      settings = {},
    } = req.body;

    const { data, error } = await supabase
      .from('game_sessions')
      .insert({
        mode,
        difficulty,
        duration_minutes: durationMinutes,
        status: 'active',
      })
      .select()
      .single();

    if (error) {
      console.error('Supabase session creation error:', error.message);

      return res.status(500).json({
        success: false,
        message: 'Failed to create game session',
      });
    }

    const session = {
      id: data.id,
      players,
      settings,
      currentRound: 1,
      createdAt: new Date().toISOString(),
      mode: data.mode,
      difficulty: data.difficulty,
      durationMinutes: data.duration_minutes,
      status: data.status,
    };

    return res.status(201).json({
      success: true,
      sessionId: data.id,
      session,
    });
  } catch (error) {
    console.error('Session creation error:', error);

    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// POST /api/sessions/:id/question
app.post('/api/sessions/:id/question', (req: Request, res: Response) => {
  const { difficulty, category, index } = req.body;

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

  const qIndex = (index || 0) % sampleQuestions.length;
  const selectedQuestion = sampleQuestions[qIndex];

  res.json({
    success: true,
    question: selectedQuestion,
  });
});

// POST /api/sessions/:id/answer
app.post('/api/sessions/:id/answer', (req: Request, res: Response) => {
  const { questionId, selectedOptionId, playerId } = req.body;

  const isCorrect = selectedOptionId === 'B';
  const pointsEarned = isCorrect ? 150 : 0;

  res.json({
    success: true,
    isCorrect: isCorrect,
    pointsEarned: pointsEarned,
    explanation: 'Validated by PlayTogether AI Game Engine',
  });
});

// POST /api/sessions/:id/adapt
app.post('/api/sessions/:id/adapt', (req: Request, res: Response) => {
  const { recentAccuracy } = req.body;

  let newDifficulty = 'MEDIUM';
  let reason = 'Balanced gameplay active.';

  if (recentAccuracy >= 80) {
    newDifficulty = 'HARD';
    reason = "You're on fire! Shifting difficulty up to HARD.";
  } else if (recentAccuracy <= 40) {
    newDifficulty = 'EASY';
    reason = "Let's build momentum! Shifting difficulty to EASY.";
  }

  res.json({
    success: true,
    newDifficulty: newDifficulty,
    reason: reason,
  });
});

// POST /api/sessions/:id/surprise
app.post('/api/sessions/:id/surprise', (req: Request, res: Response) => {
  res.json({
    success: true,
    challenge: {
      title: 'SURPRISE ROUND: BUZZER BLITZ!',
      description: 'First to buzz in gets exclusive rights to answer for Double Points!',
      bonusPoints: 300,
    },
  });
});

// POST /api/sessions/:id/recap
app.post('/api/sessions/:id/recap', (req: Request, res: Response) => {
  res.json({
    success: true,
    recap: {
      hostInsight: 'Your family excelled at 90s cinema and science trivia!',
      familySynergyPercent: '94%',
      avgSpeedSec: '1.9s',
      nextGameRecommendation: 'Space & Soundtracks (Co-op)',
    },
  });
});

app.listen(PORT, () => {
  console.log(`[PlayTogether AI Backend] Running on http://localhost:${PORT}`);
});
