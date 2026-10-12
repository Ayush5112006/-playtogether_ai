'use client';

// =============================================================================
// PlayTogether AI — Screen 2: Home Screen Hub
// Hero presentation, session status, start/continue CTA, dynamic category rail.
// =============================================================================

import React, { useEffect, useState } from 'react';
import { Play, Sparkles, Film, Rocket, Music, Star, Brain, Users, ArrowRight, Settings, UserPlus, UserMinus, X, Check, Baby, Sparkle } from 'lucide-react';
import { TVFocusable, useTVFocus } from '../tv/TVFocusManager';
import { Player, GameCategory } from '@/lib/types';

const DEFAULT_CATEGORIES: GameCategory[] = [
  { id: 'cat-1', name: 'Cinema & TV', emoji: '🎬', description: 'Blockbuster classics and modern family favorites', questionCount: 7, orderIndex: 1 },
  { id: 'cat-2', name: 'Science & Cosmos', emoji: '🚀', description: 'Space exploration, astrophysics, and planet biology', questionCount: 7, orderIndex: 2 },
  { id: 'cat-3', name: 'Pop Hits & Music', emoji: '🎵', description: 'Iconic anthems from the 80s to chart toppers', questionCount: 6, orderIndex: 3 },
  { id: 'cat-4', name: 'Animation Universe', emoji: '⭐', description: 'Beloved animated worlds, Pixar, and cartoons', questionCount: 6, orderIndex: 4 },
  { id: 'cat-5', name: 'History & Wonder', emoji: '🧠', description: 'Ancient civilizations, inventors, and landmarks', questionCount: 6, orderIndex: 5 },
];

const DEFAULT_PLAYERS: Player[] = [
  { id: 'p1', name: 'Dad (Mark)', avatar: '👨‍💼', ageGroup: 'adult', roleTag: 'Family Tactician', accentColor: '#3b82f6', color: '#3b82f6', score: 450, streak: 3 },
  { id: 'p2', name: 'Mom (Sarah)', avatar: '👩‍🏫', ageGroup: 'adult', roleTag: 'Pop Culture Queen', accentColor: '#ec4899', color: '#ec4899', score: 380, streak: 1 },
  { id: 'p3', name: 'Leo', avatar: '👦', ageGroup: 'child', roleTag: 'Speed Buzzer Demon', accentColor: '#10b981', color: '#10b981', score: 520, streak: 4 },
  { id: 'p4', name: 'Grandma (Elena)', avatar: '👵', ageGroup: 'senior', roleTag: 'History Sage', accentColor: '#f59e0b', color: '#f59e0b', score: 410, streak: 2 },
];

const QUICK_NAMES = ['Leo', 'Sister', 'Brother', 'Grandpa', 'Grandma', 'Uncle', 'Aunt', 'Cousin', 'Guest'];
const QUICK_AVATARS = ['👦', '👧', '👨‍💼', '👩‍🏫', '👴', '👵', '🎮', '🚀', '🦁', '🦄', '🐱', '🐶'];
const QUICK_COLORS = ['#3b82f6', '#ec4899', '#10b981', '#f59e0b', '#a855f7', '#ef4444', '#06b6d4', '#f97316'];
const QUICK_ROLES = ['Family Tactician', 'Speed Demon', 'Pop Culture Queen', 'History Sage', 'Science Prodigy', 'Wildcard'];
const AGE_GROUPS = [
  { id: 'child', label: 'Child (8-12)', icon: '🧒', badge: 'Hints + Extra Time', desc: 'Relaxed timer (+5s) & AI hints' },
  { id: 'teen', label: 'Teen (13-17)', icon: '🎧', badge: 'Rapid Reflexes', desc: 'Fast reflex challenge & pop trivia' },
  { id: 'adult', label: 'Adult (18-64)', icon: '☕', badge: 'Balanced Play', desc: 'Standard family trivia balance' },
  { id: 'senior', label: 'Senior (65+)', icon: '👓', badge: 'Pacing Boost', desc: 'Pacing boost & classic trivia' },
] as const;

export interface HomeScreenProps {
  players?: Player[];
  sessionId?: string;
  categories?: GameCategory[];
  totalQuestionsCount?: number;
  onStartGame?: () => void;
  onContinueSession?: () => void;
  onSelectCategory?: (categoryName: string) => void;
  onQuickPlay?: () => void;
  onCustomGame?: () => void;
  onSettings?: () => void;
  onAddFamilyMember?: (newMember: Player) => void;
  onRemoveFamilyMember?: (id: string) => void;
}

