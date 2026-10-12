'use client';

import React, { useEffect, useRef } from 'react';
import { Crown, Flame, Sparkles, ArrowRight, Swords, ShieldCheck } from 'lucide-react';
import { playTVSound, TVFocusable, useTVFocus } from '@/components/tv/TVFocusManager';
import { Session, Player } from '@/lib/types';

interface FinalRoundScreenProps {
  session: Session;
  players: Player[];
  onStartFinalRound: () => void;
}

export default function FinalRoundScreen({
  session,
  players,
  onStartFinalRound,
}: FinalRoundScreenProps) {
  const { setActiveFocusId, lastCommand, commandCounter } = useTVFocus();
  const lastProcessedCmdRef = useRef<number>(0);

  useEffect(() => {
    setActiveFocusId('btn-enter-final');
    playTVSound('surprise');
  }, [setActiveFocusId]);

  // Remote OK command fallback
  useEffect(() => {
    if (commandCounter > lastProcessedCmdRef.current) {
      lastProcessedCmdRef.current = commandCounter;
      if (lastCommand === 'OK') {
        playTVSound('click');
        onStartFinalRound();
      }
    }
  }, [commandCounter, lastCommand, onStartFinalRound]);

  const topTwo = [...players].sort((a, b) => b.score - a.score).slice(0, 2);

  return (
    <div className="w-full h-full flex flex-col justify-between p-12 relative overflow-hidden bg-gradient-to-b from-purple-950/40 via-black to-black">
      {/* Dynamic ambient lights */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-96 h-96 bg-amber-500/10 rounded-full blur-3xl pointer-events-none" />

      {/* Top Banner */}
      <div className="flex items-center justify-between z-10">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-amber-400/20 border border-amber-400/50 flex items-center justify-center shadow-lg shadow-amber-400/30">
            <Crown className="w-8 h-8 text-amber-300 animate-bounce" />
          </div>
          <div>
            <span className="text-xs font-mono uppercase tracking-widest text-amber-400 flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5" /> ULTIMATE DECIDER
            </span>
            <h1 className="text-4xl font-black text-white tracking-tight">The Final Showdown</h1>
          </div>
        </div>

        <div className="flex items-center gap-2 bg-gradient-to-r from-purple-500/30 to-amber-500/30 border border-amber-400/40 px-5 py-3 rounded-2xl">
          <Flame className="w-5 h-5 text-amber-400 fill-amber-400" />
          <span className="text-sm font-black text-amber-300 font-mono">+500 BONUS STAKES</span>
        </div>
      </div>

      {/* Center Matchup Stage */}
      <div className="max-w-4xl mx-auto w-full my-auto text-center space-y-8 z-10">
        <div className="inline-flex items-center gap-2 px-6 py-2 rounded-full bg-white/5 border border-white/10 text-amber-400 font-mono text-sm uppercase tracking-widest">
          <Swords className="w-4 h-4" /> ONE QUESTION REMAINS
        </div>

        <h2 className="text-6xl font-black text-white tracking-tight leading-none">
          Double Point Stakes.<br />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-300 via-orange-400 to-amber-500">
            Winner Takes The Crown.
          </span>
        </h2>

        {/* Head-to-Head Top Contenders */}
        {topTwo.length >= 2 && (
          <div className="flex items-center justify-center gap-8 pt-4">
            <div className="p-6 rounded-3xl bg-white/5 border border-amber-400/30 flex items-center gap-4">
              <div
                className="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl font-bold"
                style={{ backgroundColor: `${topTwo[0].color}25`, border: `2px solid ${topTwo[0].color}` }}
              >
                <span style={{ color: topTwo[0].color }}>{topTwo[0].avatar}</span>
              </div>
              <div className="text-left">
                <span className="text-xl font-black text-white block">{topTwo[0].name}</span>
                <span className="text-amber-400 font-mono font-bold">{topTwo[0].score} pts</span>
              </div>
            </div>

            <div className="text-2xl font-black text-white/30 italic">VS</div>

            <div className="p-6 rounded-3xl bg-white/5 border border-purple-400/30 flex items-center gap-4">
              <div
                className="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl font-bold"
                style={{ backgroundColor: `${topTwo[1].color}25`, border: `2px solid ${topTwo[1].color}` }}
              >
                <span style={{ color: topTwo[1].color }}>{topTwo[1].avatar}</span>
              </div>
              <div className="text-left">
                <span className="text-xl font-black text-white block">{topTwo[1].name}</span>
                <span className="text-purple-400 font-mono font-bold">{topTwo[1].score} pts</span>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Action Footer */}
      <div className="flex items-center justify-between border-t border-white/10 pt-6 z-10">
        <div className="flex items-center gap-2 text-white/50 text-sm font-mono">
          <ShieldCheck className="w-4 h-4 text-emerald-400" />
          <span>SPEED BONUSES DOUBLED (UP TO +100 PTS)</span>
        </div>

        <TVFocusable
          id="btn-enter-final"
          group="final-actions"
          onActivate={() => {
            playTVSound('click');
            onStartFinalRound();
          }}
          className="flex items-center gap-3 px-10 py-5 rounded-2xl bg-gradient-to-r from-amber-400 via-orange-500 to-amber-500 text-black font-black text-2xl hover:scale-105 active:scale-95 transition-all shadow-2xl shadow-amber-500/40 cursor-pointer"
        >
          <span>ENTER FINAL ROUND</span>
          <ArrowRight className="w-7 h-7" />
          <span className="text-xs px-2.5 py-1 rounded bg-black/20 text-black/80 font-mono">OK</span>
        </TVFocusable>
      </div>
    </div>
  );
}
