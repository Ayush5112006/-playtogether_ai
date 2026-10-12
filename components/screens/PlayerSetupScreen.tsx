'use client';

// =============================================================================
// PlayTogether AI — Screen 6: Player Setup Screen
// Manage 2–8 players, add custom players, edit profiles, shuffle roles, and proceed.
// =============================================================================

import React, { useEffect, useState } from 'react';
import { UserPlus, UserMinus, ArrowRight, Edit3, Shuffle, X, Check, Sparkles, Smile } from 'lucide-react';
import { TVFocusable, useTVFocus } from '../tv/TVFocusManager';
import { Player } from '@/lib/types';

const DEFAULT_SETUP_PLAYERS: Player[] = [
  { id: 'p1', name: 'Dad (Mark)', avatar: '👨‍💼', accentColor: '#3b82f6', color: '#3b82f6', roleTag: 'Family Tactician', score: 0, streak: 0 },
  { id: 'p2', name: 'Mom (Sarah)', avatar: '👩‍🏫', accentColor: '#ec4899', color: '#ec4899', roleTag: 'Pop Culture Queen', score: 0, streak: 0 },
  { id: 'p3', name: 'Leo', avatar: '👦', accentColor: '#10b981', color: '#10b981', roleTag: 'Speed Buzzer Demon', score: 0, streak: 0 },
  { id: 'p4', name: 'Grandma (Elena)', avatar: '👵', accentColor: '#f59e0b', color: '#f59e0b', roleTag: 'History Sage', score: 0, streak: 0 },
];

const QUICK_NAMES = ['Sister', 'Brother', 'Uncle', 'Aunt', 'Grandpa', 'Grandma', 'Cousin', 'Guest'];
const QUICK_AVATARS = ['👧', '👦', '👴', '👵', '👨‍💼', '👩‍🏫', '🎮', '🚀', '🦁', '🦄', '🐱', '🐶'];
const QUICK_COLORS = ['#3b82f6', '#ec4899', '#10b981', '#f59e0b', '#a855f7', '#ef4444', '#06b6d4', '#f97316'];
const QUICK_ROLES = ['Family Tactician', 'Speed Demon', 'Pop Culture Queen', 'Trivia Wizard', 'History Sage', 'Science Prodigy', 'Wildcard'];
const AGE_GROUPS = [
  { id: 'child', label: 'Child (8-12)', icon: '🧒', badge: 'Hints + Extra Time', desc: 'Relaxed timer (+5s) & friendly handicap hints' },
  { id: 'teen', label: 'Teen (13-17)', icon: '🎧', badge: 'Rapid Reflexes', desc: 'Fast reflex challenge & pop trivia' },
  { id: 'adult', label: 'Adult (18-64)', icon: '☕', badge: 'Balanced Play', desc: 'Standard family trivia balance' },
  { id: 'senior', label: 'Senior (65+)', icon: '👓', badge: 'Pacing Boost', desc: 'Pacing boost & classic cultural questions' },
] as const;

export interface PlayerSetupScreenProps {
  players?: Player[];
  onAddPlayer?: (newPlayer?: Player) => void;
  onRemovePlayer?: (id: string) => void;
  onEditPlayer?: (player: Player) => void;
  onShuffleRoles?: () => void;
  onContinue?: () => void;
  onComplete?: (roster: Player[]) => void;
  onBack?: () => void;
}

