'use client';

// =============================================================================
// PlayTogether AI — Sofa-Friendly Shared Bottom HUD
// Remote shortcuts legend, voice trigger, leave room, audio settings.
// =============================================================================

import React from 'react';
import { Volume2, Sliders, LogOut } from 'lucide-react';
import { useTVFocus } from './TVFocusManager';

export interface SharedBottomHudProps {
  currentScreen?: any;
  onOkPress?: () => void;
  onBackPress?: () => void;
  onMicPress?: () => void;
  onBuzzPress?: () => void;
  onLeaveRoom?: () => void;
  onSettingsTap?: () => void;
  onAccountTap?: () => void;
  hostCode?: string;
}

export function SharedBottomHud({
  currentScreen,
  onOkPress,
  onBackPress,
  onMicPress,
  onBuzzPress,
  onLeaveRoom,
  onSettingsTap,
  onAccountTap,
  hostCode = '8942',
}: SharedBottomHudProps) {
  const { triggerRemoteCommand } = useTVFocus();

  const handleBuzz = () => {
    if (onBuzzPress) {
      onBuzzPress();
    } else {
      triggerRemoteCommand('BUZZ');
    }
  };

  return (
    <footer className="relative z-30 flex items-center justify-between px-10 py-3 bg-background/90 backdrop-blur-md border-t border-outline-variant/40 text-xs font-mono select-none text-slate-300">
      {/* 1. Left Key Legends */}
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-1.5">
          <span className="px-2 py-0.5 rounded bg-amber-500/20 border border-amber-400/40 text-amber-300 font-bold">
            ▲▼◀▶
          </span>
          <span className="text-slate-400">Navigate</span>
        </div>

        <button
          onClick={onOkPress ? onOkPress : () => triggerRemoteCommand('OK')}
          className="flex items-center gap-1.5 hover:text-white transition cursor-pointer"
        >
          <span className="px-2 py-0.5 rounded bg-cyan-500/20 border border-cyan-400/40 text-cyan-300 font-bold">
            [OK]
          </span>
          <span className="text-slate-300">Select</span>
        </button>

        <button
          onClick={onMicPress}
          className="flex items-center gap-1.5 hover:text-purple-300 transition cursor-pointer"
        >
          <span className="px-2 py-0.5 rounded bg-purple-500/20 border border-purple-400/40 text-purple-300 font-bold">
            [MIC]
          </span>
          <span className="text-slate-300">Voice Input</span>
        </button>

        <button
          onClick={onBackPress ? onBackPress : () => triggerRemoteCommand('BACK')}
          className="flex items-center gap-1.5 hover:text-pink-300 transition cursor-pointer"
        >
          <span className="px-2 py-0.5 rounded bg-pink-500/20 border border-pink-400/40 text-pink-300 font-bold">
            [BACK]
          </span>
          <span className="text-slate-300">Return</span>
        </button>

        {(currentScreen === 'GAMEPLAY' || currentScreen === 'SURPRISE_ROUND') && (
          <button
            onClick={handleBuzz}
            className="flex items-center gap-1.5 hover:text-amber-200 transition text-amber-300 animate-pulse"
          >
            <span className="px-2.5 py-0.5 rounded bg-amber-500/25 border border-amber-400/60 font-bold flex items-center gap-1">
              ⚡ Buzz In
            </span>
          </button>
        )}
      </div>

      {/* 2. Right Quick Actions */}
      <div className="flex items-center gap-5">
        <button
          onClick={onLeaveRoom}
          className="flex items-center gap-1 text-slate-400 hover:text-rose-400 transition"
        >
          <LogOut className="w-3.5 h-3.5" />
          <span>Leave Room</span>
        </button>

        <button
          onClick={onSettingsTap}
          className="flex items-center gap-1.5 text-slate-400 hover:text-secondary transition"
        >
          <Sliders className="w-3.5 h-3.5 text-secondary" />
          <span>Audio & Game Settings</span>
        </button>

        <button
          onClick={onAccountTap}
          className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-surface-high border border-outline-variant/60 text-slate-300 hover:border-secondary transition"
        >
          <Volume2 className="w-3.5 h-3.5 text-cyan-400" />
          <span>Host Code: <strong className="text-white">{hostCode}</strong></span>
        </button>
      </div>
    </footer>
  );
}

export default SharedBottomHud;
