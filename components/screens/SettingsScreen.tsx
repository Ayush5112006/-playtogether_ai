'use client';

// =============================================================================
// PlayTogether AI — Screen 9: Settings Screen (AI Dynamic Match Synthesizer)
// Increment, decrement, timers, question counts, difficulty, and persona tuning.
// =============================================================================

import React, { useEffect } from 'react';
import { Play, RotateCcw, Clock, Layers, Shield, CheckCircle, Volume2, Sparkles, Sliders } from 'lucide-react';
import { TVFocusable, useTVFocus } from '../tv/TVFocusManager';
import { AIObsorbOrb } from '../tv/AIObsorbOrb';
import { Player, GameSettings, DifficultyStrategy } from '@/lib/types';

const DEFAULT_SETTINGS: GameSettings = {
  questionCount: 5,
  timerSeconds: 15,
  difficulty: 'ADAPTIVE',
  persona: 'Playful Host',
  adaptiveHandicap: true,
  voiceHostEnabled: true,
  sfxEnabled: true,
  reducedMotion: false,
  highContrast: false,
};

export interface SettingsScreenProps {
  players?: Player[];
  settings?: GameSettings;
  selectedCategory?: string;
  selectedDifficulty?: DifficultyStrategy;
  onUpdateSettings?: (newSettings: GameSettings) => void;
  onStartGame?: () => void;
  onBack?: () => void;
}

