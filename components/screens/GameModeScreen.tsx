'use client';

// =============================================================================
// PlayTogether AI — Screen 8: Game Mode & Category Select Screen
// Select Party Trivia, Movie Guess, or AI Surprise, category, and baseline difficulty.
// =============================================================================

import React, { useEffect, useState } from 'react';
import { Film, Rocket, Music, Star, Brain, Sparkles, Zap, ArrowRight, ArrowLeft, ShieldCheck } from 'lucide-react';
import { TVFocusable, useTVFocus } from '../tv/TVFocusManager';
import { Player, GameCategory, GameModeInfo, DifficultyStrategy } from '@/lib/types';

const DEFAULT_CATEGORIES: GameCategory[] = [
  { id: 'cat-1', name: 'Cinema & TV', emoji: '🎬', description: 'Blockbuster classics and modern family favorites', questionCount: 7, orderIndex: 1 },
  { id: 'cat-2', name: 'Science & Cosmos', emoji: '🚀', description: 'Space exploration, astrophysics, and planet biology', questionCount: 7, orderIndex: 2 },
  { id: 'cat-3', name: 'Pop Hits & Music', emoji: '🎵', description: 'Iconic anthems from the 80s to chart toppers', questionCount: 6, orderIndex: 3 },
  { id: 'cat-4', name: 'Animation Universe', emoji: '⭐', description: 'Beloved animated worlds, Pixar, and cartoons', questionCount: 6, orderIndex: 4 },
  { id: 'cat-5', name: 'History & Wonder', emoji: '🧠', description: 'Ancient civilizations, inventors, and landmarks', questionCount: 6, orderIndex: 5 },
];

const DEFAULT_MODES: GameModeInfo[] = [
  { id: 'trivia', title: 'Party Trivia', subtitle: '10 questions, 4 choices', description: 'Fastest path to a polished live demo. Score points per answer.', icon: 'Brain', badge: 'TRIVIA', isAvailable: true },
  { id: 'movie_guess', title: 'Movie Guess', subtitle: 'Clues lead to a movie title', description: 'Guess blockbuster films from quotes, plots, and visual clues.', icon: 'Film', badge: 'MOVIE', isAvailable: true },
  { id: 'ai_surprise', title: 'AI Surprise', subtitle: 'Dynamic adaptive bonus round', description: 'One dynamic living room challenge worth bonus points.', icon: 'Sparkles', badge: 'BONUS ROUND', isAvailable: true },
];

const DEFAULT_PLAYERS: Player[] = [
  { id: 'p1', name: 'Dad (Mark)', avatar: '👨‍💼', accentColor: '#3b82f6', color: '#3b82f6', score: 0, streak: 0 },
  { id: 'p2', name: 'Mom (Sarah)', avatar: '👩‍🏫', accentColor: '#ec4899', color: '#ec4899', score: 0, streak: 0 },
  { id: 'p3', name: 'Leo', avatar: '👦', accentColor: '#10b981', color: '#10b981', score: 0, streak: 0 },
  { id: 'p4', name: 'Grandma (Elena)', avatar: '👵', accentColor: '#f59e0b', color: '#f59e0b', score: 0, streak: 0 },
];

export interface GameModeScreenProps {
  players?: Player[];
  categories?: GameCategory[];
  modes?: GameModeInfo[];
  selectedCategory?: string;
  selectedDifficulty?: DifficultyStrategy;
  onSelectCategory?: (name: string) => void;
  onSelectDifficulty?: (difficulty: DifficultyStrategy) => void;
  onSelectMode?: (modeId: any, category?: any) => void;
  onContinue?: () => void;
  onBack?: () => void;
}

