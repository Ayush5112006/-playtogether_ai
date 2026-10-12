'use client';

// =============================================================================
// PlayTogether AI — Screen 13: Answer Result & Explanation Screen
// Correct/incorrect validation, points earned, streak update, and explanation card.
// =============================================================================

import React, { useEffect } from 'react';
import { CheckCircle2, XCircle, ArrowRight, Zap, Flame } from 'lucide-react';
import { TVFocusable, useTVFocus } from '../tv/TVFocusManager';
import { Question, Player, AnswerResult } from '@/lib/types';

export interface AnswerResultScreenProps {
  question: Question;
  result: AnswerResult;
  player?: Player;
  onContinue: () => void;
}

export function AnswerResultScreen({
  question,
  result,
  player: playerProp,
  onContinue,
}: AnswerResultScreenProps) {
  const { setActiveFocusId } = useTVFocus();
  const player = playerProp || result.player || ({ name: 'Player', accentColor: '#3b82f6', color: '#3b82f6' } as Player);

  useEffect(() => {
    setActiveFocusId('result-btn-continue');
  }, [setActiveFocusId]);

  const correctOption = question.options.find(
    (o) => o.id === result.correctOptionId
  ) || question.options[0];

  return (
    <div className="relative w-full h-full flex flex-col items-center justify-center select-none text-center animate-fadeIn text-white max-w-3xl mx-auto my-auto py-6">
      {/* 1. Large Status Icon */}
      <div className="mb-4">
        {result.isCorrect ? (
          <div className="w-24 h-24 rounded-full bg-emerald-500/20 border-4 border-emerald-400 flex items-center justify-center shadow-2xl shadow-emerald-500/40 animate-bounce">
            <CheckCircle2 className="w-14 h-14 text-emerald-400" />
          </div>
        ) : (
          <div className="w-24 h-24 rounded-full bg-rose-500/20 border-4 border-rose-400 flex items-center justify-center shadow-2xl shadow-rose-500/40">
            <XCircle className="w-14 h-14 text-rose-400" />
          </div>
        )}
      </div>

      {/* 2. Result Headline */}
      <h1
        className={`font-space font-extrabold text-5xl mb-2 drop-shadow tracking-tight ${
          result.isCorrect ? 'text-emerald-400' : 'text-rose-400'
        }`}
      >
        {result.isCorrect ? "THAT'S CORRECT!" : 'NOT QUITE!'}
      </h1>

      {/* Points Banner */}
      <div className="text-2xl font-space font-bold mb-6">
        {result.isCorrect ? (
          <span className="text-amber-300 drop-shadow flex items-center justify-center gap-2">
            <span>+{result.pointsEarned ?? result.scoreDelta ?? 0} POINTS EARNED!</span>
            {result.buzzerBonusApplied && (
              <span className="text-xs font-mono px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-400/40 animate-pulse">
                ⚡ 2X BUZZER BOOST
              </span>
            )}
            {result.speedBonusApplied && (
              <span className="text-xs font-mono px-2 py-0.5 rounded bg-cyan-500/20 text-cyan-300 border border-cyan-400/40">
                ⚡ SPEED BONUS (+50)
              </span>
            )}
          </span>
        ) : (
          <span className="text-slate-300 text-lg">
            Correct Answer was:{' '}
            <strong className="text-cyan-300">
              {correctOption.id}. {correctOption.text}
            </strong>
          </span>
        )}
      </div>

      {/* 3. Explanation Card */}
      <div className="w-full p-6 rounded-3xl bg-surface/90 border border-outline-variant/60 backdrop-blur-md shadow-2xl mb-8 text-left">
        {/* Player & Streak Info Header */}
        <div className="flex items-center justify-between pb-3 mb-3 border-b border-outline-variant/40">
          <div className="flex items-center gap-3">
            <div
              className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-slate-950"
              style={{ backgroundColor: player.accentColor }}
            >
              {player.name.charAt(0)}
            </div>
            <span className="font-space font-bold text-base text-white">{player.name}</span>
          </div>

          <div className="flex items-center gap-2">
            {(result.newStreak ?? result.streak ?? 0) > 1 && (
              <span className="flex items-center gap-1 px-3 py-1 rounded-full bg-amber-500/20 border border-amber-400/40 text-xs font-mono font-bold text-amber-300">
                <Flame className="w-3.5 h-3.5" />
                <span>{result.newStreak ?? result.streak}x STREAK</span>
              </span>
            )}
            <span className="text-xs font-mono text-cyan-300">
              Total Score: <strong>{result.newScore} PTS</strong>
            </span>
          </div>
        </div>

        {/* Explanation Text */}
        <p className="font-outfit text-base text-slate-200 leading-relaxed">
          {result.explanation || question.explanation}
        </p>
      </div>

      {/* 4. Continue CTA */}
      <TVFocusable
        id="result-btn-continue"
        group="result"
        onActivate={onContinue}
        className="flex items-center gap-3 px-12 py-4 rounded-2xl bg-gradient-to-r from-primary-container to-secondary text-slate-950 font-space font-bold text-lg tracking-wide shadow-2xl hover:brightness-110 active:scale-95 transition"
      >
        <span>CONTINUE [OK]</span>
        <ArrowRight className="w-6 h-6" />
      </TVFocusable>
    </div>
  );
}

export default AnswerResultScreen;
