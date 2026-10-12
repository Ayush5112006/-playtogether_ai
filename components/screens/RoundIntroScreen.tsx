'use client';

// =============================================================================
// PlayTogether AI — Screen 11: Round Intro Screen
// Sets expectations, shows round number, category, active players, and start CTA.
// =============================================================================

import React, { useEffect } from 'react';
import { Play } from 'lucide-react';
import { TVFocusable, useTVFocus } from '../tv/TVFocusManager';
import { Player } from '@/lib/types';

export interface RoundIntroScreenProps {
  roundNumber?: number;
  totalRounds?: number;
  category?: string;
  difficulty?: string;
  players?: Player[];
  activePlayer?: Player;
  onStartRound: () => void;
}

export function RoundIntroScreen({
  roundNumber = 1,
  totalRounds = 5,
  category = 'Science & Cosmos',
  difficulty = 'Adaptive',
  players = [],
  activePlayer,
  onStartRound,
}: RoundIntroScreenProps) {
  const { setActiveFocusId } = useTVFocus();

  useEffect(() => {
    setActiveFocusId('roundintro-btn-start');
  }, [setActiveFocusId]);

  return (
    <div className="relative w-full h-full flex flex-col items-center justify-center select-none text-center animate-fadeIn text-white max-w-4xl mx-auto my-auto py-8">
      {/* Round Badge */}
      <div className="px-6 py-2 rounded-full bg-secondary/15 border border-secondary/40 text-secondary font-mono font-bold text-sm tracking-widest uppercase mb-4 shadow">
        ROUND {roundNumber}
      </div>

      {/* Category Headline */}
      <h1 className="font-space font-extrabold text-5xl md:text-6xl text-white tracking-tight mb-3 drop-shadow">
        {category}
      </h1>

      <p className="font-outfit text-xl text-primary font-medium mb-8">
        Difficulty Baseline: <strong className="text-white uppercase">{difficulty}</strong>
      </p>

      {/* Synced Player Tiles */}
      <div className="flex flex-wrap items-center justify-center gap-3 max-w-4xl mb-6 max-h-[160px] overflow-y-auto">
        {players.map((p) => {
          const color = p.color || p.accentColor || '#3b82f6';
          return (
            <div
              key={p.id}
              className="p-3 rounded-2xl bg-surface border border-outline-variant/60 shadow-xl flex flex-col items-center min-w-[105px]"
            >
              <div
                className="w-10 h-10 rounded-full flex items-center justify-center text-lg font-bold shadow-md mb-1 text-slate-950"
                style={{ backgroundColor: color }}
              >
                {p.avatar && p.avatar.length <= 2 ? p.avatar : p.name.charAt(0)}
              </div>
              <span className="font-space font-bold text-xs text-white truncate max-w-[95px]">{p.name}</span>
              <span className="text-[10px] font-mono text-secondary mt-0.5">{p.score} PTS</span>
            </div>
          );
        })}
      </div>

      {/* Start Button */}
      <TVFocusable
        id="roundintro-btn-start"
        group="roundintro"
        onActivate={onStartRound}
        className="flex items-center gap-3 px-12 py-5 rounded-2xl bg-gradient-to-r from-primary-container to-secondary text-slate-950 font-space font-bold text-xl tracking-wide shadow-2xl hover:brightness-110 active:scale-95 transition"
      >
        <span>START ROUND [OK]</span>
        <Play className="w-7 h-7 fill-slate-950" />
      </TVFocusable>
    </div>
  );
}

export default RoundIntroScreen;
