'use client';

import React from 'react';
import { Cpu, Sparkles } from 'lucide-react';

export interface AIObsorbOrbProps {
  label?: string;
  size?: 'sm' | 'md' | 'lg' | 'hero';
  isListening?: boolean;
  state?: 'idle' | 'listening' | 'thinking' | 'speaking';
}

export function AIObsorbOrb({
  label = 'CORTEX-9',
  size = 'md',
  isListening = false,
  state = 'idle',
}: AIObsorbOrbProps) {
  const sizeMap = {
    sm: 'w-16 h-16 text-xs',
    md: 'w-24 h-24 text-sm',
    lg: 'w-36 h-36 text-base',
    hero: 'w-48 h-48 text-lg',
  };

  const orbSize = sizeMap[size];
  const activePulse = isListening || state === 'listening' || state === 'thinking';

  return (
    <div className="relative flex flex-col items-center justify-center select-none">
      {/* Outer ripple rings */}
      <div
        className={`absolute rounded-full border border-purple-400/30 animate-ping opacity-30 ${
          size === 'hero' ? 'w-64 h-64' : 'w-36 h-36'
        }`}
        style={{ animationDuration: activePulse ? '1.2s' : '3.5s' }}
      />
      <div
        className={`absolute rounded-full border border-amber-400/20 animate-pulse ${
          size === 'hero' ? 'w-56 h-56' : 'w-32 h-32'
        }`}
        style={{ animationDuration: '2.5s' }}
      />

      {/* Main holographic orb body */}
      <div
        className={`relative ${orbSize} rounded-full flex items-center justify-center bg-gradient-to-tr from-purple-700 via-indigo-600 to-amber-500 shadow-xl transition-all duration-300 ${
          activePulse
            ? 'shadow-purple-500/60 scale-105'
            : 'shadow-purple-900/40 hover:scale-102'
        }`}
      >
        <div className="absolute inset-1 rounded-full bg-gradient-to-b from-white/20 via-transparent to-black/40 pointer-events-none" />
        <div className="flex flex-col items-center justify-center gap-1">
          <Cpu className="w-8 h-8 text-white drop-shadow-md animate-pulse" />
        </div>
      </div>

      {/* Floating badge */}
      {label && (
        <div className="mt-3 flex items-center gap-1.5 px-3 py-1 rounded-full bg-purple-950/80 border border-purple-400/40 text-purple-200 text-xs font-mono font-bold tracking-widest shadow-md">
          <Sparkles className="w-3 h-3 text-amber-300" />
          <span>{label}</span>
        </div>
      )}
    </div>
  );
}

export default AIObsorbOrb;
