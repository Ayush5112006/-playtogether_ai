'use client';

// =============================================================================
// PlayTogether AI — Screen 1: Splash Screen
// Brand intro, pulsing AI core, tagline "One TV. Everyone Plays."
// =============================================================================

import React, { useEffect } from 'react';
import { AIObsorbOrb } from '../tv/AIObsorbOrb';

interface SplashScreenProps {
  onFinish: () => void;
}

export function SplashScreen({ onFinish }: SplashScreenProps) {
  useEffect(() => {
    const timer = setTimeout(() => {
      onFinish();
    }, 1800);

    const handleKey = (e: KeyboardEvent) => {
      if (e.key === 'Enter' || e.key === ' ' || e.key === 'ArrowRight') {
        onFinish();
      }
    };
    window.addEventListener('keydown', handleKey);

    return () => {
      clearTimeout(timer);
      window.removeEventListener('keydown', handleKey);
    };
  }, [onFinish]);

  return (
    <div
      onClick={onFinish}
      className="relative w-full h-full flex flex-col items-center justify-center select-none text-center animate-fadeIn cursor-pointer"
    >
      <div className="mb-8">
        <AIObsorbOrb size="hero" label="AI HOST" />
      </div>

      <h1 className="font-space font-extrabold text-5xl md:text-7xl text-white tracking-tight drop-shadow-2xl mb-4">
        PlayTogether <span className="text-secondary">AI</span>
      </h1>

      <div className="px-6 py-2 rounded-full bg-surface-high/80 border border-secondary/40 shadow-lg text-secondary font-mono text-sm tracking-wider uppercase animate-pulse">
        One TV. Everyone Plays.
      </div>

      <div className="absolute bottom-10 text-xs font-mono text-slate-500">
        Fire TV Living Room Experience • Press [OK] to Start
      </div>
    </div>
  );
}