export function GameModeScreen({
  players = DEFAULT_PLAYERS,
  categories = DEFAULT_CATEGORIES,
  modes = DEFAULT_MODES,
  selectedCategory = 'Science & Cosmos',
  selectedDifficulty = 'ADAPTIVE',
  onSelectCategory,
  onSelectDifficulty,
  onSelectMode,
  onContinue,
  onBack,
}: GameModeScreenProps) {
  const { setActiveFocusId } = useTVFocus();
  const [activeModeId, setActiveModeId] = useState<string>('trivia');
  const [activeCat, setActiveCat] = useState<string>(selectedCategory);
  const [activeDiff, setActiveDiff] = useState<DifficultyStrategy>(selectedDifficulty);

  useEffect(() => {
    setActiveFocusId('mode-card-0');
  }, [setActiveFocusId]);

  const difficulties: DifficultyStrategy[] = ['EASY', 'MEDIUM', 'HARD', 'ADAPTIVE'];
  const playerNames = players.map((p) => p.name).join(', ') || 'All Players';

  const getCatIcon = (name: string) => {
    if (name.includes('Cinema')) return <Film className="w-5 h-5 text-purple-400" />;
    if (name.includes('Science')) return <Rocket className="w-5 h-5 text-cyan-400" />;
    if (name.includes('Music') || name.includes('Pop')) return <Music className="w-5 h-5 text-pink-400" />;
    if (name.includes('Animation')) return <Star className="w-5 h-5 text-amber-400" />;
    return <Brain className="w-5 h-5 text-emerald-400" />;
  };

  const handleStart = () => {
    if (onSelectMode) {
      onSelectMode(activeModeId, activeCat);
    } else if (onContinue) {
      onContinue();
    }
  };

  return (
    <div className="relative w-full h-full flex flex-col justify-between px-12 py-4 select-none animate-fadeIn text-white">
      {/* 1. Header Bar */}
      <div className="flex items-center justify-between pb-4 border-b border-outline-variant/40">
        <div className="flex items-center gap-4">
          {onBack && (
            <TVFocusable
              id="mode-btn-back"
              group="mode-header"
              onActivate={onBack}
              className="p-3 rounded-2xl bg-surface border border-outline-variant hover:border-white transition"
            >
              <ArrowLeft className="w-5 h-5 text-slate-300" />
            </TVFocusable>
          )}
          <div>
            <h1 className="font-space font-extrabold text-4xl text-white tracking-tight">
              What should we play?
            </h1>
            <p className="font-outfit text-sm text-slate-400 mt-1">
              Pick a category or let AI adapt to <strong className="text-secondary">{playerNames}</strong>
            </p>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-high border border-outline-variant text-xs font-mono">
            <div className="flex -space-x-1">
              {players.map((p) => (
                <span
                  key={p.id}
                  className="w-4 h-4 rounded-full border border-background text-[9px] font-bold flex items-center justify-center text-slate-950"
                  style={{ backgroundColor: p.color || p.accentColor || '#3b82f6' }}
                >
                  {p.name.charAt(0)}
                </span>
              ))}
            </div>
            <span className="text-slate-300 ml-1.5">{players.length} Players Synced</span>
          </div>

          <TVFocusable
            id="mode-btn-start-top"
            group="mode-header"
            onActivate={handleStart}
            className="flex items-center gap-2 px-6 py-3 rounded-2xl bg-secondary text-slate-950 font-space font-bold text-sm tracking-wide shadow-lg hover:brightness-110 active:scale-95 transition"
          >
            <span>CONTINUE TO SETTINGS [OK]</span>
            <ArrowRight className="w-4 h-4" />
          </TVFocusable>
        </div>
      </div>

      {/* 2. Middle Selection Matrices */}
      <div className="space-y-6 my-4">
        {/* Row A: Game Modes */}
        <div>
          <div className="text-xs font-mono text-slate-400 mb-2.5 flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-secondary" />
            <span>PRIMARY GAME FORMAT:</span>
          </div>

          <div className="grid grid-cols-3 gap-6">
            {modes.map((m, idx) => {
              const isSelected = activeModeId === m.id;
              return (
                <TVFocusable
                  key={m.id}
                  id={`mode-card-${idx}`}
                  group="modes"
                  isSelected={isSelected}
                  onActivate={() => {
                    setActiveModeId(m.id);
                  }}
                  className={`p-5 rounded-2xl border transition flex flex-col justify-between h-36 ${
                    isSelected
                      ? 'bg-secondary/15 border-secondary ring-2 ring-secondary/50'
                      : 'bg-surface/80 border-outline-variant/60 hover:border-secondary'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-mono px-2 py-0.5 rounded-full bg-slate-800 text-secondary border border-secondary/30">
                      {m.badge}
                    </span>
                    <span className="text-xs font-mono text-slate-400 uppercase">MODE 0{idx + 1}</span>
                  </div>

                  <div>
                    <h2 className="font-space font-bold text-xl text-white">{m.title}</h2>
                    <p className="font-outfit text-xs text-slate-300 mt-1 line-clamp-2">
                      {m.description}
                    </p>
                  </div>
                </TVFocusable>
              );
            })}
          </div>
        </div>

        {/* Row B: Category Rail */}
        <div>
          <div className="text-xs font-mono text-slate-400 mb-2.5 flex items-center gap-2">
            <Film className="w-4 h-4 text-cyan-400" />
            <span>KNOWLEDGE CATEGORY:</span>
          </div>

          <div className="grid grid-cols-5 gap-4">
            {categories.map((c, idx) => {
              const isSelected = activeCat === c.name || activeCat === c.id;
              return (
                <TVFocusable
                  key={c.id || idx}
                  id={`mode-cat-${idx}`}
                  group="categories"
                  isSelected={isSelected}
                  onActivate={() => {
                    setActiveCat(c.name);
                    onSelectCategory?.(c.name);
                  }}
                  className={`p-4 rounded-2xl border transition flex flex-col justify-between h-28 ${
                    isSelected
                      ? 'bg-cyan-500/20 border-cyan-400 ring-2 ring-cyan-400/50'
                      : 'bg-surface/80 border-outline-variant/60 hover:border-secondary'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    {getCatIcon(c.name)}
                    <span className="text-[11px] font-mono px-2 py-0.5 rounded-full bg-slate-800 text-slate-300">
                      {c.questionCount || 7} Qs
                    </span>
                  </div>
                  <div>
                    <div className="font-space font-bold text-sm text-white truncate">{c.name}</div>
                    <div className="text-[10px] text-slate-400 mt-0.5 line-clamp-1">{c.description}</div>
                  </div>
                </TVFocusable>
              );
            })}
          </div>
        </div>

        {/* Row C: Difficulty Strategy Rail */}
        <div>
          <div className="text-xs font-mono text-slate-400 mb-2 flex items-center gap-2">
            <Zap className="w-4 h-4 text-amber-400" />
            <span>DIFFICULTY STRATEGY:</span>
          </div>

          <div className="grid grid-cols-4 gap-4">
            {difficulties.map((d, idx) => {
              const isSelected = activeDiff === d;
              return (
                <TVFocusable
                  key={d}
                  id={`mode-diff-${idx}`}
                  group="difficulties"
                  isSelected={isSelected}
                  onActivate={() => {
                    setActiveDiff(d);
                    onSelectDifficulty?.(d);
                  }}
                  className={`p-3.5 rounded-2xl border transition text-center ${
                    isSelected
                      ? 'bg-amber-500/20 border-amber-400 ring-2 ring-amber-400/50'
                      : 'bg-surface/80 border-outline-variant/60 hover:border-secondary'
                  }`}
                >
                  <div className="font-space font-bold text-sm text-white">{d}</div>
                  <div className="text-[10px] font-mono text-slate-400 mt-0.5">
                    {d === 'ADAPTIVE' ? 'Dynamic Real-Time Rebalancing' : 'Fixed Question Complexity'}
                  </div>
                </TVFocusable>
              );
            })}
          </div>
        </div>
      </div>

      {/* 3. Bottom Safe Zone Note */}
      <div className="flex items-center justify-between text-xs font-mono text-slate-400 border-t border-outline-variant/40 pt-3">
        <div className="flex items-center gap-2">
          <ShieldCheck className="w-4 h-4 text-emerald-400" />
          <span>FIRE TV D-PAD: USE ARROW KEYS TO NAVIGATE • [OK] SELECT</span>
        </div>
        <span>PLAYTOGETHER AI • HACKATHON 2026</span>
      </div>
    </div>
  );
}

export default GameModeScreen;
