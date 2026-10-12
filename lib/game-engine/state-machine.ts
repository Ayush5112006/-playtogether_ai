// =============================================================================
// PlayTogether AI — Authoritative Session State Machine
// Enforces valid transitions and prevents illegal navigation or double-triggers.
// =============================================================================

import { GameScreenState, ScreenState } from '../types';

export { type ScreenState, type GameScreenState };

/**
 * Transition rules definition: maps each valid screen state to its allowed targets.
 */
export const ALLOWED_TRANSITIONS: Record<GameScreenState, GameScreenState[]> = {
  SPLASH: ['HOME', 'AUTH'],
  AUTH: ['HOME', 'SPLASH'],
  HOME: ['AUTH', 'PLAYER_SETUP', 'SETTINGS', 'QUESTION', 'GAMEPLAY', 'GAME_MODE'],
  PLAYER_SETUP: ['HOME', 'PLAYER_PICKER', 'GAME_MODE', 'GENERATING'],
  PLAYER_PICKER: ['PLAYER_SETUP', 'GENERATING'],
  GAME_MODE: ['PLAYER_SETUP', 'SETTINGS', 'HOME'],
  SETTINGS: ['GAME_MODE', 'GENERATING', 'HOME'],
  GENERATING: ['ROUND_INTRO', 'SETTINGS', 'HOME', 'QUESTION', 'GAMEPLAY'],
  ROUND_INTRO: ['QUESTION', 'GAMEPLAY', 'HOME'],
  QUESTION: ['ANSWER_RESULT', 'AI_ADAPTATION', 'SURPRISE', 'SURPRISE_ROUND', 'HOME'],
  GAMEPLAY: ['ANSWER_RESULT', 'AI_ADAPTATION', 'SURPRISE', 'SURPRISE_ROUND', 'HOME'],
  ANSWER_RESULT: ['SCORE_UPDATE', 'AI_ADAPTATION', 'FINAL', 'FINAL_ROUND', 'WINNER'],
  SCORE_UPDATE: ['QUESTION', 'GAMEPLAY', 'AI_ADAPTATION', 'SURPRISE', 'SURPRISE_ROUND', 'FINAL', 'FINAL_ROUND', 'WINNER', 'HOME'],
  AI_ADAPTATION: ['QUESTION', 'GAMEPLAY', 'SURPRISE', 'SURPRISE_ROUND', 'SCORE_UPDATE', 'HOME'],
  SURPRISE: ['QUESTION', 'GAMEPLAY', 'ANSWER_RESULT', 'SCORE_UPDATE', 'FINAL', 'FINAL_ROUND', 'HOME'],
  SURPRISE_ROUND: ['QUESTION', 'GAMEPLAY', 'ANSWER_RESULT', 'SCORE_UPDATE', 'FINAL', 'FINAL_ROUND', 'HOME'],
  FINAL: ['QUESTION', 'GAMEPLAY', 'WINNER', 'HOME'],
  FINAL_ROUND: ['QUESTION', 'GAMEPLAY', 'WINNER', 'HOME'],
  WINNER: ['RECAP', 'SETTINGS', 'HOME'],
  RECAP: ['SETTINGS', 'PLAYER_SETUP', 'GAME_MODE', 'HOME'],
};

/**
 * Validates whether a state transition from `current` to `target` is legal.
 */
export function isValidTransition(
  current: GameScreenState,
  target: GameScreenState
): boolean {
  if (current === target) return true; // Re-entrancy / self-update is safe
  const allowed = ALLOWED_TRANSITIONS[current];
  return allowed ? allowed.includes(target) : false;
}

export const canTransition = isValidTransition;

/**
 * Resolves the previous logical state for the physical Fire TV remote BACK button.
 */
export function getPreviousLogicalState(
  current: GameScreenState
): GameScreenState {
  switch (current) {
    case 'AUTH':
      return 'HOME';
    case 'PLAYER_SETUP':
      return 'GAME_MODE';
    case 'PLAYER_PICKER':
      return 'PLAYER_SETUP';
    case 'GAME_MODE':
      return 'HOME';
    case 'SETTINGS':
      return 'HOME';
    case 'GENERATING':
      return 'PLAYER_PICKER';
    case 'ROUND_INTRO':
      return 'HOME';
    case 'QUESTION':
    case 'GAMEPLAY':
      return 'HOME';
    case 'ANSWER_RESULT':
      return 'SCORE_UPDATE';
    case 'SCORE_UPDATE':
      return 'HOME';
    case 'AI_ADAPTATION':
      return 'GAMEPLAY';
    case 'SURPRISE':
    case 'SURPRISE_ROUND':
      return 'GAMEPLAY';
    case 'FINAL':
    case 'FINAL_ROUND':
      return 'SCORE_UPDATE';
    case 'WINNER':
      return 'HOME';
    case 'RECAP':
      return 'WINNER';
    default:
      return 'HOME';
  }
}

export const resolveBackState = getPreviousLogicalState;
