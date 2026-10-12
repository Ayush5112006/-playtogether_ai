'use client';

import React, { useEffect, useState, useRef, useCallback } from 'react';
import { Zap, BellRing, Sparkles, ArrowRight, Flame, ShieldAlert, Award } from 'lucide-react';
import { playTVSound, TVFocusable, useTVFocus } from '@/components/tv/TVFocusManager';
import { Session, Player } from '@/lib/types';

interface SurpriseRoundScreenProps {
  session: Session;
  players: Player[];
  onStartRound: () => void;
  onBuzzerTest?: (playerId: string) => void;
}

export default function SurpriseRoundScreen({
  session,
  players,
  onStartRound,
  onBuzzerTest,
}: SurpriseRoundScreenProps) {
  const { setActiveFocusId, lastCommand, commandCounter } = useTVFocus();
  const [buzzedPlayer, setBuzzedPlayer] = useState<Player | null>(null);
  const lastProcessedCmdRef = useRef<number>(0);

  const playerList = players.length > 0 ? players : session?.players || [];

  const handleTestBuzzer = useCallback((player: Player) => {
    playTVSound('buzz');
    setBuzzedPlayer(player);
    if (onBuzzerTest) onBuzzerTest(player.id);
  }, [onBuzzerTest]);

  // Set default focus to START BLITZ button
  useEffect(() => {
    setActiveFocusId('btn-start-surprise');
    playTVSound('surprise');
  }, [setActiveFocusId]);

  // Listen to remote commands
  useEffect(() => {
    if (commandCounter > lastProcessedCmdRef.current) {
      lastProcessedCmdRef.current = commandCounter;
      if (lastCommand === 'BUZZ') {
        const targetPlayer = playerList[0] || ({ id: 'p1', name: 'Player 1', avatar: '🎮', color: '#f59e0b', score: 0, streak: 0 } as Player);
        handleTestBuzzer(targetPlayer);
      }
    }
  }, [commandCounter, lastCommand, playerList, handleTestBuzzer]);

  return (
    <div className="w-full h-full flex flex-col justify-between px-8 py-3.5 relative bg-gradient-to-b from-orange-950/20 to-black select-none text-white animate-fadeIn overflow-hidden">
      {/* 1. Top Banner Header (With Always-Visible Start Button) */}
      <div className="flex items-center justify-between z-10 shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-xl bg-orange-500/20 border border-orange-500/50 flex items-center justify-center shadow-lg shadow-orange-500/30">
            <Zap className="w-6 h-6 text-orange-400 animate-bounce" />
          </div>
          <div>
            <span className="text-[10px] font-mono uppercase tracking-widest text-orange-400 flex items-center gap-1.5">
              <Sparkles className="w-3 h-3" /> SURPRISE STAKES UNLOCKED
            </span>
            <h1 className="text-2xl md:text-3xl font-black text-white tracking-tight">Lightning Buzzer Blitz!</h1>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5 bg-gradient-to-r from-amber-500/30 to-orange-500/30 border border-amber-400/50 px-3.5 py-1.5 rounded-xl animate-pulse">
            <Flame className="w-4 h-4 text-amber-400 fill-amber-400" />
            <span className="text-xs font-black text-amber-300 font-mono tracking-wider">2X MULTIPLIER</span>
          </div>

          <TVFocusable
            id="btn-start-surprise-top"
            group="surprise-actions"
            onActivate={() => {
              playTVSound('click');
              onStartRound();
            }}
            className="flex items-center gap-2 px-5 py-2 rounded-xl bg-gradient-to-r from-orange-500 to-amber-500 text-black font-space font-extrabold text-sm shadow-lg shadow-orange-500/40 ring-2 ring-white/50 hover:scale-105 active:scale-95 transition cursor-pointer"
          >
            <span>START BLITZ [OK]</span>
            <ArrowRight className="w-4 h-4" />
          </TVFocusable>
        </div>
      </div>

      {/* 2. Main Center Content (Compact & Sofa-Friendly) */}
      <div className="max-w-4xl mx-auto w-full my-auto text-center space-y-3 z-10">
        <div className="inline-block p-0.5 rounded-full bg-gradient-to-r from-orange-500 via-amber-400 to-red-500">
          <div className="bg-black/90 px-5 py-1 rounded-full flex items-center gap-2">
            <BellRing className="w-4 h-4 text-orange-400 animate-spin" />
            <span className="text-xs md:text-sm font-black text-white">FASTEST FINGERS FIRST</span>
          </div>
        </div>

        <div>
          <h2 className="text-2xl md:text-3xl font-black text-white leading-tight">
            First to Buzz gets to answer!
          </h2>
          <p className="text-sm md:text-base font-bold text-transparent bg-clip-text bg-gradient-to-r from-orange-400 via-amber-300 to-yellow-400 mt-0.5">
            Correct answer steals 2x points.
          </p>
        </div>

        {/* Buzzer Practice Grid (Responsive for 2–8 players) */}
        <div className="p-3 rounded-2xl bg-white/5 border border-white/10 backdrop-blur-md">
          <span className="text-[10px] font-mono text-white/50 uppercase tracking-widest block mb-2">
            TEST REMOTE BUZZER / D-PAD SELECT TO PRACTICE ({playerList.length} PLAYERS)
          </span>

          <div className="grid grid-cols-4 md:grid-cols-5 lg:grid-cols-8 gap-2 max-h-[140px] overflow-y-auto pr-1">
            {playerList.map((p) => {
              const isBuzzed = buzzedPlayer?.id === p.id;
              const color = p.color || p.accentColor || '#3b82f6';
              return (
                <TVFocusable
                  key={p.id}
                  id={`surprise-player-${p.id}`}
                  group="surprise-players"
                  onActivate={() => handleTestBuzzer(p)}
                  className={`p-2 rounded-xl border transition-all flex flex-col items-center gap-1 cursor-pointer ${
                    isBuzzed
                      ? 'bg-amber-500/30 border-amber-400 scale-105 shadow-lg shadow-amber-500/30 ring-2 ring-amber-400'
                      : 'bg-white/5 border-white/10 hover:border-white/30'
                  }`}
                >
                  <div
                    className="w-8 h-8 rounded-lg flex items-center justify-center text-sm font-bold shadow"
                    style={{ backgroundColor: `${color}30`, border: `2px solid ${color}` }}
                  >
                    <span style={{ color }}>{p.avatar || p.name.charAt(0)}</span>
                  </div>
                  <span className="font-bold text-white text-xs truncate max-w-[90px]">{p.name}</span>
                  <span className="text-[9px] font-mono text-amber-300 font-bold">
                    {isBuzzed ? '⚡ BUZZED!' : 'PRACTICE'}
                  </span>
                </TVFocusable>
              );
            })}
          </div>

          {buzzedPlayer && (
            <div className="mt-2 inline-flex items-center gap-1.5 text-emerald-400 font-mono text-xs font-bold bg-emerald-500/10 px-3 py-1 rounded-full border border-emerald-500/30 animate-bounce">
              <Award className="w-3.5 h-3.5" />
              <span>{buzzedPlayer.name} buzzed in first! System verified.</span>
            </div>
          )}
        </div>
      </div>

      {/* 3. Action Footer (Always In View) */}
      <div className="flex items-center justify-between border-t border-white/10 pt-2.5 z-10 shrink-0">
        <div className="flex items-center gap-2 text-white/50 text-xs font-mono">
          <ShieldAlert className="w-3.5 h-3.5 text-orange-400" />
          <span>FIRE TV D-PAD SELECT OR TOUCH TO PRACTICE BUZZER</span>
        </div>

        <TVFocusable
          id="btn-start-surprise"
          group="surprise-actions"
          onActivate={() => {
            playTVSound('click');
            onStartRound();
          }}
          className="flex items-center gap-2.5 px-7 py-2.5 rounded-2xl bg-gradient-to-r from-orange-500 to-amber-500 text-black font-black text-base hover:scale-105 active:scale-95 transition-all shadow-xl shadow-orange-500/40 ring-2 ring-white/50 cursor-pointer"
        >
          <span>START BLITZ</span>
          <ArrowRight className="w-5 h-5" />
          <span className="text-xs px-2 py-0.5 rounded bg-black/20 text-black/80 font-mono">OK</span>
        </TVFocusable>
      </div>
    </div>
  );
}