export function PlayerSetupScreen({
  players = DEFAULT_SETUP_PLAYERS,
  onAddPlayer,
  onRemovePlayer,
  onEditPlayer,
  onShuffleRoles,
  onContinue,
  onComplete,
  onBack,
}: PlayerSetupScreenProps) {
  const [localPlayers, setLocalPlayers] = useState<Player[]>(players);
  const { setActiveFocusId } = useTVFocus();

  // Add Player Modal State
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [newPlayerName, setNewPlayerName] = useState('Sister');
  const [newPlayerAgeGroup, setNewPlayerAgeGroup] = useState<'child' | 'teen' | 'adult' | 'senior'>('child');
  const [newPlayerAvatar, setNewPlayerAvatar] = useState('👧');
  const [newPlayerColor, setNewPlayerColor] = useState('#ec4899');
  const [newPlayerRole, setNewPlayerRole] = useState('Speed Demon');

  useEffect(() => {
    if (players && players.length > 0) {
      setLocalPlayers(players);
    }
  }, [players]);

  useEffect(() => {
    setActiveFocusId('setup-btn-continue-top');
  }, [setActiveFocusId]);

  const handleProceed = () => {
    if (onComplete) onComplete(localPlayers);
    else if (onContinue) onContinue();
  };

  const handleConfirmAddPlayer = () => {
    if (localPlayers.length >= 8) return;
    const trimmed = newPlayerName.trim() || `Player ${localPlayers.length + 1}`;
    const newPlayer: Player = {
      id: `p_${Date.now()}_${Math.random().toString(36).substring(2, 5)}`,
      name: trimmed,
      avatar: newPlayerAvatar,
      ageGroup: newPlayerAgeGroup,
      accentColor: newPlayerColor,
      color: newPlayerColor,
      roleTag: newPlayerRole,
      score: 0,
      streak: 0,
    };
    const updated = [...localPlayers, newPlayer];
    setLocalPlayers(updated);
    setIsAddModalOpen(false);
    onAddPlayer?.(newPlayer);
  };

  const handleRemove = (id: string) => {
    if (localPlayers.length <= 1) return;
    const updated = localPlayers.filter((p) => p.id !== id);
    setLocalPlayers(updated);
    onRemovePlayer?.(id);
  };

  const handleShuffle = () => {
    const roles = [
      'Family Tactician',
      'Pop Culture Queen',
      'Speed Buzzer Demon',
      'History Sage',
      'Science Prodigy',
      'Wildcard Gamer',
      'Movie Maven',
      'Quiz Champion',
    ];
    const shuffled = localPlayers.map((p, idx) => ({
      ...p,
      roleTag: roles[(idx + Math.floor(Math.random() * roles.length)) % roles.length],
    }));
    setLocalPlayers(shuffled);
    onShuffleRoles?.();
  };

  return (
    <div className="relative w-full h-full flex flex-col justify-between px-10 py-3 select-none animate-fadeIn text-white">
      {/* 1. Header Bar */}
      <div className="flex items-center justify-between pb-3 border-b border-outline-variant/40">
        <div>
          <h1 className="font-space font-extrabold text-3xl md:text-4xl text-white tracking-tight flex items-center gap-3">
            <span>Who’s playing?</span>
            <span className="text-secondary text-sm md:text-base font-mono font-normal">
              ({localPlayers.length} players synced • Max 8)
            </span>
          </h1>
          <p className="font-outfit text-xs text-slate-400 mt-0.5">
            Use remote D-Pad [Arrows] to navigate • Press [OK] to select or edit
          </p>
        </div>

        <div className="flex items-center gap-3">
          {localPlayers.length < 8 && (
            <TVFocusable
              id="setup-btn-add-top"
              group="setup-header"
              onActivate={() => setIsAddModalOpen(true)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-cyan-500/20 border border-cyan-400/60 hover:bg-cyan-500/30 text-cyan-300 font-space font-bold text-sm tracking-wide shadow-lg transition"
            >
              <UserPlus className="w-4 h-4 text-cyan-400" />
              <span>+ ADD PLAYER [OK]</span>
            </TVFocusable>
          )}

          <TVFocusable
            id="setup-btn-continue-top"
            group="setup-header"
            onActivate={handleProceed}
            className="flex items-center gap-2 px-6 py-2.5 rounded-2xl bg-secondary text-slate-950 font-space font-bold text-sm tracking-wide shadow-lg hover:brightness-110 active:scale-95 transition"
          >
            <span>CONTINUE [OK]</span>
            <ArrowRight className="w-4 h-4" />
          </TVFocusable>
        </div>
      </div>

      {/* 2. Player Cards Grid (Dynamic 2 to 8 players) */}
      <div className="flex-1 overflow-y-auto py-4 my-auto max-h-[62vh]">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 items-stretch">
          {localPlayers.map((p, idx) => (
            <div
              key={p.id}
              className="p-5 rounded-3xl bg-surface/85 border border-outline-variant/50 backdrop-blur-md shadow-xl flex flex-col items-center text-center justify-between transition hover:border-secondary min-h-[220px]"
            >
              {/* Avatar Circle */}
              <div className="relative mb-2">
                <div
                  className="w-16 h-16 rounded-full flex items-center justify-center text-2xl font-bold shadow-lg"
                  style={{ backgroundColor: p.accentColor || p.color || '#3b82f6' }}
                >
                  {p.avatar && p.avatar.length <= 2 ? p.avatar : p.name.charAt(0)}
                </div>
                <span className="absolute -bottom-1 -right-1 px-2 py-0.5 rounded-full bg-emerald-500 text-slate-950 text-[9px] font-bold font-mono">
                  READY
                </span>
              </div>

              {/* Name & Role Tag & Age Group */}
              <h3 className="font-space font-bold text-xl text-white tracking-tight mb-0.5 truncate max-w-[180px]">
                {p.name}
              </h3>
              <div className="flex items-center gap-1.5 mb-3 max-w-[180px] truncate">
                <span className="px-2 py-0.5 rounded-full bg-amber-500/20 border border-amber-400/40 text-[10px] font-mono font-bold text-amber-300">
                  {p.ageGroup?.toUpperCase() || 'ADULT'}
                </span>
                <span className="px-2.5 py-0.5 rounded-full bg-surface-high border border-outline-variant/50 text-[11px] font-mono text-cyan-300 truncate">
                  {p.roleTag || 'Player'}
                </span>
              </div>

              {/* Action Buttons on Card */}
              <div className="w-full space-y-1.5">
                <TVFocusable
                  id={`setup-card-edit-${idx}`}
                  group="setup-players"
                  onActivate={() => onEditPlayer?.(p)}
                  className="w-full py-2 rounded-xl bg-surface-high hover:bg-surface-highest border border-outline-variant text-xs font-semibold text-slate-200 flex items-center justify-center gap-1.5 transition"
                >
                  <Edit3 className="w-3 h-3 text-secondary" />
                  <span>Edit Profile</span>
                </TVFocusable>

                {localPlayers.length > 1 && (
                  <TVFocusable
                    id={`setup-card-remove-${idx}`}
                    group="setup-players"
                    onActivate={() => handleRemove(p.id)}
                    className="w-full py-1 rounded-xl bg-rose-950/40 hover:bg-rose-900 border border-rose-500/30 text-[10px] font-medium text-rose-300 flex items-center justify-center gap-1 transition"
                  >
                    <UserMinus className="w-3 h-3" />
                    <span>Remove</span>
                  </TVFocusable>
                )}
              </div>
            </div>
          ))}

          {/* "+ Add New Player" Empty Slot Card */}
          {localPlayers.length < 8 && (
            <TVFocusable
              id="setup-card-add-slot"
              group="setup-players"
              onActivate={() => setIsAddModalOpen(true)}
              className="p-5 rounded-3xl border-2 border-dashed border-cyan-400/50 hover:border-cyan-300 bg-cyan-950/15 hover:bg-cyan-950/30 backdrop-blur-md shadow-xl flex flex-col items-center justify-center text-center cursor-pointer transition min-h-[220px]"
            >
              <div className="w-16 h-16 rounded-full bg-cyan-500/20 border border-cyan-400/50 flex items-center justify-center text-cyan-300 mb-3 shadow-lg">
                <UserPlus className="w-8 h-8 text-cyan-400" />
              </div>
              <span className="font-space font-bold text-lg text-white">+ Add Player</span>
              <span className="text-[11px] font-mono text-cyan-300/80 mt-1">
                Slot {localPlayers.length + 1} of 8
              </span>
            </TVFocusable>
          )}
        </div>
      </div>

      {/* 3. Bottom Control Bar: Add Player, Shuffle, Continue */}
      <div className="flex items-center justify-between pt-3 border-t border-slate-800">
        <div className="flex items-center gap-3">
          {localPlayers.length < 8 ? (
            <TVFocusable
              id="setup-btn-add-bottom"
              group="setup-bottom"
              onActivate={() => setIsAddModalOpen(true)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-cyan-500/20 border border-cyan-400/50 text-cyan-300 font-semibold text-xs tracking-wide hover:bg-cyan-500/30 transition"
            >
              <UserPlus className="w-4 h-4" />
              <span>+ Add Player ({localPlayers.length}/8)</span>
            </TVFocusable>
          ) : (
            <span className="text-xs font-mono text-slate-500">
              Maximum 8 Players Reached (Living Room Full)
            </span>
          )}

          <TVFocusable
            id="setup-btn-shuffle"
            group="setup-bottom"
            onActivate={handleShuffle}
            className="flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-surface-high border border-outline-variant text-slate-300 font-semibold text-xs tracking-wide hover:bg-surface-highest transition"
          >
            <Shuffle className="w-4 h-4 text-purple-300" />
            <span>Shuffle Roles</span>
          </TVFocusable>
        </div>

        <TVFocusable
          id="setup-btn-continue-bottom"
          group="setup-bottom"
          onActivate={handleProceed}
          className="flex items-center gap-3 px-8 py-3 rounded-2xl bg-gradient-to-r from-primary-container to-secondary text-slate-950 font-space font-bold text-base tracking-wide shadow-xl hover:brightness-110 active:scale-95 transition"
        >
          <span>CONTINUE TO GAME SELECT [OK]</span>
          <ArrowRight className="w-4 h-4" />
        </TVFocusable>
      </div>

      {/* 4. Add Player Dialog Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-6 animate-fadeIn">
          <div className="w-full max-w-lg rounded-3xl bg-[#0e1222] border border-cyan-500/50 shadow-2xl p-6 text-white space-y-5">
            {/* Modal Header */}
            <div className="flex items-center justify-between pb-3 border-b border-slate-700">
              <div className="flex items-center gap-2">
                <UserPlus className="w-5 h-5 text-cyan-400" />
                <h2 className="font-space font-bold text-2xl text-white">Add New Player</h2>
              </div>
              <button
                onClick={() => setIsAddModalOpen(false)}
                className="p-1 rounded-xl text-slate-400 hover:text-white transition"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Quick Name Suggestions */}
            <div>
              <label className="block text-xs font-mono text-slate-300 mb-1.5">
                PLAYER NAME OR QUICK PICK:
              </label>
              <input
                type="text"
                value={newPlayerName}
                onChange={(e) => setNewPlayerName(e.target.value)}
                maxLength={20}
                className="w-full px-4 py-2.5 rounded-xl bg-surface border border-outline-variant/60 focus:border-secondary text-white font-space font-semibold text-base outline-none mb-2"
                placeholder="Enter player name..."
              />
              <div className="flex flex-wrap gap-1.5">
                {QUICK_NAMES.map((name) => (
                  <button
                    key={name}
                    type="button"
                    onClick={() => setNewPlayerName(name)}
                    className={`px-2.5 py-1 rounded-lg text-xs font-mono transition ${
                      newPlayerName === name
                        ? 'bg-secondary text-slate-950 font-bold'
                        : 'bg-surface-high border border-outline-variant/40 text-slate-300 hover:text-white'
                    }`}
                  >
                    {name}
                  </button>
                ))}
              </div>
            </div>

            {/* Age Group & AI Handicap Tier */}
            <div>
              <label className="block text-xs font-mono text-cyan-300 mb-1.5">
                AGE GROUP & CORTEX-9 AI HANDICAP TIER:
              </label>
              <div className="grid grid-cols-2 gap-2">
                {AGE_GROUPS.map((grp) => {
                  const isSelected = newPlayerAgeGroup === grp.id;
                  return (
                    <button
                      key={grp.id}
                      type="button"
                      onClick={() => setNewPlayerAgeGroup(grp.id as any)}
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

            {/* Avatar & Color Picker */}
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-mono text-slate-300 mb-1.5">AVATAR ICON:</label>
                <div className="grid grid-cols-4 gap-2">
                  {QUICK_AVATARS.map((av) => (
                    <button
                      key={av}
                      type="button"
                      onClick={() => setNewPlayerAvatar(av)}
                      className={`text-xl p-2 rounded-xl transition ${
                        newPlayerAvatar === av
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
                <label className="block text-xs font-mono text-slate-300 mb-1.5">TEAM ACCENT COLOR:</label>
                <div className="grid grid-cols-4 gap-2">
                  {QUICK_COLORS.map((col) => (
                    <button
                      key={col}
                      type="button"
                      onClick={() => setNewPlayerColor(col)}
                      className={`w-9 h-9 rounded-full transition ${
                        newPlayerColor === col
                          ? 'scale-110 ring-4 ring-white shadow-lg'
                          : 'opacity-80 hover:opacity-100'
                      }`}
                      style={{ backgroundColor: col }}
                    />
                  ))}
                </div>
              </div>
            </div>

            {/* Role Tag Picker */}
            <div>
              <label className="block text-xs font-mono text-slate-300 mb-1.5">FAMILY ROLE TAG:</label>
              <div className="flex flex-wrap gap-1.5">
                {QUICK_ROLES.map((role) => (
                  <button
                    key={role}
                    type="button"
                    onClick={() => setNewPlayerRole(role)}
                    className={`px-3 py-1 rounded-lg text-xs font-mono transition ${
                      newPlayerRole === role
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
                id="setup-modal-cancel"
                group="setup-modal"
                onActivate={() => setIsAddModalOpen(false)}
                className="px-5 py-2.5 rounded-xl bg-surface border border-outline-variant text-slate-300 text-sm hover:text-white transition"
              >
                Cancel
              </TVFocusable>
              <TVFocusable
                id="setup-modal-confirm"
                group="setup-modal"
                onActivate={handleConfirmAddPlayer}
                className="flex items-center gap-2 px-6 py-2.5 rounded-xl bg-secondary text-slate-950 font-space font-bold text-sm tracking-wide shadow-lg hover:brightness-110 transition"
              >
                <Check className="w-4 h-4" />
                <span>Add to Room [OK]</span>
              </TVFocusable>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default PlayerSetupScreen;
