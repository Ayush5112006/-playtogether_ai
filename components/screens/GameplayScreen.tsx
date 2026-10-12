'use client';

// =============================================================================
// PlayTogether AI — Screen 12: Gameplay Screen
// Active question, 4 answer choices, visual timer, player turn, and score HUD.
// =============================================================================

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Clock, Zap, Sparkles, HelpCircle, Flame, Lightbulb } from 'lucide-react';
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

  // Lifeline & Hint states
  const [eliminatedOptions, setEliminatedOptions] = useState<string[]>([]);
  const [lifelinesRemaining, setLifelinesRemaining] = useState<number>(2);
  const [hintsRemaining, setHintsRemaining] = useState<number>(2);
  const [isHintVisible, setIsHintVisible] = useState<boolean>(false);

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
    ({ name: 'Player 1', accentColor: '#3b82f6', color: '#3b82f6', score: 0, streak: 0 } as Player);

  const qIndex = session ? session.currentQuestionIndex || questionIndex : questionIndex;
  const totalQ = session ? session.totalRounds || totalQuestions : totalQuestions;

  // Streak Multiplier Calculation
  const playerStreak = currentActivePlayer.streak || 0;
  const streakMultiplier = playerStreak >= 3 ? 2.0 : playerStreak >= 2 ? 1.5 : 1.0;
  const rawBasePoints = question.pointValue || 100;
  const earnedPoints = Math.round(rawBasePoints * (isBuzzed ? 2 : 1) * streakMultiplier);

  // Handle 50/50 Lifeline
  const handleUseFiftyFifty = useCallback(() => {
    if (isSubmitted || lifelinesRemaining <= 0 || eliminatedOptions.length > 0) return;
    playTVSound('surprise');
    const incorrectOptions = question.options
      .map((o) => o.id)
      .filter((id) => id !== question.correctOptionId);
    const toEliminate = incorrectOptions.slice(0, 2);
    setEliminatedOptions(toEliminate);
    setLifelinesRemaining((prev) => Math.max(0, prev - 1));
  }, [isSubmitted, lifelinesRemaining, eliminatedOptions.length, question.options, question.correctOptionId]);

  // Handle AI Hint
  const handleUseHint = useCallback(() => {
    if (isSubmitted || hintsRemaining <= 0 || isHintVisible) return;
    playTVSound('ai');
    setIsHintVisible(true);
    setHintsRemaining((prev) => Math.max(0, prev - 1));
  }, [isSubmitted, hintsRemaining, isHintVisible]);

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

  // Keyboard shortcut listener for Lifeline (L) and Hint (H)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (isSubmitted) return;
      if (e.key === 'l' || e.key === 'L') {
        handleUseFiftyFifty();
      } else if (e.key === 'h' || e.key === 'H') {
        handleUseHint();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isSubmitted, handleUseFiftyFifty, handleUseHint]);

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
    setEliminatedOptions([]);
    setIsHintVisible(false);
    startTimeRef.current = Date.now();
  }, [question.id, timerDurationSeconds, setActiveFocusId]);

  const handleSelectOption = (optId: string) => {
    if (isSubmitted || eliminatedOptions.includes(optId)) return;
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
        {/* Left: Question Counter, Category & Lifelines */}
        <div className="flex flex-col gap-1.5">
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

          {/* Lifelines & Streak Multiplier Pill */}
          <div className="flex items-center gap-2 mt-1">
            <button
              type="button"
              onClick={handleUseFiftyFifty}
              disabled={lifelinesRemaining <= 0 || eliminatedOptions.length > 0 || isSubmitted}
              className={`flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-mono font-bold transition shadow ${
                eliminatedOptions.length > 0
                  ? 'bg-slate-800/60 text-slate-500 border border-slate-700 cursor-not-allowed'
                  : lifelinesRemaining > 0
                  ? 'bg-purple-500/20 hover:bg-purple-500/40 border border-purple-400/50 text-purple-300 cursor-pointer active:scale-95'
                  : 'bg-slate-900 text-slate-600 border border-slate-800 cursor-not-allowed'
              }`}
            >
              <HelpCircle className="w-3 h-3" />
              <span>50/50 [L] ({lifelinesRemaining})</span>
            </button>

            <button
              type="button"
              onClick={handleUseHint}
              disabled={hintsRemaining <= 0 || isHintVisible || isSubmitted}
              className={`flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-mono font-bold transition shadow ${
                isHintVisible
                  ? 'bg-amber-500/30 text-amber-300 border border-amber-400 cursor-not-allowed'
                  : hintsRemaining > 0
                  ? 'bg-amber-500/20 hover:bg-amber-500/40 border border-amber-400/50 text-amber-300 cursor-pointer active:scale-95'
                  : 'bg-slate-900 text-slate-600 border border-slate-800 cursor-not-allowed'
              }`}
            >
              <Lightbulb className="w-3 h-3" />
              <span>HINT [H] ({hintsRemaining})</span>
            </button>

            {streakMultiplier > 1.0 && (
              <div className="flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-orange-500/20 border border-orange-400/60 text-orange-300 font-mono text-xs font-black animate-pulse">
                <Flame className="w-3 h-3 text-orange-400 fill-orange-400" />
                <span>{streakMultiplier === 2.0 ? '⚡ 2.0x MEGA COMBO' : '🔥 1.5x COMBO'}</span>
              </div>
            )}
          </div>
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
            <span>+{earnedPoints} PTS</span>
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

        {isHintVisible && (
          <div className="mb-4 px-6 py-2.5 rounded-2xl bg-amber-500/20 border border-amber-400/50 text-amber-200 text-sm font-space font-medium tracking-wide flex items-center gap-3 animate-fadeIn shadow-lg shadow-amber-500/20">
            <Lightbulb className="w-5 h-5 text-amber-400 shrink-0 animate-bounce" />
            <div className="text-left">
              <span className="font-bold text-amber-300 mr-1.5">💡 AI Host Clue:</span>
              <span>{question.explanation ? `Hint: ${question.explanation.slice(0, 100)}...` : `Think carefully about famous ${question.category} highlights!`}</span>
            </div>
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
          const isEliminated = eliminatedOptions.includes(opt.id);

          return (
            <TVFocusable
              key={opt.id}
              id={`gameplay-opt-${opt.id}`}
              group="gameplay-options"
              isSelected={isSelected}
              disabled={isEliminated}
              onActivate={() => handleSelectOption(opt.id)}
              className={`p-5 rounded-2xl border transition-all flex items-center justify-between text-left ${
                isEliminated
                  ? 'bg-red-950/20 border-red-900/40 text-red-400/50 line-through opacity-40 pointer-events-none'
                  : isSubmitted
                  ? isSelected
                    ? 'bg-cyan-500/30 border-cyan-400 text-white ring-2 ring-cyan-400'
                    : 'bg-surface/40 border-outline-variant/30 text-slate-500 pointer-events-none'
                  : 'bg-surface/80 border-outline-variant/50 hover:border-secondary hover:bg-surface'
              }`}
            >
              <div className="flex items-center gap-4">
                <span
                  className={`w-10 h-10 rounded-xl border flex items-center justify-center font-mono font-bold text-lg ${
                    isEliminated
                      ? 'bg-red-950/60 border-red-800 text-red-500'
                      : 'bg-slate-900 border-outline-variant text-secondary'
                  }`}
                >
                  {isEliminated ? '✕' : opt.id}
                </span>
                <span className={`font-space font-semibold text-lg ${isEliminated ? 'text-red-400/60' : 'text-white'}`}>
                  {opt.text}
                </span>
              </div>
              {isEliminated && (
                <span className="text-xs font-mono font-bold text-red-400 bg-red-950/70 border border-red-800/60 px-2 py-0.5 rounded uppercase">
                  50/50 Eliminated
                </span>
              )}
            </TVFocusable>
          );
        })}
      </div>
    </div>
  );
}

export default GameplayScreen;
