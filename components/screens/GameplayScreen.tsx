'use client';

// =============================================================================
// PlayTogether AI — Screen 12: Gameplay Screen
// Active question, 4 answer choices, visual timer, player turn, and score HUD.
// =============================================================================

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Clock, Zap, Sparkles } from 'lucide-react';
import { TVFocusable, useTVFocus, playTVSound } from '../tv/TVFocusManager';
import { Question, Player, Session } from '@/lib/types';

export interface GameplayScreenProps {
  question: Question;
  questionIndex?: number;
  totalQuestions?: number;
  players?: Player[];
  activePlayerIndex?: number;
  activePlayer?: Player;
  timerDurationSeconds?: number;
  session?: Session;
  onSubmitAnswer?: (optionId: string, responseTime: number) => void;
  onAnswerSelected?: (optionId: string, responseTimeMs: number) => void;
  onTriggerBuzz?: () => void;
}

export function GameplayScreen({
  question,
  questionIndex = 0,
  totalQuestions = 5,
  players = [],
  activePlayerIndex = 0,
  activePlayer: activePlayerProp,
  timerDurationSeconds = 15,
  session,
  onSubmitAnswer,
  onAnswerSelected,
  onTriggerBuzz,
}: GameplayScreenProps) {
  const { setActiveFocusId, lastCommand, commandCounter } = useTVFocus();
  const [secondsRemaining, setSecondsRemaining] = useState<number>(timerDurationSeconds);
  const [isSubmitted, setIsSubmitted] = useState<boolean>(false);
  const [selectedOption, setSelectedOption] = useState<string | null>(null);

  // Buzzer States
  const [isBuzzed, setIsBuzzed] = useState<boolean>(false);
  const [buzzedPlayer, setBuzzedPlayer] = useState<Player | null>(null);
  const [buzzReactionSec, setBuzzReactionSec] = useState<number | null>(null);
  const [isScreenShaking, setIsScreenShaking] = useState<boolean>(false);

  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const startTimeRef = useRef<number>(Date.now());
  const lastProcessedCmdRef = useRef<number>(0);

  const playerList = players.length > 0 ? players : session?.players || [];
  const currentActivePlayer =
    activePlayerProp ||
    playerList[activePlayerIndex % (playerList.length || 1)] ||
    playerList[0] ||
    ({ name: 'Player 1', accentColor: '#3b82f6', color: '#3b82f6', score: 0 } as Player);

  const qIndex = session ? session.currentQuestionIndex || questionIndex : questionIndex;
  const totalQ = session ? session.totalRounds || totalQuestions : totalQuestions;

  // Handle Buzz In Action
  const handleBuzzIn = useCallback(
    (claimingPlayer?: Player) => {
      if (isSubmitted || isBuzzed) return; // Ignore if already buzzed or submitted
      playTVSound('buzz');

      const claimPlayer = claimingPlayer || currentActivePlayer;
      const reaction = Number(
        Math.max(0.2, (Date.now() - startTimeRef.current) / 1000).toFixed(2)
      );

      setIsBuzzed(true);
      setBuzzedPlayer(claimPlayer);
      setBuzzReactionSec(reaction);
      setIsScreenShaking(true);
      setTimeout(() => setIsScreenShaking(false), 600);

      if (onTriggerBuzz) {
        onTriggerBuzz();
      }

      // Automatically shift remote focus directly to Option A
      setActiveFocusId('gameplay-opt-A');
    },
    [isSubmitted, isBuzzed, currentActivePlayer, onTriggerBuzz, setActiveFocusId]
  );

  // Listen to remote commands for BUZZ
  useEffect(() => {
    if (commandCounter > lastProcessedCmdRef.current) {
      lastProcessedCmdRef.current = commandCounter;
      if (lastCommand === 'BUZZ') {
        handleBuzzIn();
      }
    }
  }, [commandCounter, lastCommand, handleBuzzIn]);

  // Set default focus on Option A and reset question states
  useEffect(() => {
    setActiveFocusId('gameplay-opt-A');
    setSecondsRemaining(timerDurationSeconds);
    setIsSubmitted(false);
    setSelectedOption(null);
    setIsBuzzed(false);
    setBuzzedPlayer(null);
    setBuzzReactionSec(null);
    setIsScreenShaking(false);
    startTimeRef.current = Date.now();
  }, [question.id, timerDurationSeconds, setActiveFocusId]);

  const handleSelectOption = (optId: string) => {
    if (isSubmitted) return; // Lock to prevent double submit
    setIsSubmitted(true);
    setSelectedOption(optId);

    if (timerRef.current) clearInterval(timerRef.current);

    const elapsedMs = Math.max(500, Date.now() - startTimeRef.current);
    const elapsedSec = Number(Math.min(timerDurationSeconds, elapsedMs / 1000).toFixed(1));

    if (onAnswerSelected) {
      onAnswerSelected(optId, elapsedMs);
    } else if (onSubmitAnswer) {
      onSubmitAnswer(optId, elapsedSec);
    }
  };

  // Countdown Timer
  useEffect(() => {
    if (isSubmitted) return;

    timerRef.current = setInterval(() => {
      setSecondsRemaining((prev) => {
        if (prev <= 1) {
          if (timerRef.current) clearInterval(timerRef.current);
          handleSelectOption(selectedOption || 'A');
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [isSubmitted, selectedOption]);

  const timerPercent = (secondsRemaining / timerDurationSeconds) * 100;
  const playerColor = currentActivePlayer.color || currentActivePlayer.accentColor || '#3b82f6';

  return (
    <div
      className={`relative w-full h-full flex flex-col justify-between px-12 py-3 select-none text-white ${
        isScreenShaking ? 'animate-buzzer-shake' : 'animate-fadeIn'
      }`}
    >
      {/* 1. Top HUD: Active Question Count, Active Player Turn, Buzzer Status, Points & Timer */}
      <div className="p-4 rounded-2xl bg-surface/80 border border-outline-variant/40 backdrop-blur-md flex items-center justify-between shadow-lg">
        {/* Left: Question Counter & Category */}
        <div className="flex items-center gap-3">
          <span className="px-3 py-1 rounded-full bg-secondary/20 border border-secondary/40 text-xs font-mono font-bold text-secondary">
            QUESTION {qIndex + 1} OF {totalQ}
          </span>
          <span className="text-sm font-semibold text-white">
            {question.categoryEmoji || '🎬'} {question.category}
          </span>
          <span className="text-xs font-mono px-2.5 py-0.5 rounded bg-surface-high border border-outline-variant/50 text-slate-300 uppercase">
            {question.difficulty}
          </span>
        </div>

        {/* Center: Active Player Turn & Sofa Buzzer Indicator */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-3 px-4 py-1.5 rounded-full bg-slate-950/70 border border-slate-700">
            <span
              className="w-3.5 h-3.5 rounded-full shadow"
              style={{ backgroundColor: playerColor }}
            />
            <span className="text-sm font-space font-bold text-white">
              TURN: {currentActivePlayer.name}
            </span>
          </div>

          {isBuzzed ? (
            <div className="flex items-center gap-2 px-4 py-1.5 rounded-full bg-gradient-to-r from-amber-500/30 to-yellow-500/30 border-2 border-amber-400 text-amber-300 font-mono text-xs font-black shadow-lg shadow-amber-500/30 animate-pulse">
              <Zap className="w-4 h-4 fill-amber-400 text-amber-400 animate-bounce" />
              <span>
                ⚡ {buzzedPlayer?.name || currentActivePlayer.name} BUZZED IN ({buzzReactionSec}s) • 2X MULTIPLIER!
              </span>
            </div>
          ) : (
            <TVFocusable
              id="gameplay-btn-buzz"
              group="hud-buzzer"
              onActivate={() => handleBuzzIn()}
              className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-amber-500/20 hover:bg-amber-500/40 border border-amber-400/60 text-amber-300 font-mono text-xs font-bold transition shadow cursor-pointer active:scale-95"
            >
              <Zap className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
              <span>BUZZ IN</span>
            </TVFocusable>
          )}
        </div>

        {/* Right: Point Value & Countdown Timer */}
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-500/10 border border-amber-400/30 text-amber-300 font-mono text-xs font-bold">
            <Zap className="w-3.5 h-3.5 fill-amber-300" />
            <span>+{isBuzzed ? (question.pointValue || 100) * 2 : question.pointValue || 100} PTS</span>
          </div>

          <div className="flex items-center gap-2">
            <Clock
              className={`w-5 h-5 ${
                secondsRemaining <= 4 ? 'text-error animate-pulse' : 'text-slate-400'
              }`}
            />
            <span
              className={`font-mono text-xl font-bold ${
                secondsRemaining <= 4 ? 'text-error' : 'text-white'
              }`}
            >
              {secondsRemaining}s
            </span>
          </div>
        </div>
      </div>

      {/* Timer Bar Gauge */}
      <div className="w-full bg-slate-900/80 h-1.5 rounded-full overflow-hidden my-2 border border-slate-800">
        <div
          className={`h-full transition-all duration-1000 ease-linear rounded-full ${
            secondsRemaining <= 4
              ? 'bg-gradient-to-r from-red-600 to-amber-500 animate-pulse'
              : 'bg-gradient-to-r from-cyan-500 via-secondary to-primary-container'
          }`}
          style={{ width: `${timerPercent}%` }}
        />
      </div>

      {/* 2. Center Card: Prompt, Buzzer Banner & Quote Highlight */}
      <div className="flex-1 my-auto max-w-4xl mx-auto w-full p-8 rounded-3xl bg-surface/90 border border-outline-variant/60 shadow-2xl backdrop-blur-xl flex flex-col justify-center items-center text-center">
        {isBuzzed && (
          <div className="mb-4 inline-flex items-center gap-2 px-6 py-2 rounded-full bg-gradient-to-r from-amber-500 via-orange-500 to-yellow-400 text-slate-950 font-black text-sm tracking-wider shadow-2xl shadow-amber-500/50 animate-bounce">
            <Zap className="w-5 h-5 fill-slate-950 text-slate-950" />
            <span>⚡ BUZZER LOCKED IN! 2X SPEED MULTIPLIER FOR {buzzedPlayer?.name || currentActivePlayer.name}!</span>
          </div>
        )}

        {question.quoteHighlight && (
          <div className="mb-4 px-6 py-2 rounded-2xl bg-secondary/15 border border-secondary/30 text-secondary text-sm font-space font-medium tracking-wide">
            &ldquo;{question.quoteHighlight}&rdquo;
          </div>
        )}

        <h2 className="font-space text-3xl font-extrabold text-white leading-snug drop-shadow-md">
          {question.question}
        </h2>

        {isSubmitted && (
          <div className="mt-4 flex items-center gap-2 px-4 py-1.5 rounded-full bg-cyan-500/20 text-cyan-300 border border-cyan-400/40 text-xs font-mono animate-pulse">
            <Sparkles className="w-4 h-4" />
            <span>ANSWER LOCKED • EVALUATING ON AUTHORITATIVE SERVER...</span>
          </div>
        )}
      </div>

      {/* 3. Bottom 4 Answer Options (2x2 Spatial Grid) */}
      <div className="grid grid-cols-2 gap-4 mt-2">
        {question.options.map((opt) => {
          const isSelected = selectedOption === opt.id;
          return (
            <TVFocusable
              key={opt.id}
              id={`gameplay-opt-${opt.id}`}
              group="gameplay-options"
              isSelected={isSelected}
              onActivate={() => handleSelectOption(opt.id)}
              className={`p-5 rounded-2xl border transition-all flex items-center justify-between text-left ${
                isSubmitted
                  ? isSelected
                    ? 'bg-cyan-500/30 border-cyan-400 text-white ring-2 ring-cyan-400'
                    : 'bg-surface/40 border-outline-variant/30 text-slate-500 pointer-events-none'
                  : 'bg-surface/80 border-outline-variant/50 hover:border-secondary hover:bg-surface'
              }`}
            >
              <div className="flex items-center gap-4">
                <span className="w-10 h-10 rounded-xl bg-slate-900 border border-outline-variant flex items-center justify-center font-mono font-bold text-lg text-secondary">
                  {opt.id}
                </span>
                <span className="font-space font-semibold text-lg text-white">
                  {opt.text}
                </span>
              </div>
            </TVFocusable>
          );
        })}
      </div>
    </div>
  );
}

export default GameplayScreen;