export function SettingsScreen({
  players = [],
  settings = DEFAULT_SETTINGS,
  selectedCategory = 'Science & Cosmos',
  selectedDifficulty = 'ADAPTIVE',
  onUpdateSettings,
  onStartGame,
  onBack,
}: SettingsScreenProps) {
  const { setActiveFocusId } = useTVFocus();
  const [currentSettings, setCurrentSettings] = React.useState<GameSettings>(settings || DEFAULT_SETTINGS);

  React.useEffect(() => {
    if (settings) {
      setCurrentSettings(settings);
    }
  }, [settings]);

  useEffect(() => {
    setActiveFocusId('settings-btn-start');
  }, [setActiveFocusId]);

  const playerNames = (players || []).map((p) => p.name).join(', ') || 'All Family';

  const handleSetQuestionCount = (count: number) => {
    const updated = { ...currentSettings, questionCount: count as 5 | 10 | 15 };
    setCurrentSettings(updated);
    onUpdateSettings?.(updated);
  };

  const handleSetTimerSeconds = (seconds: number) => {
    const updated = { ...currentSettings, timerSeconds: seconds as 10 | 15 | 20 | 30 };
    setCurrentSettings(updated);
    onUpdateSettings?.(updated);
  };

  const handleSetDifficulty = (diff: DifficultyStrategy) => {
    const updated = { ...currentSettings, difficulty: diff };
    setCurrentSettings(updated);
    onUpdateSettings?.(updated);
  };

  const handleResetDefaults = () => {
    const def: GameSettings = {
      questionCount: 10,
      timerSeconds: 15,
      difficulty: 'ADAPTIVE',
      persona: 'Playful Host',
      adaptiveHandicap: true,
      voiceHostEnabled: true,
      sfxEnabled: true,
      reducedMotion: false,
      highContrast: false,
    };
    setCurrentSettings(def);
    onUpdateSettings?.(def);
  };


  return (
    <div className="relative w-full h-full flex flex-col justify-between px-10 py-4 select-none animate-fadeIn text-white">
      {/* 2-Column Synthesis Arena */}
      <div className="grid grid-cols-12 gap-8 items-start my-auto">
        {/* Left 5 Columns: Dynamic Match Synthesizer AI Card */}
        <div className="col-span-5 p-7 rounded-3xl bg-surface/85 border border-outline-variant/50 backdrop-blur-md shadow-2xl flex flex-col items-center text-center justify-between">
          <div className="my-2">
            <AIObsorbOrb size="lg" label="CORTEX-9" />
          </div>

          <h2 className="font-space font-bold text-2xl text-white tracking-tight mt-2 mb-1">
            Dynamic Match Synthesizer
          </h2>
          <p className="font-outfit text-xs text-slate-400 mb-4">
            Engine calibrated for <strong className="text-secondary">{playerNames}</strong>
          </p>

          {/* Quick Metrics Badges */}
          <div className="flex flex-wrap items-center justify-center gap-2 mb-5">
            <span className="px-3 py-1 rounded-full bg-surface-high border border-outline-variant text-xs font-mono text-cyan-300">
              ⚡ {currentSettings.questionCount} Questions
            </span>
            <span className="px-3 py-1 rounded-full bg-surface-high border border-outline-variant text-xs font-mono text-purple-300">
              ⏱ {currentSettings.timerSeconds}s / Q
            </span>
            <span className="px-3 py-1 rounded-full bg-surface-high border border-outline-variant text-xs font-mono text-emerald-300">
              🎮 ~{Math.ceil((currentSettings.questionCount * currentSettings.timerSeconds) / 60)} Min
            </span>
            <span className="px-3 py-1 rounded-full bg-surface-high border border-outline-variant text-xs font-mono text-amber-300">
              🎯 {currentSettings.difficulty}
            </span>
          </div>

          {/* CORTEX-9 Host Logic Briefing */}
          <div className="w-full p-4 rounded-2xl bg-slate-950/60 border border-slate-800 text-left mb-4">
            <div className="text-[11px] font-mono text-secondary mb-1 flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5 text-secondary" />
              <span>CORTEX-9 HOST LOGIC:</span>
            </div>
            <p className="text-xs text-slate-300 leading-relaxed italic">
              "Persona: {currentSettings.persona}. Category: {selectedCategory}. Adaptive handicap will dynamically balance point weights. Surprise buzzer round enabled!"
            </p>
          </div>

          {/* System Health Indicators */}
          <div className="w-full space-y-2 text-xs font-mono text-left">
            <div className="flex items-center justify-between p-2 rounded-xl bg-surface-high/60 border border-outline-variant/30">
              <span className="flex items-center gap-2 text-slate-300">
                <CheckCircle className="w-3.5 h-3.5 text-emerald-400" />
                <span>AI Question Bank</span>
              </span>
              <span className="text-emerald-400 font-semibold">LOADED (Supabase)</span>
            </div>

            <div className="flex items-center justify-between p-2 rounded-xl bg-surface-high/60 border border-outline-variant/30">
              <span className="flex items-center gap-2 text-slate-300">
                <CheckCircle className="w-3.5 h-3.5 text-emerald-400" />
                <span>Adaptive Handicap</span>
              </span>
              <span className="text-secondary font-semibold">
                {currentSettings.adaptiveHandicap ? 'ACTIVE' : 'OFF'}
              </span>
            </div>

            <div className="flex items-center justify-between p-2 rounded-xl bg-surface-high/60 border border-outline-variant/30">
              <span className="flex items-center gap-2 text-slate-300">
                <Volume2 className="w-3.5 h-3.5 text-emerald-400" />
                <span>Voice Host & SFX Engines</span>
              </span>
              <span className="text-purple-300 font-semibold">CORTEX-9 ONLINE</span>
            </div>
          </div>
        </div>

        {/* Right 7 Columns: Interactive Configuration Sliders & Toggles */}
        <div className="col-span-7 space-y-6">
          {/* Section 1: MATCH LENGTH (QUESTION COUNT) */}
          <div className="p-6 rounded-3xl bg-surface/85 border border-outline-variant/50 backdrop-blur-md shadow-xl">
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-mono text-cyan-300 flex items-center gap-2">
                <Layers className="w-4 h-4 text-cyan-400" />
                <span>MATCH LENGTH (QUESTION COUNT)</span>
              </span>
              <span className="text-xs font-mono text-slate-500">D-Pad: ◀ / ▶ • [OK]</span>
            </div>
            <p className="text-xs text-slate-400 mb-3">
              Number of questions to play before the Winner Celebration
            </p>

            <div className="grid grid-cols-3 gap-3">
              {[
                { count: 5, label: 'Blitz' },
                { count: 10, label: 'Standard' },
                { count: 15, label: 'Championship' },
              ].map((opt) => {
                const isSelected = currentSettings.questionCount === opt.count;
                return (
                  <TVFocusable
                    key={opt.count}
                    id={`settings-qcount-${opt.count}`}
                    group="settings-qcount"
                    isSelected={isSelected}
                    onActivate={() => handleSetQuestionCount(opt.count)}
                    className={`py-3.5 px-4 rounded-2xl border text-center transition ${
                      isSelected
                        ? 'bg-secondary text-slate-950 font-bold border-secondary shadow-lg'
                        : 'bg-surface/60 border-outline-variant/40 text-slate-200 hover:border-outline'
                    }`}
                  >
                    <div className="font-space font-bold text-base">{opt.count} Questions</div>
                    <div className="text-[11px] font-mono opacity-80">{opt.label}</div>
                  </TVFocusable>
                );
              })}
            </div>
          </div>

          {/* Section 2: COUNTDOWN TIMER PER QUESTION */}
          <div className="p-6 rounded-3xl bg-surface/85 border border-outline-variant/50 backdrop-blur-md shadow-xl">
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-mono text-purple-300 flex items-center gap-2">
                <Clock className="w-4 h-4 text-purple-400" />
                <span>COUNTDOWN TIMER PER QUESTION</span>
              </span>
              <span className="text-xs font-mono text-slate-500">D-Pad: ◀ / ▶ • [OK]</span>
            </div>
            <p className="text-xs text-slate-400 mb-3">
              Response window for sofa buzzers and answer selection
            </p>

            <div className="grid grid-cols-3 gap-3">
              {[
                { sec: 10, label: 'Speed' },
                { sec: 15, label: 'Standard' },
                { sec: 20, label: 'Relaxed' },
              ].map((opt) => {
                const isSelected = currentSettings.timerSeconds === opt.sec;
                return (
                  <TVFocusable
                    key={opt.sec}
                    id={`settings-timer-${opt.sec}`}
                    group="settings-timer"
                    isSelected={isSelected}
                    onActivate={() => handleSetTimerSeconds(opt.sec)}
                    className={`py-3.5 px-4 rounded-2xl border text-center transition ${
                      isSelected
                        ? 'bg-secondary text-slate-950 font-bold border-secondary shadow-lg'
                        : 'bg-surface/60 border-outline-variant/40 text-slate-200 hover:border-outline'
                    }`}
                  >
                    <div className="font-space font-bold text-base">{opt.sec} Seconds</div>
                    <div className="text-[11px] font-mono opacity-80">{opt.label}</div>
                  </TVFocusable>
                );
              })}
            </div>
          </div>

          {/* Section 3: DIFFICULTY ENGINE LEVEL */}
          <div className="p-6 rounded-3xl bg-surface/85 border border-outline-variant/50 backdrop-blur-md shadow-xl">
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-mono text-emerald-300 flex items-center gap-2">
                <Shield className="w-4 h-4 text-emerald-400" />
                <span>DIFFICULTY ENGINE LEVEL</span>
              </span>
              <span className="text-xs font-mono text-slate-500">D-Pad: ◀ / ▶ • [OK]</span>
            </div>
            <p className="text-xs text-slate-400 mb-3">
              Baseline challenge rating across all trivia question categories
            </p>

            <div className="grid grid-cols-4 gap-3">
              {(['EASY', 'MEDIUM', 'HARD', 'ADAPTIVE'] as DifficultyStrategy[]).map((diff) => {
                const isSelected = currentSettings.difficulty === diff;
                return (
                  <TVFocusable
                    key={diff}
                    id={`settings-diff-${diff}`}
                    group="settings-diff"
                    isSelected={isSelected}
                    onActivate={() => handleSetDifficulty(diff)}
                    className={`py-3 px-3 rounded-2xl border text-center transition ${
                      isSelected
                        ? 'bg-secondary text-slate-950 font-bold border-secondary shadow-lg'
                        : 'bg-surface/60 border-outline-variant/40 text-slate-200 hover:border-outline'
                    }`}
                  >
                    <div className="font-space font-bold text-sm">{diff}</div>
                    <div className="text-[10px] font-mono opacity-80">
                      {diff === 'ADAPTIVE' ? 'Dynamic' : 'Fixed'}
                    </div>
                  </TVFocusable>
                );
              })}
            </div>
          </div>

          {/* Action Row: Reset Defaults + Back + Start Game CTA */}
          <div className="flex items-center justify-between pt-2">
            <div className="flex items-center gap-3">
              {onBack && (
                <TVFocusable
                  id="settings-btn-back"
                  group="settings-actions"
                  onActivate={onBack}
                  className="flex items-center gap-2 px-5 py-3.5 rounded-2xl bg-surface border border-outline-variant text-slate-300 text-sm font-semibold hover:text-white transition"
                >
                  <span>Back to Home</span>
                </TVFocusable>
              )}

              <TVFocusable
                id="settings-btn-reset"
                group="settings-actions"
                onActivate={handleResetDefaults}
                className="flex items-center gap-2 px-5 py-3.5 rounded-2xl bg-surface border border-outline-variant text-slate-300 text-sm font-semibold hover:text-white transition"
              >
                <RotateCcw className="w-4 h-4" />
                <span>Reset Defaults</span>
              </TVFocusable>
            </div>

            <TVFocusable
              id="settings-btn-start"
              group="settings-actions"
              onActivate={onStartGame}
              className="flex items-center gap-3 px-10 py-4 rounded-2xl bg-gradient-to-r from-primary-container via-secondary to-cyan-300 text-slate-950 font-space font-bold text-lg tracking-wide shadow-2xl hover:brightness-110 active:scale-95 transition"
            >
              <Play className="w-6 h-6 fill-slate-950" />
              <span>START GAME [OK]</span>
            </TVFocusable>
          </div>
        </div>
      </div>
    </div>
  );
}


export default SettingsScreen;
