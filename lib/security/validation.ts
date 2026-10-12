// =============================================================================
// PlayTogether AI — Zod Input Validation Schemas
// Strict schema validation for all external API payloads.
// =============================================================================

import { z } from 'zod';

export const PlayerSchema = z.object({
  id: z.string().min(1).max(64),
  name: z.string().min(1).max(64),
  avatarName: z.string().default('default'),
  iconName: z.string().default('smile'),
  accentColor: z.string().default('#D0BCFF'),
  score: z.number().int().min(0).default(0),
  streak: z.number().int().min(0).default(0),
  bestStreak: z.number().int().min(0).default(0),
  correctCount: z.number().int().min(0).default(0),
  totalAnswered: z.number().int().min(0).default(0),
  roleTag: z.string().default('Player'),
});

export const GameSettingsSchema = z.object({
  questionCount: z.union([z.literal(5), z.literal(10), z.literal(15)]).default(10),
  timerSeconds: z.union([z.literal(10), z.literal(15), z.literal(20), z.literal(30)]).default(15),
  difficulty: z.enum(['EASY', 'MEDIUM', 'HARD', 'ADAPTIVE']).default('ADAPTIVE'),
  persona: z.enum(['Playful Host', 'Game Show Host', 'Strict Master']).default('Playful Host'),
  adaptiveHandicap: z.boolean().default(true),
  voiceHostEnabled: z.boolean().default(true),
  sfxEnabled: z.boolean().default(true),
  reducedMotion: z.boolean().default(false),
  highContrast: z.boolean().default(false),
});

export const CreateSessionSchema = z.object({
  sessionId: z.string().min(3).max(64).optional(),
  players: z.array(PlayerSchema).min(1, 'Must have at least 1 player').max(8, 'Cannot have more than 8 players'),
  difficulty: z.enum(['EASY', 'MEDIUM', 'HARD', 'ADAPTIVE']).default('ADAPTIVE'),
  settings: GameSettingsSchema.optional(),
  category: z.string().optional(),
});


export const SubmitAnswerSchema = z.object({
  sessionId: z.string().min(1),
  playerId: z.string().min(1),
  questionId: z.string().min(1),
  selectedOptionId: z.enum(['A', 'B', 'C', 'D']),
  responseTimeSeconds: z.number().min(0).max(60).default(1.0),
});

export const AuthSignUpSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  name: z.string().min(1).max(64).optional(),
});

export const AuthSignInSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export const AuthVerifyOtpSchema = z.object({
  email: z.string().email(),
  token: z.string().min(6).max(8),
  type: z.enum(['signup', 'recovery', 'invite', 'magiclink', 'email_change']).default('signup'),
});

export const MfaVerifySchema = z.object({
  factorId: z.string().min(1),
  challengeId: z.string().min(1),
  code: z.string().length(6, 'MFA code must be exactly 6 digits'),
});

export const AdaptDifficultySchema = z.object({
  sessionId: z.string().min(1),
  recentAccuracy: z.number().min(0).max(100).optional(),
  currentDifficulty: z.enum(['EASY', 'MEDIUM', 'HARD']).default('MEDIUM'),
});

export const sessionCreateSchema = z.object({
  sessionId: z.string().optional(),
  players: z.array(z.object({
    id: z.string().optional(),
    name: z.string().min(1),
    ageGroup: z.string().optional(),
    avatar: z.string().optional(),
    color: z.string().optional(),
  })).min(2, 'Must have at least 2 players').max(4, 'Cannot have more than 4 players'),
  mode: z.string().optional(),
  difficulty: z.string().optional(),
  category: z.string().optional(),
  settings: GameSettingsSchema.optional(),
});

export const answerSubmissionSchema = z.object({
  sessionId: z.string().optional(),
  playerId: z.string().min(1),
  questionId: z.string().min(1),
  selectedOptionId: z.enum(['A', 'B', 'C', 'D']),
  responseTimeMs: z.number().optional(),
  responseTimeSeconds: z.number().optional(),
});
