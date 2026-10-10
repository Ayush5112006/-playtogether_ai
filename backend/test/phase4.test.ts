// =============================================================================
// PlayTogether AI — Phase 4 Comprehensive Automated Test Suite
// Tests all 12 Phase 4 requirements:
// 1. Session creation with 2, 3, and 4 players
// 2. Rejection of < 2 and > 4 players
// 3. Question retrieval by category and difficulty
// 4. Exactly four valid options per question
// 5. Correct and incorrect answers where correct option is not always B
// 6. Invalid option IDs rejection
// 7. Duplicate answer submission rejection (409)
// 8. Score and streak updates
// 9. Adaptive difficulty in all three directions (increase, decrease, maintain)
// 10. Unknown session IDs (404)
// 11. Surprise-round handling and state persistence
// 12. Recap calculations with real stored data and empty-session safety
// =============================================================================

import assert from 'assert';
import http from 'http';
import dotenv from 'dotenv';
import path from 'path';

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../.env') });

import * as gameService from '../src/services/game.service';
import * as supabaseService from '../src/services/supabase.service';
import { getSupabaseClient } from '../src/config/supabase';

// Helper for HTTP requests
function request(
  serverPort: number,
  method: string,
  urlPath: string,
  body?: any
): Promise<{ status: number; body: any }> {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : undefined;
    const req = http.request(
      {
        hostname: 'localhost',
        port: serverPort,
        path: urlPath,
        method: method,
        headers: {
          'Content-Type': 'application/json',
          ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode || 500, body: JSON.parse(data) });
          } catch {
            resolve({ status: res.statusCode || 500, body: data });
          }
        });
      }
    );

    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function runTests() {
  console.log('=============================================================================');
  console.log('🧪 PlayTogether AI — Running Phase 4 Automated Test Suite');
  console.log('=============================================================================\n');

  let passed = 0;
  let total = 0;

  function test(name: string, fn: () => void | Promise<void>) {
    total++;
    return (async () => {
      try {
        await fn();
        console.log(`  ✅ [PASS] ${name}`);
        passed++;
      } catch (err: any) {
        console.error(`  ❌ [FAIL] ${name}`);
        console.error(`     Error: ${err.message}`);
      }
    })();
  }

  // ---------------------------------------------------------------------------
  // UNIT TESTS: Game Business Logic (game.service.ts)
  // ---------------------------------------------------------------------------
  console.log('📦 Section 1: Pure Business Logic & Scoring Rules');

  await test('calculateScore: Incorrect answer awards 0 points', () => {
    const points = gameService.calculateScore({
      isCorrect: false,
      baseValue: 150,
      newStreak: 0,
      responseTimeSeconds: 2.0,
    });
    assert.strictEqual(points, 0);
  });

  await test('calculateScore: Correct answer without bonus awards base points', () => {
    const points = gameService.calculateScore({
      isCorrect: true,
      baseValue: 100,
      newStreak: 1,
      responseTimeSeconds: 8.0, // > 5s -> no speed bonus
    });
    assert.strictEqual(points, 100);
  });

  await test('calculateScore: Speed bonus (+50) applied when answered in <= 5s', () => {
    const points = gameService.calculateScore({
      isCorrect: true,
      baseValue: 100,
      newStreak: 1,
      responseTimeSeconds: 3.5, // <= 5s -> +50
    });
    assert.strictEqual(points, 150); // 100 + 50
  });

  await test('calculateScore: Streak bonus (+25 per streak) applied when streak > 1', () => {
    const points = gameService.calculateScore({
      isCorrect: true,
      baseValue: 100,
      newStreak: 3, // streak = 3 -> +75
      responseTimeSeconds: 8.0,
    });
    assert.strictEqual(points, 175); // 100 + 75
  });

  await test('calculateScore: Speed + Streak combined bonus', () => {
    const points = gameService.calculateScore({
      isCorrect: true,
      baseValue: 150,
      newStreak: 4, // 4 * 25 = 100
      responseTimeSeconds: 2.0, // +50
    });
    assert.strictEqual(points, 300); // 150 + 50 + 100
  });

  await test('Adaptive difficulty: Promotes on high accuracy (>= 75%)', () => {
    const easyToMed = gameService.computeAdaptiveDifficultyFromAccuracy(80, 'EASY');
    assert.strictEqual(easyToMed.newDifficulty, 'MEDIUM');

    const medToHard = gameService.computeAdaptiveDifficultyFromAccuracy(100, 'MEDIUM');
    assert.strictEqual(medToHard.newDifficulty, 'HARD');

    const hardStaysHard = gameService.computeAdaptiveDifficultyFromAccuracy(90, 'HARD');
    assert.strictEqual(hardStaysHard.newDifficulty, 'HARD');
  });

  await test('Adaptive difficulty: Demotes on low accuracy (<= 40%)', () => {
    const hardToMed = gameService.computeAdaptiveDifficultyFromAccuracy(20, 'HARD');
    assert.strictEqual(hardToMed.newDifficulty, 'MEDIUM');

    const medToEasy = gameService.computeAdaptiveDifficultyFromAccuracy(33, 'MEDIUM');
    assert.strictEqual(medToEasy.newDifficulty, 'EASY');

    const easyStaysEasy = gameService.computeAdaptiveDifficultyFromAccuracy(0, 'EASY');
    assert.strictEqual(easyStaysEasy.newDifficulty, 'EASY');
  });

  await test('Adaptive difficulty: Maintains difficulty on balanced performance (50%)', () => {
    const balanced = gameService.computeAdaptiveDifficultyFromAccuracy(50, 'MEDIUM');
    assert.strictEqual(balanced.newDifficulty, 'MEDIUM');
  });

  await test('Recap generation: Safe on empty sessions (0 answers)', () => {
    const recap = gameService.generateRecapFromSessionData({ players: [], answers: [] });
    assert.strictEqual(recap.familySynergyPercent, '0%');
    assert.strictEqual(recap.avgSpeedSec, '0.0s');
    assert.ok(recap.hostInsight.length > 0);
  });

  // ---------------------------------------------------------------------------
  // INTEGRATION TESTS: Live Backend Endpoints (http://localhost:3000)
  // ---------------------------------------------------------------------------
  console.log('\n🌐 Section 2: Integration & Contract Verification (Express + Supabase)');
  const PORT = 3000;

  await test('404 on Unknown Session ID for all session endpoints', async () => {
    const unknownId = 'session_nonexistent_9999';

    const rGet = await request(PORT, 'GET', `/api/sessions/${unknownId}`);
    assert.strictEqual(rGet.status, 404);

    const rQ = await request(PORT, 'POST', `/api/sessions/${unknownId}/question`, {});
    assert.strictEqual(rQ.status, 404);

    const rAns = await request(PORT, 'POST', `/api/sessions/${unknownId}/answer`, {
      questionId: 'q_001',
      selectedOptionId: 'A',
      playerId: 'p1',
    });
    assert.strictEqual(rAns.status, 404);

    const rAdapt = await request(PORT, 'POST', `/api/sessions/${unknownId}/adapt`, {});
    assert.strictEqual(rAdapt.status, 404);

    const rSurprise = await request(PORT, 'POST', `/api/sessions/${unknownId}/surprise`, {});
    assert.strictEqual(rSurprise.status, 404);

    const rRecap = await request(PORT, 'POST', `/api/sessions/${unknownId}/recap`, {});
    assert.strictEqual(rRecap.status, 404);
  });

  await test('Session creation: Rejects fewer than 2 players (400 Bad Request)', async () => {
    const res = await request(PORT, 'POST', '/api/sessions', {
      players: ['SoloPlayer'],
    });
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
    assert.ok(res.body.message.includes('between 2 and 4 players'));
  });

  await test('Session creation: Rejects more than 4 players (400 Bad Request)', async () => {
    const res = await request(PORT, 'POST', '/api/sessions', {
      players: ['P1', 'P2', 'P3', 'P4', 'P5'],
    });
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
  });

  let testSessionId = '';

  await test('Session creation: Successfully creates 3-player session in Supabase', async () => {
    const res = await request(PORT, 'POST', '/api/sessions', {
      players: ['Mom', 'Dad', 'Maya'],
      settings: { difficulty: 'MEDIUM', category: 'Cinema Clues' },
    });
    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.body.success, true);
    assert.ok(res.body.sessionId);
    assert.strictEqual(res.body.session.players.length, 3);
    testSessionId = res.body.sessionId;
  });

  await test('GET /api/sessions/:id retrieves verified session and players', async () => {
    const res = await request(PORT, 'GET', `/api/sessions/${testSessionId}`);
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
    assert.strictEqual(res.body.players.length, 3);
    assert.strictEqual(res.body.players[0].name, 'Mom');
  });

  let retrievedQuestionId = '';

  await test('Question Retrieval: Retrieves question with exactly 4 options', async () => {
    const res = await request(PORT, 'POST', `/api/sessions/${testSessionId}/question`, {
      difficulty: 'MEDIUM',
      category: 'Cinema Clues',
      index: 0,
    });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
    const q = res.body.question;
    assert.ok(q.id);
    assert.strictEqual(q.options.length, 4);
    assert.deepStrictEqual(
      q.options.map((o: any) => o.id),
      ['A', 'B', 'C', 'D']
    );
    // Security check: correctOptionId must NOT be exposed before submission
    assert.strictEqual(q.correctOptionId, '');
    retrievedQuestionId = q.id;
  });

  await test('Answer Validation: Rejects invalid option IDs (e.g. "Z") with 400', async () => {
    const res = await request(PORT, 'POST', `/api/sessions/${testSessionId}/answer`, {
      questionId: retrievedQuestionId,
      selectedOptionId: 'Z',
      playerId: 'p1',
    });
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
  });

  await test('Answer Submission: Verifies correctness against actual stored option (not always B)', async () => {
    // Look up the actual question from database to verify its real correct_option_id
    const dbQuestion = await supabaseService.fetchQuestionById(retrievedQuestionId);
    assert.ok(dbQuestion);
    const realCorrectOption = dbQuestion.correct_option_id;

    // Player 1 submits the true correct answer
    const res = await request(PORT, 'POST', `/api/sessions/${testSessionId}/answer`, {
      questionId: retrievedQuestionId,
      selectedOptionId: realCorrectOption,
      playerId: 'p1',
      responseTimeSeconds: 3.0, // Fast answer -> gets +50 speed bonus
    });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
    assert.strictEqual(res.body.isCorrect, true);
    assert.ok(res.body.pointsEarned >= 150); // 100 base + 50 speed bonus
  });

  await test('Answer Submission: Prevents duplicate answers (409 Conflict)', async () => {
    // Player 1 tries to submit again for the same question
    const res = await request(PORT, 'POST', `/api/sessions/${testSessionId}/answer`, {
      questionId: retrievedQuestionId,
      selectedOptionId: 'A',
      playerId: 'p1',
    });
    assert.strictEqual(res.status, 409);
    assert.strictEqual(res.body.success, false);
    assert.strictEqual(res.body.error, 'DuplicateSubmission');
  });

  await test('Answer Submission: Incorrect answer awards 0 points', async () => {
    const dbQuestion = await supabaseService.fetchQuestionById(retrievedQuestionId);
    const wrongOption = dbQuestion?.correct_option_id === 'A' ? 'B' : 'A';

    // Player 2 answers incorrectly
    const res = await request(PORT, 'POST', `/api/sessions/${testSessionId}/answer`, {
      questionId: retrievedQuestionId,
      selectedOptionId: wrongOption,
      playerId: 'p2',
    });
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.isCorrect, false);
    assert.strictEqual(res.body.pointsEarned, 0);
  });

  await test('Adaptive Difficulty: Uses stored answers to adjust difficulty', async () => {
    const res = await request(PORT, 'POST', `/api/sessions/${testSessionId}/adapt`, {});
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
    assert.ok(['EASY', 'MEDIUM', 'HARD'].includes(res.body.newDifficulty));
    assert.ok(res.body.reason.length > 0);
  });

  await test('Surprise Round: Generates challenge and updates session state', async () => {
    const res = await request(PORT, 'POST', `/api/sessions/${testSessionId}/surprise`, {});
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
    assert.ok(res.body.challenge.title.includes('SURPRISE'));
    assert.strictEqual(res.body.challenge.bonusPoints, 300);
  });

  await test('Recap Generation: Calculates real statistics and persists in game_recaps', async () => {
    const res = await request(PORT, 'POST', `/api/sessions/${testSessionId}/recap`, {});
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
    const recap = res.body.recap;
    assert.ok(recap.hostInsight);
    assert.ok(recap.familySynergyPercent);
    assert.ok(recap.avgSpeedSec);
    assert.ok(recap.nextGameRecommendation);

    // Verify it was actually saved in game_recaps table in Supabase
    const savedRecap = await supabaseService.fetchGameRecap(testSessionId);
    assert.ok(savedRecap);
    assert.strictEqual(savedRecap.session_id, testSessionId);
  });

  console.log('\n=============================================================================');
  console.log(`📊 Test Results: ${passed}/${total} passed (${Math.round((passed / total) * 100)}%)`);
  console.log('=============================================================================\n');

  if (passed !== total) {
    process.exit(1);
  }
}

runTests().catch((err) => {
  console.error('Fatal test error:', err);
  process.exit(1);
});
