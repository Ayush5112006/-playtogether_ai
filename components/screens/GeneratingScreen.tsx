'use client';

// =============================================================================
// PlayTogether AI — Screen 10: AI Match Creation / Loading Screen
// CORTEX-9 match synthesis telemetry, round stack generation, progress indicator.
// =============================================================================

import React, { useEffect, useState } from 'react';
import { Sparkles, Check, Database, Brain, Cpu } from 'lucide-react';
import { AIObsorbOrb } from '../tv/AIObsorbOrb';

export interface GeneratingScreenProps {
  category?: string;
  difficulty?: string;
  mode?: string;
  playerCount?: number;
  onFinish?: () => void;
}

export function GeneratingScreen({
  category = 'Science & Cosmos',
  difficulty = 'Adaptive',
  mode = 'family-adaptive',
  playerCount = 4,
  onFinish,
}: GeneratingScreenProps) {
  const [progressStep, setProgressStep] = useState<number>(0);

  const steps = [
    { label: 'Connecting to Supabase Question Bank', icon: Database },
    { label: `Synthesizing ${category} Master Deck (${difficulty})`, icon: Brain },
    { label: 'Balancing Living Room Handicap & Buzzer Weights', icon: Cpu },
    { label: 'Match Matrix Ready! Deploying Round 1...', icon: Sparkles },
  ];

  useEffect(() => {
    const timer1 = setTimeout(() => setProgressStep(1), 600);
    const timer2 = setTimeout(() => setProgressStep(2), 1200);
    const timer3 = setTimeout(() => setProgressStep(3), 1800);
    const timer4 = setTimeout(() => onFinish?.(), 2400);

    return () => {
      clearTimeout(timer1);
      clearTimeout(timer2);
      clearTimeout(timer3);
      clearTimeout(timer4);
    };
  }, [onFinish]);

  return (
    <div className="relative w-full h-full flex flex-col items-center justify-center select-none animate-fadeIn text-white text-center max-w-xl mx-auto">
      <div className="mb-6">
        <AIObsorbOrb size="lg" label="CORTEX-9" isListening={true} />
      </div>

      <h2 className="font-space font-bold text-3xl text-white mb-2">
        Synthesizing Tonight’s Match
      </h2>
      <p className="font-outfit text-sm text-slate-400 mb-8">
        CORTEX-9 is tailoring questions and timer rules for the room...
      </p>

      {/* Progress Stack */}
      <div className="w-full space-y-3 text-left">
        {steps.map((st, idx) => {
          const isDone = progressStep > idx;
          const isCurrent = progressStep === idx;
          const StepIcon = st.icon;

          return (
            <div
              key={idx}
              className={`p-3.5 rounded-2xl border transition-all flex items-center justify-between ${
                isDone
                  ? 'bg-surface border-emerald-500/50 text-emerald-300'
                  : isCurrent
                  ? 'bg-surface border-secondary shadow-tv-focus text-white'
                  : 'bg-surface/40 border-outline-variant/30 text-slate-500'
              }`}
            >
              <div className="flex items-center gap-3">
                <StepIcon className={`w-5 h-5 ${isCurrent ? 'animate-pulse text-cyan-300' : ''}`} />
                <span className="font-space text-xs font-semibold">{st.label}</span>
              </div>

              {isDone ? (
                <Check className="w-4 h-4 text-emerald-400" />
              ) : isCurrent ? (
                <div className="w-2.5 h-2.5 rounded-full bg-secondary animate-ping" />
              ) : null}
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default GeneratingScreen;
