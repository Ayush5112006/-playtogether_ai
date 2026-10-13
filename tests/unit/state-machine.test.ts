import { describe, it, expect } from 'vitest';
import {
  isValidTransition,
  getPreviousLogicalState,
  ALLOWED_TRANSITIONS,
} from '@/lib/game-engine/state-machine';
import { GameScreenState } from '@/lib/types';

describe('Authoritative Session State Machine', () => {
  it('allows valid transitions according to transition matrix', () => {
    expect(isValidTransition('SPLASH', 'HOME')).toBe(true);
    expect(isValidTransition('HOME', 'PLAYER_SETUP')).toBe(true);
    expect(isValidTransition('PLAYER_SETUP', 'PLAYER_PICKER')).toBe(true);
    expect(isValidTransition('GAME_MODE', 'PLAYER_SETUP')).toBe(true);
    expect(isValidTransition('GENERATING', 'ROUND_INTRO')).toBe(true);
    expect(isValidTransition('ROUND_INTRO', 'GAMEPLAY')).toBe(true);
    expect(isValidTransition('GAMEPLAY', 'ANSWER_RESULT')).toBe(true);
    expect(isValidTransition('ANSWER_RESULT', 'SCORE_UPDATE')).toBe(true);
    expect(isValidTransition('SCORE_UPDATE', 'AI_ADAPTATION')).toBe(true);
    expect(isValidTransition('SCORE_UPDATE', 'SURPRISE_ROUND')).toBe(true);
    expect(isValidTransition('SCORE_UPDATE', 'FINAL_ROUND')).toBe(true);
    expect(isValidTransition('SCORE_UPDATE', 'WINNER')).toBe(true);
    expect(isValidTransition('WINNER', 'RECAP')).toBe(true);
    expect(isValidTransition('RECAP', 'HOME')).toBe(true);
  });

  it('permits self-transitions (re-entrancy / state refreshes)', () => {
    const states: GameScreenState[] = [
      'HOME',
      'QUESTION',
      'GAMEPLAY',
      'SCORE_UPDATE',
      'SETTINGS',
    ];
    states.forEach((st) => {
      expect(isValidTransition(st, st)).toBe(true);
    });
  });

  it('rejects illegal transitions that skip lifecycle stages', () => {
    // Skipping directly from SPLASH to WINNER is illegal
    expect(isValidTransition('SPLASH', 'WINNER')).toBe(false);
    // Skipping directly from GENERATING to RECAP is illegal
    expect(isValidTransition('GENERATING', 'RECAP')).toBe(false);
    // Skipping directly from GAMEPLAY to WINNER without evaluation is illegal
    expect(isValidTransition('GAMEPLAY', 'WINNER')).toBe(false);
  });

  describe('Fire TV Hardware Remote BACK Key Resolution', () => {
    it('maps previous logical state correctly', () => {
      expect(getPreviousLogicalState('PLAYER_SETUP')).toBe('HOME');
      expect(getPreviousLogicalState('PLAYER_PICKER')).toBe('PLAYER_SETUP');
      expect(getPreviousLogicalState('GAME_MODE')).toBe('PLAYER_SETUP');
      expect(getPreviousLogicalState('SETTINGS')).toBe('GAME_MODE');
      expect(getPreviousLogicalState('GAMEPLAY')).toBe('HOME');
      expect(getPreviousLogicalState('WINNER')).toBe('HOME');
      expect(getPreviousLogicalState('RECAP')).toBe('WINNER');
    });
  });
});
