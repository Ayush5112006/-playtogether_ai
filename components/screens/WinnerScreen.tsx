'use client';

import React, { useEffect } from 'react';
import confetti from 'canvas-confetti';
import { Trophy, Crown, Sparkles, ArrowRight, RotateCcw, Home, Flame, Star } from 'lucide-react';
import { playTVSound, TVFocusable, useTVFocus } from '@/components/tv/TVFocusManager';
import { Player, Session } from '@/lib/types';

interface WinnerScreenProps {
  session: Session;
  players: Player[];
  onShowRecap: () => void;
  onPlayAgain: () => void;
  onReturnHome: () => void;
}

export default function WinnerScreen({
  session,
  players,
  onShowRecap,
  onPlayAgain,
  onReturnHome,
}: WinnerScreenProps) {
  const { setActiveFocusId } = useTVFocus();

  // Sort players descending
  const sorted = [...players].sort((a, b) => b.score - a.score);
  const winner = sorted[0];
  const second = sorted[1];
  const third = sorted[2];

  useEffect(() => {
    setActiveFocusId('btn-view-recap');
    playTVSound('winner');

    // Multi-burst canvas-confetti celebration
    const end = Date.now() + 3000;
    const colors = ['#f59e0b', '#ec4899', '#8b5cf6', '#10b981', '#ffffff'];

    const frame = () => {
      confetti({
        particleCount: 5,
        angle: 60,
        spread: 55,
        origin: { x: 0 },
        colors,
      });
      confetti({
        particleCount: 5,
        angle: 120,
        spread: 55,
        origin: { x: 1 },
        colors,
      });

      if (Date.now() < end) {
        requestAnimationFrame(frame);
      }
    };
    frame();
  }, []);

  return (
    <div className="w-full h-full flex flex-col justify-between p-12 relative overflow-hidden">
      {/* Background celebration glow */}
      <div className="absolute inset-0 bg-radial-gradient from-amber-500/20 via-transparent to-transparent pointer-events-none" />

      {/* Top Banner */}
      <div className="flex items-center justify-between z-10">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-amber-400/20 border border-amber-400/50 flex items-center justify-center shadow-lg shadow-amber-400/30">
            <Trophy className="w-8 h-8 text-amber-300 animate-bounce" />
          </div>
          <div>
            <span className="text-xs font-mono uppercase tracking-widest text-amber-400 flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5" /> MATCH CONCLUDED
            </span>
            <h1 className="text-4xl font-black text-white tracking-tight">Family Champion Crowned!</h1>
          </div>
        </div>

        <div className="flex items-center gap-2 bg-amber-400/10 border border-amber-400/30 px-5 py-2.5 rounded-2xl text-amber-300 font-mono text-sm font-bold">
          <Star className="w-4 h-4 fill-amber-300" />
          <span>MATCH WINNER: {winner?.name || 'CHAMPION'}</span>
        </div>
      </div>

      {/* 3-Tier Podium */}
      <div className="flex items-end justify-center gap-6 max-w-4xl mx-auto w-full my-auto z-10 pt-8">
        {/* 2nd Place */}
        {second && (
          <div className="flex flex-col items-center flex-1 max-w-[220px]">
            <div
              className="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl font-black mb-3 shadow-lg"
              style={{ backgroundColor: `${second.color}30`, border: `2px solid ${second.color}` }}
            >
              <span style={{ color: second.color }}>{second.avatar}</span>
            </div>
            <span className="font-bold text-white text-lg">{second.name}</span>
            <span className="text-sm font-mono text-white/60 mb-2">{second.score.toLocaleString()} pts</span>
            <div className="w-full h-36 bg-gradient-to-t from-slate-800 to-slate-700/80 rounded-t-3xl border-t-4 border-slate-400 flex flex-col items-center justify-center shadow-xl">
              <span className="text-4xl font-black text-slate-300 font-mono">2ND</span>
            </div>
          </div>
        )}

        {/* 1st Place Champion */}
        {winner && (
          <div className="flex flex-col items-center flex-1 max-w-[260px] relative">
            <div className="absolute -top-10 text-amber-400 animate-bounce">
              <Crown className="w-10 h-10 fill-amber-400" />
            </div>
            <div
              className="w-24 h-24 rounded-3xl flex items-center justify-center text-5xl font-black mb-3 shadow-2xl ring-4 ring-amber-400/60"
              style={{ backgroundColor: `${winner.color}40`, border: `3px solid ${winner.color}` }}
            >
              <span style={{ color: winner.color }}>{winner.avatar}</span>
            </div>
            <span className="font-black text-white text-2xl tracking-wide">{winner.name}</span>
            <span className="text-lg font-mono font-black text-amber-300 mb-2">
              {winner.score.toLocaleString()} pts
            </span>
            <div className="w-full h-52 bg-gradient-to-t from-amber-600/80 to-amber-500 rounded-t-3xl border-t-4 border-amber-300 flex flex-col items-center justify-center shadow-2xl shadow-amber-500/30">
              <span className="text-5xl font-black text-black font-mono">1ST</span>
              <span className="text-xs font-black tracking-widest text-black/80 uppercase">CHAMPION</span>
            </div>
          </div>
        )}

        {/* 3rd Place */}
        {third && (
          <div className="flex flex-col items-center flex-1 max-w-[220px]">
            <div
              className="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl font-black mb-3 shadow-lg"
              style={{ backgroundColor: `${third.color}30`, border: `2px solid ${third.color}` }}
            >
              <span style={{ color: third.color }}>{third.avatar}</span>
            </div>
            <span className="font-bold text-white text-lg">{third.name}</span>
            <span className="text-sm font-mono text-white/60 mb-2">{third.score.toLocaleString()} pts</span>
            <div className="w-full h-24 bg-gradient-to-t from-amber-950 to-amber-900/80 rounded-t-3xl border-t-4 border-amber-700 flex flex-col items-center justify-center shadow-xl">
              <span className="text-3xl font-black text-amber-600 font-mono">3RD</span>
            </div>
          </div>
        )}
      </div>

      {/* Action Footer */}
      <div className="flex items-center justify-between border-t border-white/10 pt-6 z-10">
        <div className="flex items-center gap-3">
          <TVFocusable
            id="btn-play-again"
            group="winner-actions"
            onActivate={() => {
              playTVSound('click');
              onPlayAgain();
            }}
            className="flex items-center gap-2 px-6 py-3.5 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-bold border border-white/20 transition-all text-base cursor-pointer"
          >
            <RotateCcw className="w-5 h-5 text-amber-400" />
            <span>PLAY AGAIN</span>
          </TVFocusable>

          <TVFocusable
            id="btn-winner-home"
            group="winner-actions"
            onActivate={() => {
              playTVSound('click');
              onReturnHome();
            }}
            className="flex items-center gap-2 px-6 py-3.5 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-bold border border-white/20 transition-all text-base cursor-pointer"
          >
            <Home className="w-5 h-5 text-purple-400" />
            <span>HOME</span>
          </TVFocusable>
        </div>

        <TVFocusable
          id="btn-view-recap"
          group="winner-actions"
          onActivate={() => {
            playTVSound('click');
            onShowRecap();
          }}
          className="flex items-center gap-3 px-10 py-5 rounded-2xl bg-gradient-to-r from-amber-400 via-orange-500 to-amber-500 text-black font-black text-2xl hover:scale-105 active:scale-95 transition-all shadow-xl shadow-amber-400/40 cursor-pointer"
        >
          <span>VIEW AI RECAP</span>
          <ArrowRight className="w-7 h-7" />
          <span className="text-xs px-2.5 py-1 rounded bg-black/20 text-black/80 font-mono">OK</span>
        </TVFocusable>
      </div>
    </div>
  );
}
