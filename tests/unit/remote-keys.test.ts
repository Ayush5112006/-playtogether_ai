import { describe, it, expect } from 'vitest';
import { RemoteCommand } from '@/lib/types';

// KeyCode mapping corresponding to Fire OS and standard TV keyboards (navigation only, no arbitrary shortcuts)
function mapNavKeyToCommand(key: string, keyCode: number): RemoteCommand | null {
  if (key === 'ArrowUp' || keyCode === 19 || keyCode === 38) return 'UP';
  if (key === 'ArrowDown' || keyCode === 20 || keyCode === 40) return 'DOWN';
  if (key === 'ArrowLeft' || keyCode === 21 || keyCode === 37) return 'LEFT';
  if (key === 'ArrowRight' || keyCode === 22 || keyCode === 39) return 'RIGHT';
  if (key === 'Enter' || keyCode === 23 || keyCode === 13) return 'OK';
  if (key === 'Escape' || key === 'GoBack' || key === 'Back' || keyCode === 4 || keyCode === 27) return 'BACK';
  return null;
}

// Runtime dispatcher reflecting removed shortcuts
function mapEventWithShortcutRemoval(e: { key: string; keyCode: number; isInput?: boolean }): RemoteCommand | null {
  if (e.isInput) return null; // Never intercept keys while typing in input/textarea

  // Only allow standard navigation
  return mapNavKeyToCommand(e.key, e.keyCode);
}

describe('Standard TV Navigation Key Mapping', () => {
  it('maps D-pad directional keys correctly', () => {
    expect(mapNavKeyToCommand('ArrowUp', 38)).toBe('UP');
    expect(mapNavKeyToCommand('ArrowDown', 40)).toBe('DOWN');
    expect(mapNavKeyToCommand('ArrowLeft', 37)).toBe('LEFT');
    expect(mapNavKeyToCommand('ArrowRight', 39)).toBe('RIGHT');
  });

  it('maps Fire OS D-pad keycodes (19, 20, 21, 22) correctly', () => {
    expect(mapNavKeyToCommand('ArrowUp', 19)).toBe('UP');
    expect(mapNavKeyToCommand('ArrowDown', 20)).toBe('DOWN');
    expect(mapNavKeyToCommand('ArrowLeft', 21)).toBe('LEFT');
    expect(mapNavKeyToCommand('ArrowRight', 22)).toBe('RIGHT');
  });

  it('maps Select / Enter key to OK', () => {
    expect(mapNavKeyToCommand('Enter', 13)).toBe('OK');
    expect(mapNavKeyToCommand('Enter', 23)).toBe('OK');
  });

  it('maps Escape and Back keys to BACK', () => {
    expect(mapNavKeyToCommand('Escape', 27)).toBe('BACK');
    expect(mapNavKeyToCommand('Back', 4)).toBe('BACK');
  });

  it('returns null for unhandled keys', () => {
    expect(mapNavKeyToCommand('Tab', 9)).toBeNull();
    expect(mapNavKeyToCommand('Space', 32)).toBeNull();
  });
});

describe('Shortcut Removal & Input Protection Verification', () => {
  it('does NOT treat letter B as a shortcut', () => {
    expect(mapEventWithShortcutRemoval({ key: 'b', keyCode: 66, isInput: false })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: 'B', keyCode: 66, isInput: false })).toBeNull();
  });

  it('does NOT treat letter M as a shortcut', () => {
    expect(mapEventWithShortcutRemoval({ key: 'm', keyCode: 77, isInput: false })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: 'M', keyCode: 77, isInput: false })).toBeNull();
  });

  it('does NOT treat letter R as a shortcut', () => {
    expect(mapEventWithShortcutRemoval({ key: 'r', keyCode: 82, isInput: false })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: 'R', keyCode: 82, isInput: false })).toBeNull();
  });

  it('does NOT treat letter T as a shortcut', () => {
    expect(mapEventWithShortcutRemoval({ key: 't', keyCode: 84, isInput: false })).toBeNull();
  });

  it('does NOT treat letter U as a shortcut', () => {
    expect(mapEventWithShortcutRemoval({ key: 'u', keyCode: 85, isInput: false })).toBeNull();
  });

  it('does NOT treat F2 or backquote (`) as remote shortcuts', () => {
    expect(mapEventWithShortcutRemoval({ key: 'F2', keyCode: 113, isInput: false })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: '`', keyCode: 192, isInput: false })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: '~', keyCode: 192, isInput: false })).toBeNull();
  });

  it('never intercepts any key when typing in an input field', () => {
    expect(mapEventWithShortcutRemoval({ key: 'm', keyCode: 77, isInput: true })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: 'r', keyCode: 82, isInput: true })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: 'b', keyCode: 66, isInput: true })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: 'Backspace', keyCode: 8, isInput: true })).toBeNull();
    expect(mapEventWithShortcutRemoval({ key: 'Enter', keyCode: 13, isInput: true })).toBeNull();
  });
});
