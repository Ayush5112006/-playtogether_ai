'use client';

import React, { useEffect, useState, useRef } from 'react';
import { Cpu, Zap, Sparkles, ArrowRight, ShieldAlert, Award, Volume2 } from 'lucide-react';
import AIObsorbOrb from '@/components/tv/AIObsorbOrb';
import { playTVSound, TVFocusable, useTVFocus } from '@/components/tv/TVFocusManager';
import { Session, Player } from '@/lib/types';

interface AiAdaptationScreenProps {
  session: Session;
  players: Player[];
  reason?: string;
  adjustmentDetails?: {
    playerHandicaps?: { playerName: string; change: string }[];
    pacing?: string;
    nextRoundType?: string;
  };
  onContinue: () => void;
}

export default function AiAdaptationScreen({
  session,
  players,
  reason = 'Dynamic Player Synergy & Performance Rebalancing',
  adjustmentDetails,
  onContinue,
}: AiAdaptationScreenProps) {
  const { setActiveFocusId, lastCommand, commandCounter } = useTVFocus();
  const [countdown, setCountdown] = useState(6);
  const lastProcessedCmdRef = useRef<number>(0);

  useEffect(() => {
    setActiveFocusId('btn-adapt-continue');
  }, [setActiveFocusId]);

  // Remote OK listener
  useEffect(() => {
    if (commandCounter > lastProcessedCmdRef.current) {
      lastProcessedCmdRef.current = commandCounter;
      if (lastCommand === 'OK') {
        playTVSound('click');
        onContinue();
      }
    }
  }, [commandCounter, lastCommand, onContinue]);

  useEffect(() => {
    playTVSound('ai');
    const timer = setInterval(() => {
      setCountdown((c) => {
        if (c <= 1) {
          clearInterval(timer);
          onContinue();
          return 0;
        }
        return c - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [onContinue]);

  return (
    <div className="w-full h-full flex flex-col justify-between p-12 relative overflow-hidden">
      {/* Background radial glow */}
      <div className="absolute inset-0 bg-radial-gradient from-purple-900/30 via-transparent to-transparent pointer-events-none" />

      {/* Top Banner */}
      <div className="flex items-center justify-between z-10">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-purple-500/20 border border-purple-400/50 flex items-center justify-center shadow-lg shadow-purple-500/30">
            <Cpu className="w-8 h-8 text-purple-300 animate-pulse" />
          </div>
          <div>
            <span className="text-xs font-mono uppercase tracking-widest text-purple-400 flex items-center gap-2">
              <Sparkles className="w-3.5 h-3.5" /> AI GAME MASTER
            </span>
            <h1 className="text-4xl font-black text-white tracking-tight">Adaptive Difficulty Updated</h1>
          </div>
        </div>

        <div className="flex items-center gap-3 bg-purple-950/40 border border-purple-500/30 rounded-2xl px-5 py-3">
          <span className="text-sm text-purple-200/70">Resuming match in</span>
          <span className="text-2xl font-black text-purple-300 font-mono w-8 text-center">{countdown}s</span>
        </div>
      </div>

      {/* Center AI Visualization */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center max-w-6xl mx-auto w-full my-auto z-10">
        {/* Left Orb Column */}
        <div className="lg:col-span-4 flex flex-col items-center text-center">
          <div className="relative">
            <AIObsorbOrb size="lg" state="thinking" />
            <div className="absolute -inset-4 rounded-full border border-purple-500/30 animate-ping pointer-events-none opacity-20" />
          </div>
          <div className="mt-6 flex items-center gap-2 px-4 py-1.5 rounded-full bg-purple-500/10 border border-purple-500/30 text-purple-300 text-xs font-mono">
            <Volume2 className="w-4 h-4 animate-bounce" />
            <span>ADAPTING DIFFICULTY LEVEL</span>
          </div>

          <div className="mt-4 flex items-center gap-3 bg-purple-950/70 border border-purple-400/40 px-4 py-2 rounded-2xl">
            <span className="text-xs font-mono text-purple-300">DIFFICULTY:</span>
            <span className="text-sm font-black text-amber-300 font-mono">MEDIUM</span>
            <span className="text-purple-400">➔</span>
            <span className="text-sm font-black text-emerald-400 font-mono">HARD</span>
          </div>
        </div>

        {/* Right Info Column */}
        <div className="lg:col-span-8 space-y-4">
          <div className="p-6 rounded-3xl bg-purple-950/30 border border-purple-500/30 backdrop-blur-md">
            <span className="text-xs font-mono text-purple-400 uppercase tracking-widest block mb-1">
              Game Master Rationale
            </span>
            <p className="text-2xl font-bold text-white leading-snug">
              &ldquo;{reason}&rdquo;
            </p>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="p-5 rounded-2xl bg-white/5 border border-white/10">
              <div className="flex items-center gap-2 text-amber-400 font-bold mb-2">
                <Zap className="w-5 h-5" />
                <span className="text-sm uppercase tracking-wider">Dynamic Pacing</span>
              </div>
              <p className="text-white/80 text-sm">
                Next questions scaled up to HARD to challenge lead players, while keeping bonus streaks accessible.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-white/5 border border-white/10">
              <div className="flex items-center gap-2 text-emerald-400 font-bold mb-2">
                <Award className="w-5 h-5" />
                <span className="text-sm uppercase tracking-wider">Underdog Assistance</span>
              </div>
              <p className="text-white/80 text-sm">
                Relaxed timer and 50/50 lifeline options prioritized for players trailing in points.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Action Footer */}
      <div className="flex items-center justify-between border-t border-purple-500/20 pt-6 z-10">
        <div className="flex items-center gap-2 text-purple-300/60 text-sm font-mono">
          <ShieldAlert className="w-4 h-4 text-purple-400" />
          <span>REAL-TIME BALANCED FAIR PLAY ACTIVE</span>
        </div>

        <TVFocusable
          id="btn-adapt-continue"
          group="adapt-actions"
          onActivate={() => {
            playTVSound('click');
            onContinue();
          }}
          className="flex items-center gap-3 px-8 py-4 rounded-2xl bg-gradient-to-r from-purple-600 to-indigo-600 text-white font-black text-xl hover:scale-105 active:scale-95 transition-all shadow-xl shadow-purple-600/40 cursor-pointer"
        >
          <span>ACCEPT & RESUME</span>
          <ArrowRight className="w-6 h-6" />
          <span className="text-xs px-2 py-0.5 rounded bg-white/20 text-white font-mono">OK</span>
        </TVFocusable>
      </div>
    </div>
  );
}
