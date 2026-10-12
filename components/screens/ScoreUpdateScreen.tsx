'use client';

import React, { useEffect, useState, useRef } from 'react';
import { Trophy, Flame, Zap, ArrowRight, ShieldCheck, Crown } from 'lucide-react';
import { Player, Session } from '@/lib/types';
import { playTVSound, TVFocusable, useTVFocus } from '@/components/tv/TVFocusManager';

interface ScoreUpdateScreenProps {
  session: Session;
  players: Player[];
  lastScoredPlayerId?: string | null;
  lastPointsEarned?: number;
  streakPlayerId?: string | null;
  onContinue: () => void;
}

export default function ScoreUpdateScreen({
  session,
  players,
  lastScoredPlayerId,
  lastPointsEarned = 0,
  onContinue,
}: ScoreUpdateScreenProps) {
  const { setActiveFocusId, lastCommand, commandCounter } = useTVFocus();
  const [countdown, setCountdown] = useState(6);
  const lastProcessedCmdRef = useRef<number>(0);

  // Sort players descending by score
  const sortedPlayers = [...players].sort((a, b) => b.score - a.score);

  useEffect(() => {
    setActiveFocusId('btn-continue');
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
    playTVSound('correct');
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

  const getRankBadge = (index: number) => {
    if (index === 0) return <div className="w-8 h-8 rounded-full bg-amber-400 text-black flex items-center justify-center font-black shadow-lg shadow-amber-400/40"><Crown className="w-5 h-5" /></div>;
    if (index === 1) return <div className="w-8 h-8 rounded-full bg-slate-300 text-black flex items-center justify-center font-bold">2</div>;
    if (index === 2) return <div className="w-8 h-8 rounded-full bg-amber-700 text-white flex items-center justify-center font-bold">3</div>;
    return <div className="w-8 h-8 rounded-full bg-white/10 text-white/70 flex items-center justify-center font-bold">{index + 1}</div>;
  };

  return (
    <div className="w-full h-full flex flex-col justify-between p-12">
      {/* Top Banner */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-amber-400/20 border border-amber-400/50 flex items-center justify-center shadow-lg shadow-amber-400/20">
            <Trophy className="w-8 h-8 text-amber-300" />
          </div>
          <div>
            <span className="text-xs font-mono uppercase tracking-widest text-amber-400">LEADERBOARD UPDATE</span>
            <h1 className="text-4xl font-black text-white tracking-tight">Round Standings</h1>
          </div>
        </div>

        <div className="flex items-center gap-3 bg-white/5 border border-white/10 rounded-2xl px-5 py-3">
          <span className="text-sm text-white/60">Auto-advancing in</span>
          <span className="text-2xl font-black text-amber-400 font-mono w-8 text-center">{countdown}s</span>
        </div>
      </div>

      {/* Main Leaderboard Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-5xl mx-auto w-full my-auto">
        {sortedPlayers.map((player, idx) => {
          const isLastScored = player.id === lastScoredPlayerId;
          const isLeader = idx === 0;

          return (
            <div
              key={player.id}
              className={`p-6 rounded-3xl border transition-all flex items-center justify-between ${
                isLeader
                  ? 'bg-gradient-to-r from-amber-500/20 to-purple-600/20 border-amber-400/50 shadow-xl shadow-amber-500/10'
                  : 'bg-white/5 border-white/10 hover:border-white/30'
              }`}
            >
              <div className="flex items-center gap-5">
                {getRankBadge(idx)}
                <div
                  className="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl font-black shadow-inner"
                  style={{ backgroundColor: `${player.color}25`, border: `2px solid ${player.color}` }}
                >
                  <span style={{ color: player.color }}>{player.avatar}</span>
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-2xl font-black text-white">{player.name}</span>
                    <span className="text-xs px-2.5 py-0.5 rounded-full bg-white/10 text-white/70 font-mono uppercase">
                      {player.ageGroup}
                    </span>
                  </div>

                  <div className="flex items-center gap-4 mt-1 text-sm text-white/60">
                    {player.streak > 1 && (
                      <span className="flex items-center gap-1 text-orange-400 font-bold font-mono">
                        <Flame className="w-4 h-4 fill-orange-400" /> {player.streak} streak
                      </span>
                    )}
                    {isLastScored && lastPointsEarned > 0 && (
                      <span className="text-emerald-400 font-mono font-bold animate-pulse">
                        +{lastPointsEarned} pts
                      </span>
                    )}
                  </div>
                </div>
              </div>

              <div className="text-right">
                <span className="text-xs font-mono text-white/40 uppercase tracking-widest block">SCORE</span>
                <span className="text-4xl font-black text-amber-300 font-mono">
                  {player.score.toLocaleString()}
                </span>
              </div>
            </div>
          );
        })}
      </div>

      {/* Action Footer */}
      <div className="flex items-center justify-between border-t border-white/10 pt-6">
        <div className="flex items-center gap-2 text-white/50 text-sm font-mono">
          <ShieldCheck className="w-4 h-4 text-emerald-400" />
          <span>AUTHORITATIVE SCORES SYNCED & VALIDATED</span>
        </div>

        <TVFocusable
          id="btn-continue"
          group="score-actions"
          onActivate={() => {
            playTVSound('click');
            onContinue();
          }}
          className="flex items-center gap-3 px-8 py-4 rounded-2xl bg-gradient-to-r from-amber-400 to-orange-500 text-black font-black text-xl hover:scale-105 active:scale-95 transition-all shadow-xl shadow-amber-400/30 cursor-pointer"
        >
          <span>CONTINUE</span>
          <ArrowRight className="w-6 h-6" />
          <span className="text-xs px-2 py-0.5 rounded bg-black/20 text-black/80 font-mono">OK</span>
        </TVFocusable>
      </div>
    </div>
  );
}