export function HomeScreen({
  players = DEFAULT_PLAYERS,
  sessionId = 'PLAY-26',
  categories = DEFAULT_CATEGORIES,
  totalQuestionsCount = 32,
  onStartGame,
  onContinueSession,
  onSelectCategory,
  onQuickPlay,
  onCustomGame,
  onSettings,
  onAddFamilyMember,
  onRemoveFamilyMember,
}: HomeScreenProps) {
  const { setActiveFocusId } = useTVFocus();
  const [selectedCatIndex, setSelectedCatIndex] = useState<number>(0);

  // Add Family Member Modal State
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [newMemberName, setNewMemberName] = useState('Sister');
  const [newMemberAgeGroup, setNewMemberAgeGroup] = useState<'child' | 'teen' | 'adult' | 'senior'>('child');
  const [newMemberAvatar, setNewMemberAvatar] = useState('👧');
  const [newMemberColor, setNewMemberColor] = useState('#ec4899');
  const [newMemberRole, setNewMemberRole] = useState('Speed Demon');

  // Set default focus to Start A Game button
  useEffect(() => {
    setActiveFocusId('home-btn-start');
  }, [setActiveFocusId]);

  const cleanSessionCode = (sessionId || 'PLAY-26').replace('session_', '').toUpperCase().slice(0, 10);

  const getCategoryIcon = (name: string) => {
    if (name.includes('Cinema')) return <Film className="w-5 h-5 text-purple-400" />;
    if (name.includes('Science')) return <Rocket className="w-5 h-5 text-cyan-400" />;
    if (name.includes('Music') || name.includes('Pop')) return <Music className="w-5 h-5 text-pink-400" />;
    if (name.includes('Animation')) return <Star className="w-5 h-5 text-amber-400" />;
    return <Brain className="w-5 h-5 text-emerald-400" />;
  };

  const handleStart = () => {
    if (onQuickPlay) onQuickPlay();
    else if (onStartGame) onStartGame();
  };

  const handleCustom = () => {
    if (onCustomGame) onCustomGame();
    else if (onContinueSession) onContinueSession();
  };

  const handleConfirmAdd = () => {
    if (players.length >= 8) return;
    const trimmed = newMemberName.trim() || `Player ${players.length + 1}`;
    const newMember: Player = {
      id: `p_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
      name: trimmed,
      avatar: newMemberAvatar,
      ageGroup: newMemberAgeGroup,
      roleTag: newMemberRole,
      color: newMemberColor,
      accentColor: newMemberColor,
      score: 0,
      streak: 0,
    };
    onAddFamilyMember?.(newMember);
    setIsAddModalOpen(false);
    // Cycle defaults for next add
    setNewMemberName('Brother');
    setNewMemberAvatar('👦');
    setNewMemberColor('#10b981');
    setNewMemberRole('Wildcard');
    setNewMemberAgeGroup('teen');
  };

  return (
    <div className="relative w-full h-full flex flex-col justify-between px-10 py-4 select-none animate-fadeIn text-white">
      {/* 1. Main Upper Arena: Split into Left Hero (8 cols) & Right Player Matrix (4 cols) */}
      <div className="grid grid-cols-12 gap-8 items-start">
        {/* Left 8 Columns: Hero Canvas */}
        <div className="col-span-8 p-8 rounded-3xl bg-surface/75 border border-outline-variant/50 backdrop-blur-md shadow-2xl relative overflow-hidden">
          {/* Status Badges */}
          <div className="flex items-center gap-3 mb-6">
            <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-cyan-950/60 border border-cyan-400/40 text-xs font-mono text-cyan-300">
              <span className="w-2 h-2 rounded-full bg-cyan-400 animate-ping" />
              <span>DATABASE SESSION #{cleanSessionCode} ACTIVE</span>
            </div>
            <div className="px-3 py-1 rounded-full bg-surface-high border border-outline-variant/60 text-xs font-mono text-slate-300">
              {totalQuestionsCount} VERIFIED SEED QUESTIONS READY
            </div>
          </div>

          <h1 className="font-space text-5xl font-extrabold text-white tracking-tight leading-tight mb-4">
            One TV. One Remote.<br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-400 via-pink-400 to-purple-400">
              Every Generation Plays.
            </span>
          </h1>

          <p className="font-outfit text-base text-slate-300 max-w-2xl mb-8 leading-relaxed">
            AI-driven adaptive family trivia tailored for Amazon Fire TV. Dynamically balances difficulty between kids, adults, and seniors so everyone stays engaged.
          </p>

          {/* Action Button Row */}
          <div className="flex items-center gap-4">
            <TVFocusable
              id="home-btn-start"
              group="home-actions"
              onActivate={handleStart}
              className="px-8 py-4 rounded-2xl bg-gradient-to-r from-amber-400 via-orange-500 to-amber-500 text-slate-950 font-space font-bold text-lg flex items-center gap-3 shadow-lg shadow-amber-500/25 ring-2 ring-white/50"
            >
              <Play className="w-5 h-5 fill-slate-950" />
              <span>QUICK PLAY</span>
              <span className="text-xs px-2 py-0.5 rounded bg-black/20 text-black font-mono">OK</span>
            </TVFocusable>

            <TVFocusable
              id="home-btn-custom"
              group="home-actions"
              onActivate={handleCustom}
              className="px-6 py-4 rounded-2xl bg-surface border border-outline-variant hover:border-secondary text-white font-space font-semibold text-base flex items-center gap-2 transition"
            >
              <Sparkles className="w-5 h-5 text-purple-400" />
              <span>CUSTOM MODE</span>
            </TVFocusable>

            {onSettings && (
              <TVFocusable
                id="home-btn-settings"
                group="home-actions"
                onActivate={onSettings}
                className="px-5 py-4 rounded-2xl bg-surface border border-outline-variant hover:border-secondary text-white font-space font-semibold text-base flex items-center gap-2 transition"
              >
                <Settings className="w-5 h-5 text-slate-300" />
                <span>SETTINGS</span>
              </TVFocusable>
            )}
          </div>
        </div>

        {/* Right 4 Columns: Living Room Roster Card */}
        <div className="col-span-4 p-5 rounded-3xl bg-surface/85 border border-outline-variant/60 backdrop-blur-md shadow-xl flex flex-col justify-between max-h-[460px]">
          <div>
            <div className="flex items-center justify-between mb-3 border-b border-outline-variant/40 pb-2.5">
              <div className="flex items-center gap-2">
                <Users className="w-4 h-4 text-secondary" />
                <span className="font-space font-bold text-sm tracking-wide text-white uppercase">
                  Living Room Roster
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-xs font-mono text-cyan-300">{players.length}/8 Active</span>
                {players.length < 8 && (
                  <TVFocusable
                    id="home-btn-add-member"
                    group="home-roster"
                    onActivate={() => setIsAddModalOpen(true)}
                    className="flex items-center gap-1 px-2.5 py-1 rounded-xl bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-400/50 text-cyan-300 font-space font-bold text-xs tracking-wide shadow transition"
                  >
                    <UserPlus className="w-3.5 h-3.5" />
                    <span>+ ADD</span>
                  </TVFocusable>
                )}
              </div>
            </div>

            <div className="space-y-2 max-h-[290px] overflow-y-auto pr-1">
              {players.map((p) => {
                const color = p.color || p.accentColor || '#3b82f6';
                const ageLabel = p.ageGroup ? p.ageGroup.toUpperCase() : 'ADULT';
                return (
                  <div
                    key={p.id}
                    className="group flex items-center justify-between p-2.5 rounded-2xl bg-surface-high/60 border border-outline-variant/40 hover:border-secondary/50 transition"
                  >
                    <div className="flex items-center gap-2.5">
                      <div
                        className="w-9 h-9 rounded-xl flex items-center justify-center text-lg font-bold shadow flex-shrink-0"
                        style={{ backgroundColor: `${color}30`, border: `2px solid ${color}` }}
                      >
                        <span style={{ color }}>{p.avatar || p.name.charAt(0)}</span>
                      </div>
                      <div className="min-w-0">
                        <div className="font-space font-bold text-sm text-white truncate max-w-[140px]">{p.name}</div>
                        <div className="flex items-center gap-1.5 text-[10px] font-mono text-slate-400 truncate">
                          <span className="px-1.5 py-0.2 rounded bg-surface border border-outline-variant/40 text-amber-300 font-semibold">
                            {ageLabel}
                          </span>
                          <span className="truncate">{p.roleTag || 'Contender'}</span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center gap-2">
                      <div className="text-right">
                        <span className="font-mono font-bold text-sm text-secondary">{p.score}</span>
                        <span className="text-[9px] text-slate-500 block uppercase">PTS</span>
                      </div>
                      {players.length > 2 && onRemoveFamilyMember && (
                        <button
                          type="button"
                          onClick={() => onRemoveFamilyMember(p.id)}
                          title="Remove player"
                          className="opacity-40 group-hover:opacity-100 p-1 rounded-lg text-rose-400 hover:text-rose-200 hover:bg-rose-950/40 transition"
                        >
                          <UserMinus className="w-3.5 h-3.5" />
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Quick Add Slot Button at bottom of roster */}
          {players.length < 8 && (
            <div className="pt-2 border-t border-outline-variant/30 mt-2">
              <TVFocusable
                id="home-btn-add-slot"
                group="home-roster"
                onActivate={() => setIsAddModalOpen(true)}
                className="w-full py-2 rounded-xl border border-dashed border-cyan-400/50 hover:border-cyan-300 bg-cyan-950/20 hover:bg-cyan-900/30 text-cyan-300 text-xs font-space font-bold flex items-center justify-center gap-1.5 transition"
              >
                <UserPlus className="w-3.5 h-3.5 text-cyan-400" />
                <span>+ Add Family Member (Slot {players.length + 1} of 8) [OK]</span>
              </TVFocusable>
            </div>
          )}
        </div>
      </div>

      {/* 2. Bottom Rail: Available Database Categories */}
      <div className="mt-4">
        <div className="flex items-center justify-between mb-2 px-1">
          <div className="text-xs font-mono text-slate-400 tracking-wider uppercase flex items-center gap-2">
            <span>SELECT EXPERIENCE</span>
            <span className="text-slate-600">•</span>
            <span className="text-white font-bold">Database Quiz Categories</span>
          </div>
          <span className="text-xs font-mono text-slate-500">D-Pad: ◀ / ▶ • [OK] Select</span>
        </div>

        <div className="grid grid-cols-5 gap-4">
          {categories.map((cat, idx) => (
            <TVFocusable
              key={cat.id || idx}
              id={`home-cat-${idx}`}
              group="home-categories"
              isSelected={selectedCatIndex === idx}
              onActivate={() => {
                setSelectedCatIndex(idx);
                if (onSelectCategory) {
                  onSelectCategory(cat.name);
                } else if (onQuickPlay) {
                  onQuickPlay();
                } else if (onStartGame) {
                  onStartGame();
                }
              }}
              className="p-4 rounded-2xl bg-surface border border-outline-variant/50 hover:border-secondary transition flex flex-col justify-between h-24"
            >
              <div className="flex items-center justify-between">
                {getCategoryIcon(cat.name)}
                <span className="text-[11px] font-mono px-2 py-0.5 rounded-full bg-slate-800 text-cyan-300">
                  {cat.questionCount || 7} Qs
                </span>
              </div>
              <div className="font-space font-semibold text-sm text-white truncate">
                {cat.name}
              </div>
            </TVFocusable>
          ))}
        </div>
      </div>

      {/* 3. Add Family Member Dialog Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-6 animate-fadeIn">
          <div className="w-full max-w-xl rounded-3xl bg-[#0e1222] border border-cyan-500/60 shadow-2xl p-6 text-white space-y-4 max-h-[92vh] overflow-y-auto">
            {/* Header */}
            <div className="flex items-center justify-between pb-3 border-b border-slate-700">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-xl bg-cyan-500/20 border border-cyan-400/40 flex items-center justify-center">
                  <UserPlus className="w-5 h-5 text-cyan-400" />
                </div>
                <div>
                  <h2 className="font-space font-bold text-xl text-white">Add Family Member</h2>
                  <p className="text-xs text-slate-400 font-outfit">Personalize family profile & AI handicap tier for One-TV living room fun</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setIsAddModalOpen(false)}
                className="p-1.5 rounded-xl text-slate-400 hover:text-white hover:bg-surface-high transition"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Field 1: Name and Quick Picks */}
            <div>
              <label className="block text-xs font-mono text-cyan-300 mb-1.5">
                FAMILY MEMBER NAME OR QUICK PICK:
              </label>
              <input
                type="text"
                value={newMemberName}
                onChange={(e) => setNewMemberName(e.target.value)}
                maxLength={20}
                className="w-full px-4 py-2.5 rounded-xl bg-surface border border-outline-variant/60 focus:border-secondary text-white font-space font-semibold text-base outline-none mb-2"
                placeholder="Enter name (e.g., Leo, Mom, Grandpa)..."
              />
              <div className="flex flex-wrap gap-1.5">
                {QUICK_NAMES.map((name) => (
                  <button
                    key={name}
                    type="button"
                    onClick={() => setNewMemberName(name)}
                    className={`px-2.5 py-1 rounded-lg text-xs font-mono transition ${
                      newMemberName === name
                        ? 'bg-secondary text-slate-950 font-bold'
                        : 'bg-surface-high border border-outline-variant/40 text-slate-300 hover:text-white'
                    }`}
                  >
                    {name}
                  </button>
                ))}
              </div>
            </div>

            {/* Field 2: Age Group & AI Handicap Tier */}
            <div>
              <label className="block text-xs font-mono text-cyan-300 mb-1.5">
                AGE GROUP & CORTEX-9 AI HANDICAP TIER:
              </label>
              <div className="grid grid-cols-2 gap-2">
                {AGE_GROUPS.map((grp) => {
                  const isSelected = newMemberAgeGroup === grp.id;
                  return (
                    <button
                      key={grp.id}
                      type="button"
                      onClick={() => setNewMemberAgeGroup(grp.id as any)}
                      className={`p-2.5 rounded-xl border text-left transition ${
                        isSelected
                          ? 'bg-secondary/20 border-secondary ring-1 ring-secondary'
                          : 'bg-surface-high/60 border-outline-variant/40 hover:bg-surface-high'
                      }`}
                    >
                      <div className="flex items-center justify-between mb-1">
                        <span className="font-space font-bold text-sm text-white flex items-center gap-1.5">
                          <span>{grp.icon}</span>
                          <span>{grp.label}</span>
                        </span>
                        <span className={`text-[9px] font-mono px-1.5 py-0.5 rounded ${
                          isSelected ? 'bg-secondary text-slate-950 font-bold' : 'bg-slate-800 text-slate-300'
                        }`}>
                          {grp.badge}
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-400 font-outfit">{grp.desc}</p>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Field 3: Avatar Emoji Picker & Team Color */}
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-mono text-cyan-300 mb-1.5">AVATAR ICON:</label>
                <div className="grid grid-cols-4 gap-1.5">
                  {QUICK_AVATARS.map((av) => (
                    <button
                      key={av}
                      type="button"
                      onClick={() => setNewMemberAvatar(av)}
                      className={`text-xl p-2 rounded-xl transition ${
                        newMemberAvatar === av
                          ? 'bg-secondary/30 ring-2 ring-secondary scale-105'
                          : 'bg-surface/80 hover:bg-surface-high'
                      }`}
                    >
                      {av}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-xs font-mono text-cyan-300 mb-1.5">TEAM ACCENT COLOR:</label>
                <div className="grid grid-cols-4 gap-2 pt-1">
                  {QUICK_COLORS.map((col) => (
                    <button
                      key={col}
                      type="button"
                      onClick={() => setNewMemberColor(col)}
                      className={`w-9 h-9 rounded-full transition ${
                        newMemberColor === col
                          ? 'scale-110 ring-4 ring-white shadow-lg'
                          : 'opacity-80 hover:opacity-100'
                      }`}
                      style={{ backgroundColor: col }}
                    />
                  ))}
                </div>
              </div>
            </div>

            {/* Field 4: Role Tag Picker */}
            <div>
              <label className="block text-xs font-mono text-cyan-300 mb-1.5">FAMILY ROLE ARCHETYPE:</label>
              <div className="flex flex-wrap gap-1.5">
                {QUICK_ROLES.map((role) => (
                  <button
                    key={role}
                    type="button"
                    onClick={() => setNewMemberRole(role)}
                    className={`px-2.5 py-1 rounded-lg text-xs font-mono transition ${
                      newMemberRole === role
                        ? 'bg-purple-600 text-white font-bold ring-2 ring-purple-400'
                        : 'bg-surface-high border border-outline-variant/40 text-slate-300 hover:text-white'
                    }`}
                  >
                    {role}
                  </button>
                ))}
              </div>
            </div>

            {/* Modal Actions */}
            <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-800">
              <TVFocusable
                id="modal-btn-cancel"
                group="add-member-modal"
                onActivate={() => setIsAddModalOpen(false)}
                className="px-5 py-2.5 rounded-xl bg-surface border border-outline-variant text-slate-300 text-xs font-bold hover:text-white transition"
              >
                Cancel [BACK]
              </TVFocusable>
              <TVFocusable
                id="modal-btn-confirm"
                group="add-member-modal"
                onActivate={handleConfirmAdd}
                className="flex items-center gap-2 px-6 py-2.5 rounded-xl bg-secondary text-slate-950 font-space font-bold text-xs tracking-wide shadow-lg hover:brightness-110 active:scale-95 transition"
              >
                <Check className="w-4 h-4" />
                <span>Add Family Member [OK]</span>
              </TVFocusable>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default HomeScreen;
