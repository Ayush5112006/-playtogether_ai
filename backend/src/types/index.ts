// =============================================================================
// PlayTogether AI — Shared TypeScript Types
// Aligned with Flutter models (lib/models/) and API response contracts
// =============================================================================

// -----------------------------------------------------------------------------
// Difficulty
// -----------------------------------------------------------------------------
export type Difficulty = 'EASY' | 'MEDIUM' | 'HARD';

// -----------------------------------------------------------------------------
// Option — matches Flutter Option class (lib/models/question.dart)
// -----------------------------------------------------------------------------
export interface QuestionOption {
  id: string; // "A", "B", "C", or "D"
  text: string;
}

// -----------------------------------------------------------------------------
// Question — matches Flutter Question.fromJson (lib/models/question.dart)
// -----------------------------------------------------------------------------
export interface Question {
  id: string;
  category: string;
  categoryEmoji: string;
  difficulty: Difficulty;
  question: string;
  quoteHighlight: string;
  options: QuestionOption[];
  correctOptionId?: string; // Masked or empty before answer submission for security
  explanation: string;
  pointValue: number;
}

// -----------------------------------------------------------------------------
// Question DB Row — maps Supabase `questions` table columns
// -----------------------------------------------------------------------------
export interface QuestionRow {
  id: string;
  category: string;
  category_emoji: string;
  difficulty: Difficulty;
  question: string;
  quote_highlight: string;
  options: QuestionOption[];
  correct_option_id: string;
  explanation: string;
  point_value: number;
  is_active: boolean;
  created_at: string;
}

// -----------------------------------------------------------------------------
// GameSettings — matches Flutter GameSettings (lib/models/game_settings.dart)
// -----------------------------------------------------------------------------
export interface GameSettings {
  difficulty?: string; // "Easy", "Medium", "Hard", "Adaptive"
  durationMinutes?: number; // 5, 10, 15
  category?: string; // "General Trivia", "Cinema Clues", etc.
  familyFriendly?: boolean;
}

// -----------------------------------------------------------------------------
// Session — matches POST /api/sessions response and Flutter usage
// -----------------------------------------------------------------------------
export interface GameSession {
  id: string;
  status: 'waiting' | 'active' | 'paused' | 'completed';
  currentDifficulty: Difficulty;
  settings: GameSettings;
  currentRound: number;
  createdAt: string;
  updatedAt: string;
}

// Session DB Row — maps Supabase `sessions` table
export interface SessionRow {
  id: string;
  status: string;
  current_difficulty: string;
  settings: GameSettings;
  current_round: number;
  created_at: string;
  updated_at: string;
}

// -----------------------------------------------------------------------------
// Player — matches Flutter Player model (lib/models/player.dart)
// -----------------------------------------------------------------------------
export interface Player {
  id: string;
  playerId: string;
  sessionId: string;
  name: string;
  avatarName: string;
  roleTag: string;
  score: number;
  streak: number;
  bestStreak: number;
  correctCount: number;
  totalAnswered: number;
}

// Session Player DB Row
export interface SessionPlayerRow {
  id: string;
  session_id: string;
  player_id: string;
  name: string;
  avatar_name: string;
  role_tag: string;
  score: number;
  streak: number;
  best_streak: number;
  correct_count: number;
  total_answered: number;
  created_at: string;
  updated_at: string;
}

// -----------------------------------------------------------------------------
// PlayerAnswer — matches POST /api/sessions/:id/answer and player_answers table
// -----------------------------------------------------------------------------
export interface PlayerAnswer {
  id: string;
  sessionId: string;
  playerId: string;
  questionId: string;
  selectedOptionId: string;
  isCorrect: boolean;
  pointsEarned: number;
  responseTimeSeconds: number;
  createdAt: string;
}

export interface PlayerAnswerRow {
  id: string;
  session_id: string;
  player_id: string;
  question_id: string;
  selected_option_id: string;
  is_correct: boolean;
  points_earned: number;
  response_time_seconds: number;
  created_at: string;
}

// -----------------------------------------------------------------------------
// GameRecap — matches Flutter SessionRecap (lib/models/recap.dart)
// -----------------------------------------------------------------------------
export interface GameRecap {
  hostInsight: string;
  familySynergyPercent: string;
  avgSpeedSec: string;
  nextGameRecommendation: string;
  winner?: {
    playerId: string;
    name: string;
    score: number;
  };
  standings?: Array<{
    rank: number;
    playerId: string;
    name: string;
    score: number;
    accuracy: string;
    streak: number;
  }>;
}

export interface GameRecapRow {
  id: string;
  session_id: string;
  host_insight: string;
  family_synergy_percent: string;
  avg_speed_sec: string;
  next_game_recommendation: string;
  standings: any[];
  created_at: string;
}

// -----------------------------------------------------------------------------
// API Request Bodies
// -----------------------------------------------------------------------------
export interface CreateSessionRequest {
  players?: any[];
  settings?: GameSettings;
}

export interface FetchQuestionRequest {
  difficulty?: string;
  category?: string;
  index?: number;
}

export interface SubmitAnswerRequest {
  questionId: string;
  selectedOptionId: string;
  playerId: string;
  responseTimeSeconds?: number;
}

export interface AdaptDifficultyRequest {
  recentAccuracy?: number;
}

// -----------------------------------------------------------------------------
// API Response Envelopes
// -----------------------------------------------------------------------------
export interface ApiResponse<T = any> {
  success: boolean;
  error?: string;
  message?: string;
  [key: string]: any;
}

export interface CreateSessionResponse {
  success: boolean;
  sessionId: string;
  session: {
    id: string;
    players: any[];
    settings: GameSettings;
    currentRound: number;
    createdAt: string;
  };
}

export interface QuestionResponse {
  success: boolean;
  question: Question;
}

export interface AnswerResponse {
  success: boolean;
  isCorrect: boolean;
  pointsEarned: number;
  explanation: string;
}

export interface AdaptResponse {
  success: boolean;
  newDifficulty: string;
  reason: string;
}

export interface SurpriseResponse {
  success: boolean;
  challenge: {
    title: string;
    description: string;
    bonusPoints: number;
  };
}

export interface RecapResponse {
  success: boolean;
  recap: GameRecap;
}
