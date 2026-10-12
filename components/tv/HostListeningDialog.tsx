'use client';

// =============================================================================
// PlayTogether AI — Host Listening Voice Synthesis Modal
// TV remote microphone command emulator with waveform visualizer and quick controls.
// =============================================================================

import React, { useState } from 'react';
import { Mic, X, Radio, Sparkles } from 'lucide-react';
import { TVFocusable } from './TVFocusManager';
import { Player } from '@/lib/types';

export interface HostListeningDialogProps {
  isOpen: boolean;
  onClose: () => void;
  players?: Player[];
  currentCategory?: string;
  currentDifficulty?: string;
  onSelectCategory?: (category: string) => void;
  onSelectDifficulty?: (difficulty: string) => void;
  onLaunchGame?: () => void;
  onTriggerSurprise?: () => void;
  onSimulateCommand?: (cmdText: string) => void;
}

export function HostListeningDialog({
  isOpen,
  onClose,
  players = [],
  currentCategory = 'Science & Cosmos',
  currentDifficulty = 'Adaptive',
  onSelectCategory,
  onSelectDifficulty,
  onLaunchGame,
  onTriggerSurprise,
  onSimulateCommand,
}: HostListeningDialogProps) {
  const [responseMsg, setResponseMsg] = useState<string>(
    "I'm listening! Speak into your Fire TV remote or select a command below."
  );

  if (!isOpen) return null;

  const quickCommands = [
    {
      label: '▶ Launch Quiz Now',
      action: () => {
        setResponseMsg('Launching match now!');
        setTimeout(() => {
          onLaunchGame?.();
          onClose();
        }, 500);
      },
    },
    {
      label: '🎬 Play Cinema Clues',
      action: () => {
        onSelectCategory?.('Cinema Clues');
        setResponseMsg('Category switched to Cinema Clues!');
      },
    },
    {
      label: '🚀 Play Science & Cosmos',
      action: () => {
        onSelectCategory?.('Science & Cosmos');
        setResponseMsg('Category switched to Science & Cosmos!');
      },
    },
    {
      label: '⚡ Surprise Buzzer Blitz',
      action: () => {
        setResponseMsg('Surprise Buzzer Blitz armed!');
        setTimeout(() => {
          onTriggerSurprise?.();
          onClose();
        }, 500);
      },
    },
    {
      label: '📈 Shift to Hard Mode',
      action: () => {
        onSelectDifficulty?.('HARD');
        setResponseMsg('Difficulty upgraded to HARD!');
      },
    },
    {
      label: '📉 Shift to Easy Mode',
      action: () => {
        onSelectDifficulty?.('EASY');
        setResponseMsg('Difficulty set to EASY mode.');
      },
    },
    {
      label: '🏆 Who is winning?',
      action: () => {
        const sorted = [...players].sort((a, b) => b.score - a.score);
        const leader = sorted[0];
        setResponseMsg(
          leader
            ? `${leader.name} is leading with ${leader.score} PTS on a ${leader.streak}x streak!`
            : 'All players are currently tied!'
        );
      },
    },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-md p-6 select-none animate-fadeIn">
      <div className="w-full max-w-2xl bg-surface-low rounded-3xl border border-secondary/50 shadow-2xl p-8 text-white relative">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-6 right-6 p-2 rounded-xl text-slate-400 hover:text-white hover:bg-surface-high transition"
          aria-label="Close"
        >
          <X className="w-6 h-6" />
        </button>

        {/* AI Voice Header & Waveform */}
        <div className="flex flex-col items-center text-center mb-6">
          <div className="relative mb-4">
            <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-purple-600 to-cyan-400 flex items-center justify-center shadow-lg shadow-purple-500/40 animate-pulse">
              <Mic className="w-10 h-10 text-white" />
            </div>
            <div className="absolute -inset-2 rounded-full border-2 border-cyan-400/50 animate-ping opacity-40 pointer-events-none" />
          </div>

          <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-surface-high border border-outline-variant/60 text-xs font-mono text-cyan-300 mb-2">
            <Radio className="w-3.5 h-3.5 text-rose-400 animate-pulse" />
            <span>CORTEX-9 VOCAL SYNTHESIS LISTENING</span>
          </div>

          <h2 className="font-space font-bold text-2xl text-white mb-2">
            Say something to CORTEX-9
          </h2>
          <p className="text-secondary font-medium text-sm max-w-lg bg-surface-high/60 px-4 py-2.5 rounded-xl border border-secondary/30">
            {responseMsg}
          </p>
        </div>

        {/* Quick Voice Commands Grid */}
        <div className="space-y-2">
          <div className="text-xs font-mono text-slate-400 flex items-center gap-1.5 px-1 mb-1">
            <Sparkles className="w-3.5 h-3.5 text-amber-400" />
            <span>Living Room Quick Voice Commands:</span>
          </div>

          <div className="grid grid-cols-2 gap-2.5">
            {quickCommands.map((cmd, idx) => (
              <TVFocusable
                key={idx}
                id={`voice-cmd-${idx}`}
                group="voice-dialog"
                onActivate={cmd.action}
                className="px-4 py-3 rounded-xl bg-surface border border-outline-variant/50 hover:border-secondary hover:bg-surface-high text-sm font-medium text-slate-200 transition text-left"
              >
                {cmd.label}
              </TVFocusable>
            ))}
          </div>
        </div>

        {/* Dismiss Button */}
        <div className="mt-6 pt-4 border-t border-slate-800 flex justify-center">
          <TVFocusable
            id="voice-dialog-close"
            group="voice-dialog"
            onActivate={onClose}
            className="px-6 py-2.5 rounded-xl bg-surface-high border border-outline-variant text-slate-300 text-xs font-mono hover:text-white"
          >
            Done / Close [BACK]
          </TVFocusable>
        </div>
      </div>
    </div>
  );
}

export default HostListeningDialog;
