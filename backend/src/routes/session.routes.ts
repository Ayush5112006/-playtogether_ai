// =============================================================================
// PlayTogether AI — Session Routes
// Maps HTTP endpoints to session controller handlers.
// Preserves all existing paths and HTTP methods.
// =============================================================================

import { Router } from 'express';
import * as sessionController from '../controllers/session.controller';

const router = Router();

// POST /api/sessions — Create a new game session
router.post('/sessions', sessionController.createSession);

// GET /api/sessions/:id — Retrieve existing session details
router.get('/sessions/:id', sessionController.getSession);

// POST /api/sessions/:id/question — Fetch next question for session
router.post('/sessions/:id/question', sessionController.getQuestion);

// POST /api/sessions/:id/answer — Submit an answer
router.post('/sessions/:id/answer', sessionController.submitAnswer);

// POST /api/sessions/:id/adapt — Adaptive difficulty adjustment
router.post('/sessions/:id/adapt', sessionController.adaptDifficulty);

// POST /api/sessions/:id/surprise — Surprise round challenge
router.post('/sessions/:id/surprise', sessionController.getSurpriseChallenge);

// POST /api/sessions/:id/recap — Post-game recap & insights
router.post('/sessions/:id/recap', sessionController.getRecap);

// GET /api/questions — Retrieve all active questions directly from database
router.get('/questions', sessionController.getAllQuestions);

// GET /api/categories — Retrieve categories & question counts
router.get('/categories', sessionController.getCategories);

export default router;
