'use client';

// =============================================================================
// PlayTogether AI — Centralized Fire TV Remote & Spatial Focus Manager
// Manages physical remote D-pad input, keyboard fallbacks, audible feedback,
// and visible TV safe-zone focus highlights.
// =============================================================================

import React, { createContext, useContext, useEffect, useState, useCallback, useRef } from 'react';
import { RemoteCommand } from '@/lib/types';

export type TVSoundType =
  | 'navigate'
  | 'select'
  | 'back'
  | 'buzz'
  | 'click'
  | 'correct'
  | 'wrong'
  | 'ai'
  | 'surprise'
  | 'countdown'
  | 'winner';

export function playTVSound(type: TVSoundType) {
  if (typeof window === 'undefined') return;
  try {
    const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
    if (!AudioCtx) return;
    const ctx = new AudioCtx();
    const now = ctx.currentTime;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);

    if (type === 'navigate' || type === 'click') {
      osc.type = 'sine';
      osc.frequency.setValueAtTime(420, now);
      osc.frequency.exponentialRampToValueAtTime(320, now + 0.05);
      gain.gain.setValueAtTime(0.04, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.05);
      osc.start(now);
      osc.stop(now + 0.05);
    } else if (type === 'select' || type === 'correct') {
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(523.25, now);
      osc.frequency.setValueAtTime(659.25, now + 0.08);
      gain.gain.setValueAtTime(0.08, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.2);
      osc.start(now);
      osc.stop(now + 0.2);
    } else if (type === 'wrong') {
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(220, now);
      osc.frequency.setValueAtTime(180, now + 0.1);
      gain.gain.setValueAtTime(0.09, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
      osc.start(now);
      osc.stop(now + 0.25);
    } else if (type === 'buzz') {
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(350, now);
      osc.frequency.linearRampToValueAtTime(700, now + 0.15);
      gain.gain.setValueAtTime(0.12, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
      osc.start(now);
      osc.stop(now + 0.15);
    } else if (type === 'ai') {
      osc.type = 'sine';
      osc.frequency.setValueAtTime(600, now);
      osc.frequency.exponentialRampToValueAtTime(900, now + 0.15);
      gain.gain.setValueAtTime(0.06, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.3);
      osc.start(now);
      osc.stop(now + 0.3);
    } else if (type === 'surprise' || type === 'countdown') {
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(440, now);
      osc.frequency.exponentialRampToValueAtTime(880, now + 0.2);
      gain.gain.setValueAtTime(0.1, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
      osc.start(now);
      osc.stop(now + 0.25);
    } else if (type === 'winner') {
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(523.25, now);
      osc.frequency.setValueAtTime(659.25, now + 0.1);
      osc.frequency.setValueAtTime(783.99, now + 0.2);
      osc.frequency.setValueAtTime(1046.5, now + 0.3);
      gain.gain.setValueAtTime(0.12, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.6);
      osc.start(now);
      osc.stop(now + 0.6);
    } else {
      osc.type = 'sine';
      osc.frequency.setValueAtTime(360, now);
      osc.frequency.exponentialRampToValueAtTime(200, now + 0.07);
      gain.gain.setValueAtTime(0.05, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.07);
      osc.start(now);
      osc.stop(now + 0.07);
    }
  } catch {
    // Audio autoplay restrictions catch
  }
}

interface TVFocusContextType {
  activeFocusId: string;
  setActiveFocusId: (id: string) => void;
  registerFocusable: (id: string, group?: string) => () => void;
  lastCommand: RemoteCommand | null;
  commandCounter: number;
  triggerRemoteCommand: (cmd: RemoteCommand) => void;
  isAudioFeedbackEnabled: boolean;
  toggleAudioFeedback: () => void;
  reducedMotion: boolean;
}

const TVFocusContext = createContext<TVFocusContextType | null>(null);

export function useTVFocus() {
  const ctx = useContext(TVFocusContext);
  if (!ctx) {
    throw new Error('useTVFocus must be used within a TVFocusProvider');
  }
  return ctx;
}

function findNextSpatialFocusId(
  currentId: string,
  cmd: 'UP' | 'DOWN' | 'LEFT' | 'RIGHT',
  registeredIds: string[]
): string {
  if (typeof document === 'undefined') return currentId;
  const currentIndex = registeredIds.indexOf(currentId);
  const currentEl = document.getElementById(currentId);

  if (!currentEl) {
    if (cmd === 'DOWN' || cmd === 'RIGHT') {
      return registeredIds[(currentIndex + 1) % registeredIds.length] || currentId;
    }
    return registeredIds[(currentIndex - 1 + registeredIds.length) % registeredIds.length] || currentId;
  }

  const currentRect = currentEl.getBoundingClientRect();
  const cX = currentRect.left + currentRect.width / 2;
  const cY = currentRect.top + currentRect.height / 2;

  let bestId: string | null = null;
  let bestScore = Infinity;

  for (const id of registeredIds) {
    if (id === currentId) continue;
    const el = document.getElementById(id);
    if (!el) continue;
    const rect = el.getBoundingClientRect();
    if (rect.width === 0 || rect.height === 0) continue;

    const tX = rect.left + rect.width / 2;
    const tY = rect.top + rect.height / 2;

    const dx = tX - cX;
    const dy = tY - cY;

    let isValid = false;
    let score = Infinity;

    if (cmd === 'UP' && dy < -10) {
      isValid = true;
      score = Math.abs(dy) * 1.5 + Math.abs(dx);
    } else if (cmd === 'DOWN' && dy > 10) {
      isValid = true;
      score = Math.abs(dy) * 1.5 + Math.abs(dx);
    } else if (cmd === 'LEFT' && dx < -10) {
      isValid = true;
      score = Math.abs(dx) * 1.5 + Math.abs(dy);
    } else if (cmd === 'RIGHT' && dx > 10) {
      isValid = true;
      score = Math.abs(dx) * 1.5 + Math.abs(dy);
    }

    if (isValid && score < bestScore) {
      bestScore = score;
      bestId = id;
    }
  }

  if (bestId) {
    return bestId;
  }

  // Fallback to cyclic navigation if no spatial element exists in that direction
  if (cmd === 'DOWN' || cmd === 'RIGHT') {
    return registeredIds[(currentIndex + 1) % registeredIds.length] || currentId;
  } else {
    return registeredIds[(currentIndex - 1 + registeredIds.length) % registeredIds.length] || currentId;
  }
}

interface TVFocusProviderProps {
  children: React.ReactNode;
  defaultFocusId?: string;
  onGlobalCommand?: (cmd: RemoteCommand) => void;
}

export function TVFocusProvider({
  children,
  defaultFocusId = 'btn-primary-action',
  onGlobalCommand,
}: TVFocusProviderProps) {
  const [activeFocusId, setActiveFocusId] = useState<string>(defaultFocusId);
  const [lastCommand, setLastCommand] = useState<RemoteCommand | null>(null);
  const [commandCounter, setCommandCounter] = useState<number>(0);
  const [isAudioFeedbackEnabled, setIsAudioFeedbackEnabled] = useState<boolean>(true);
  const [reducedMotion] = useState<boolean>(false);

  const focusableIdsRef = useRef<Map<string, string>>(new Map());
  const lastKeyTimeRef = useRef<number>(0);

  const triggerRemoteCommand = useCallback(
    (cmd: RemoteCommand) => {
      setLastCommand(cmd);
      setCommandCounter((c) => c + 1);
      onGlobalCommand?.(cmd);

      if (cmd === 'UP' || cmd === 'DOWN' || cmd === 'LEFT' || cmd === 'RIGHT') {
        if (isAudioFeedbackEnabled) playTVSound('navigate');
      } else if (cmd === 'OK') {
        if (isAudioFeedbackEnabled) playTVSound('select');
      } else if (cmd === 'BACK') {
        if (isAudioFeedbackEnabled) playTVSound('back');
      } else if (cmd === 'BUZZ') {
        if (isAudioFeedbackEnabled) playTVSound('buzz');
      }

      const registered = Array.from(focusableIdsRef.current.keys());
      if (registered.length === 0) return;

      if (cmd === 'UP' || cmd === 'DOWN' || cmd === 'LEFT' || cmd === 'RIGHT') {
        const nextId = findNextSpatialFocusId(activeFocusId, cmd, registered);
        setActiveFocusId(nextId);
      } else if (cmd === 'OK') {
        const focusedEl = document.getElementById(activeFocusId);
        if (focusedEl) {
          focusedEl.click();
        }
      }
    },
    [activeFocusId, isAudioFeedbackEnabled, onGlobalCommand]
  );

  const registerFocusable = useCallback((id: string, group = 'default') => {
    focusableIdsRef.current.set(id, group);
    return () => {
      focusableIdsRef.current.delete(id);
    };
  }, []);

function isInputElementActive(e?: KeyboardEvent): boolean {
  if (typeof document === 'undefined') return false;
  if (e?.target && e.target instanceof HTMLElement) {
    const tag = e.target.tagName.toLowerCase();
    if (tag === 'input' || tag === 'textarea' || tag === 'select' || e.target.isContentEditable) {
      return true;
    }
  }
  const active = document.activeElement;
  if (active && active instanceof HTMLElement) {
    const tag = active.tagName.toLowerCase();
    if (tag === 'input' || tag === 'textarea' || tag === 'select' || active.isContentEditable) {
      return true;
    }
  }
  return false;
}

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // 1. NEVER intercept keys when user is typing in an input field
      if (isInputElementActive(e)) {
        return;
      }

      const now = Date.now();
      if (now - lastKeyTimeRef.current < 60) return;
      lastKeyTimeRef.current = now;

      let cmd: RemoteCommand | null = null;

      // 2. Map standard D-pad navigation and select/back keys ONLY (no arbitrary shortcuts)
      if (e.key === 'ArrowUp' || e.keyCode === 19 || e.keyCode === 38) {
        cmd = 'UP';
      } else if (e.key === 'ArrowDown' || e.keyCode === 20 || e.keyCode === 40) {
        cmd = 'DOWN';
      } else if (e.key === 'ArrowLeft' || e.keyCode === 21 || e.keyCode === 37) {
        cmd = 'LEFT';
      } else if (e.key === 'ArrowRight' || e.keyCode === 22 || e.keyCode === 39) {
        cmd = 'RIGHT';
      } else if (
        e.key === 'Enter' ||
        e.keyCode === 23 ||
        e.keyCode === 13
      ) {
        cmd = 'OK';
      } else if (
        e.key === 'Escape' ||
        e.key === 'GoBack' ||
        e.key === 'Back' ||
        e.keyCode === 4 ||
        e.keyCode === 27
      ) {
        cmd = 'BACK';
      }

      if (cmd) {
        e.preventDefault();
        triggerRemoteCommand(cmd);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [triggerRemoteCommand]);

  return (
    <TVFocusContext.Provider
      value={{
        activeFocusId,
        setActiveFocusId,
        registerFocusable,
        lastCommand,
        commandCounter,
        triggerRemoteCommand,
        isAudioFeedbackEnabled,
        toggleAudioFeedback: () => setIsAudioFeedbackEnabled((v) => !v),
        reducedMotion,
      }}
    >
      {children}
    </TVFocusContext.Provider>
  );
}

// -----------------------------------------------------------------------------
// Focusable TV Card / Button Wrapper Component
// -----------------------------------------------------------------------------

export interface TVFocusableProps extends React.HTMLAttributes<HTMLDivElement> {
  id: string;
  group?: string;
  isSelected?: boolean;
  onActivate?: () => void;
  className?: string;
  children?: React.ReactNode;
}

export function TVFocusable({
  id,
  group = 'default',
  isSelected = false,
  onActivate,
  className = '',
  children,
  ...props
}: TVFocusableProps) {
  const { activeFocusId, setActiveFocusId, registerFocusable } = useTVFocus();
  const isFocused = activeFocusId === id;

  useEffect(() => {
    return registerFocusable(id, group);
  }, [id, group, registerFocusable]);

  return (
    <div
      id={id}
      role="button"
      tabIndex={0}
      data-focused={isFocused ? 'true' : 'false'}
      onMouseEnter={() => setActiveFocusId(id)}
      onClick={() => {
        setActiveFocusId(id);
        onActivate?.();
      }}
      className={`relative cursor-pointer transition-all duration-200 select-none outline-none ${
        isFocused
          ? 'scale-[1.03] ring-4 ring-amber-400 ring-offset-2 ring-offset-black shadow-lg shadow-amber-400/40 z-20 brightness-110'
          : isSelected
          ? 'ring-2 ring-purple-500 z-10'
          : 'opacity-90 hover:opacity-100'
      } ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}

export default function TVFocusManager({
  children,
  onBack,
  onBuzz,
  defaultFocusId,
}: {
  children: React.ReactNode;
  onBack?: () => void;
  onBuzz?: () => void;
  defaultFocusId?: string;
}) {
  return (
    <TVFocusProvider
      defaultFocusId={defaultFocusId}
      onGlobalCommand={(cmd) => {
        if (cmd === 'BACK' && onBack) onBack();
        if (cmd === 'BUZZ' && onBuzz) onBuzz();
      }}
    >
      {children}
    </TVFocusProvider>
  );
}
