// =============================================================================
// PlayTogether AI — TypeScript Type Definitions
// Authoritative models for game state, players, questions, sessions, and TV input.
// =============================================================================

export type Difficulty = 'EASY' | 'MEDIUM' | 'HARD';
export type DifficultyStrategy = 'EASY' | 'MEDIUM' | 'HARD' | 'ADAPTIVE';

export type GameModeId = 'trivia' | 'movie_guess' | 'ai_surprise' | 'family-adaptive';
export type GameMode = GameModeId | string;

export interface QuestionOption {
  id: 'A' | 'B' | 'C' | 'D' | string;
  text: string;
}

export interface Question {
  id: string;
  category: string;
  categoryEmoji?: string;
  difficulty: Difficulty;
  question: string;
  quoteHighlight?: string;
  options: QuestionOption[];
  correctOptionId: string; // Only exposed after evaluation or in server-only logic
  explanation: string;
  pointValue: number;
  source?: 'DATABASE' | 'FALLBACK' | 'AI_GENERATED';
}

export interface Player {
  id: string;
  name: string;
  avatarName?: string;
  avatar?: string;
  iconName?: string;
  accentColor?: string;
  color?: string;
  ageGroup?: 'child' | 'teen' | 'adult' | 'senior' | string;
  score: number;
  streak: number;
  bestStreak?: number;
  correctCount?: number;
  totalAnswered?: number;
  roleTag?: string;
  isReady?: boolean;
}

export interface GameSettings {
  questionCount: number; // 5, 10, 15
  timerSeconds: number; // 10, 15, 20, 30
  difficulty: DifficultyStrategy;
  persona: 'Playful Host' | 'Game Show Host' | 'Strict Master';
  adaptiveHandicap: boolean;
  voiceHostEnabled: boolean;
  sfxEnabled: boolean;
  reducedMotion: boolean;
  highContrast: boolean;
}

export interface Session {
  id: string;
  joinCode?: string;
  status: 'waiting' | 'in_progress' | 'active' | 'paused' | 'completed';
  currentDifficulty?: Difficulty | number;
  mode?: string;
  category?: string;
  settings?: GameSettings;
  currentRound: number;
  totalRounds?: number;
  currentQuestionIndex?: number;
  adaptivePacing?: string;
  createdAt: string;
  updatedAt?: string;
  players: Player[];
  userId?: string | null;
  isGuestSession?: boolean;
}

export type GameSession = Session;

export interface AnswerSubmission {
  sessionId: string;
  playerId: string;
  questionId: string;
  selectedOptionId: 'A' | 'B' | 'C' | 'D' | string;
  responseTimeSeconds?: number;
  responseTimeMs?: number;
}

export interface AnswerResult {
  isCorrect?: boolean;
  correct?: boolean;
  correctOptionId: 'A' | 'B' | 'C' | 'D' | string;
  pointsEarned?: number;
  scoreDelta?: number;
  newScore?: number;
  streak?: number;
  newStreak?: number;
  bestStreak?: number;
  explanation: string;
  speedBonusApplied?: boolean;
  streakBonusApplied?: boolean;
  buzzerBonusApplied?: boolean;
  player?: Player;
}

export interface AdaptiveResult {
  newDifficulty: Difficulty;
  reason: string;
  calculatedAccuracy: number;
  formula: string;
  underdogBoostActive: boolean;
}

export interface SurpriseChallenge {
  id: string;
  title: string;
  description: string;
  stakes: string;
  bounty: string;
  bonusPoints: number;
  type: 'BUZZER_BLITZ' | 'LIGHTNING_SPRINT' | 'FAMILY_TEAMUP';
}

export interface GameRecapAward {
  playerId: string;
  awardName: string;
  description: string;
}

export interface GameRecap {
  id?: string;
  sessionId: string;
  winnerId?: string;
  winnerPlayerId?: string;
  winnerName?: string;
  winnerScore?: number;
  highestStreak?: number;
  totalQuestions?: number;
  familySynergyScore?: number;
  familySynergyPercent?: string;
  avgSpeedSec?: string;
  aiSummary?: string;
  hostInsight?: string;
  recommendedNextCategory?: string;
  nextGameRecommendation?: string;
  awards?: GameRecapAward[];
  strengthsSummary?: string[];
  createdAt?: string;
}

export interface GameCategory {
  id: string;
  name: string;
  emoji: string;
  description: string;
  questionCount: number;
  orderIndex: number;
}

export type GameCategoryType = string;

export interface GameModeInfo {
  id: GameModeId;
  title: string;
  subtitle: string;
  description: string;
  icon: string;
  badge: string;
  isAvailable: boolean;
}

// -----------------------------------------------------------------------------
// TV Navigation & State Machine Types
// -----------------------------------------------------------------------------

export type GameScreenState =
  | 'SPLASH'
  | 'HOME'
  | 'AUTH'
  | 'PLAYER_SETUP'
  | 'PLAYER_PICKER'
  | 'GAME_MODE'
  | 'SETTINGS'
  | 'GENERATING'
  | 'ROUND_INTRO'
  | 'QUESTION'
  | 'GAMEPLAY'
  | 'ANSWER_RESULT'
  | 'SCORE_UPDATE'
  | 'AI_ADAPTATION'
  | 'SURPRISE'
  | 'SURPRISE_ROUND'
  | 'FINAL'
  | 'FINAL_ROUND'
  | 'WINNER'
  | 'RECAP';

export type ScreenState = GameScreenState;

export type RemoteCommand =
  | 'UP'
  | 'DOWN'
  | 'LEFT'
  | 'RIGHT'
  | 'OK'
  | 'BACK'
  | 'BUZZ'
  | 'MIC'
  | 'MENU';
