'use client';

// =============================================================================
// PlayTogether AI — Screen 7: Player Picker / Profile Editor
// Edit player name, select avatar icon and living room team accent color.
// =============================================================================

import React, { useState } from 'react';
import { ArrowLeft, Check, Sparkles, Smile, Bot, Star, Heart, Flame, Shield } from 'lucide-react';
import { TVFocusable } from '../tv/TVFocusManager';
import { Player } from '@/lib/types';

export interface PlayerPickerScreenProps {
  player?: Player;
  players?: Player[];
  onSave?: (updatedPlayer: Player) => void;
  onConfirmPlayers?: (roster: Player[]) => void;
  onBack?: () => void;
}

const DEFAULT_PICKER_PLAYER: Player = {
  id: 'p-default',
  name: 'Leo',
  avatar: '👦',
  accentColor: '#F59E0B',
  color: '#F59E0B',
  score: 0,
  streak: 0,
};

export function PlayerPickerScreen({
  player: playerProp,
  players,
  onSave,
  onConfirmPlayers,
  onBack,
}: PlayerPickerScreenProps) {
  const activePlayer = playerProp || (players && players[0]) || DEFAULT_PICKER_PLAYER;
  const [name, setName] = useState<string>(activePlayer.name);
  const [selectedColor, setSelectedColor] = useState<string>(activePlayer.accentColor || activePlayer.color || '#F59E0B');
  const [selectedIcon, setSelectedIcon] = useState<string>(activePlayer.iconName || 'smile');
  const [ageGroup, setAgeGroup] = useState<string>(activePlayer.ageGroup || 'adult');
  const [roleTag, setRoleTag] = useState<string>(activePlayer.roleTag || 'Family Tactician');

  React.useEffect(() => {
    setName(activePlayer.name);
    setSelectedColor(activePlayer.accentColor || activePlayer.color || '#F59E0B');
    setSelectedIcon(activePlayer.iconName || 'smile');
    setAgeGroup(activePlayer.ageGroup || 'adult');
    setRoleTag(activePlayer.roleTag || 'Family Tactician');
  }, [activePlayer]);

  const avatarColors = [
    '#FFB0CD', // Pink
    '#7BD0FF', // Cyan
    '#D0BCFF', // Purple
    '#F59E0B', // Gold
    '#34D399', // Emerald
    '#EF4444', // Ruby
  ];

  const avatarIcons = [
    { name: 'smile', icon: Smile, label: 'Happy' },
    { name: 'bot', icon: Bot, label: 'Robot' },
    { name: 'star', icon: Star, label: 'Star' },
    { name: 'heart', icon: Heart, label: 'Heart' },
    { name: 'flame', icon: Flame, label: 'Fire' },
    { name: 'shield', icon: Shield, label: 'Defender' },
  ];

  const handleSave = () => {
    const updated: Player = {
      ...activePlayer,
      name: name.trim() || activePlayer.name,
      accentColor: selectedColor,
      color: selectedColor,
      iconName: selectedIcon,
      ageGroup,
      roleTag,
    };
    if (onConfirmPlayers) {
      const roster = players ? players.map((p) => (p.id === activePlayer.id ? updated : p)) : [updated];
      onConfirmPlayers(roster);
    } else if (onSave) {
      onSave(updated);
    }
  };

  return (
    <div className="relative w-full h-full flex flex-col justify-between px-16 py-6 select-none animate-fadeIn text-white max-w-4xl mx-auto">
      {/* 1. Header */}
      <div className="flex items-center gap-4 pb-4 border-b border-outline-variant/40">
        <TVFocusable
          id="picker-btn-back"
          group="picker-nav"
          onActivate={onBack}
          className="p-3 rounded-2xl bg-surface-high border border-outline-variant text-slate-300 hover:text-white"
        >
          <ArrowLeft className="w-5 h-5" />
        </TVFocusable>
        <div>
          <h1 className="font-space font-bold text-3xl text-white">Edit Player Profile</h1>
          <p className="text-xs text-slate-400">Customize avatar, color, and player name on Fire TV</p>
        </div>
      </div>

      {/* 2. Middle Editor Matrix */}
      <div className="grid grid-cols-12 gap-8 my-4 items-center">
        {/* Left: Avatar Preview */}
        <div className="col-span-4 flex flex-col items-center justify-center p-6 rounded-3xl bg-surface border border-outline-variant/60 shadow-xl text-center">
          <div
            className="w-28 h-28 rounded-full flex items-center justify-center text-4xl font-bold shadow-2xl mb-4 transition-all"
            style={{ backgroundColor: selectedColor }}
          >
            {name.charAt(0).toUpperCase()}
          </div>
          <span className="font-space font-bold text-2xl text-white tracking-wide">{name}</span>
          <span className="text-xs text-secondary font-mono mt-1">{activePlayer.roleTag || 'Contender'}</span>
        </div>

        {/* Right: Customization Controls */}
        <div className="col-span-8 space-y-5">
          {/* Name Input */}
          <div>
            <label className="block text-xs font-mono text-slate-400 mb-1.5">PLAYER NAME:</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              maxLength={16}
              className="w-full px-4 py-3 rounded-2xl bg-surface border border-outline-variant/60 focus:border-secondary text-white font-space font-semibold text-lg outline-none"
            />
          </div>

          {/* Color Rail */}
          <div>
            <label className="block text-xs font-mono text-slate-400 mb-1.5">TEAM ACCENT COLOR:</label>
            <div className="flex items-center gap-3">
              {avatarColors.map((c, idx) => (
                <TVFocusable
                  key={c}
                  id={`picker-color-${idx}`}
                  group="picker-colors"
                  onActivate={() => setSelectedColor(c)}
                  className={`w-12 h-12 rounded-full border-2 transition-transform ${
                    selectedColor === c ? 'scale-110 border-white ring-4 ring-secondary/50' : 'border-transparent'
                  }`}
                  style={{ backgroundColor: c }}
                >
                  <span className="sr-only">{c}</span>
                </TVFocusable>
              ))}
            </div>
          </div>

          {/* Avatar Icon Rail */}
          <div>
            <label className="block text-xs font-mono text-slate-400 mb-1.5">AVATAR ICON:</label>
            <div className="grid grid-cols-6 gap-2">
              {avatarIcons.map((ic, idx) => {
                const IconComp = ic.icon;
                const isSelected = selectedIcon === ic.name;
                return (
                  <TVFocusable
                    key={ic.name}
                    id={`picker-icon-${idx}`}
                    group="picker-icons"
                    onActivate={() => setSelectedIcon(ic.name)}
                    className={`p-3 rounded-2xl border flex flex-col items-center justify-center gap-1 transition ${
                      isSelected
                        ? 'bg-secondary/20 border-secondary text-secondary'
                        : 'bg-surface border-outline-variant/40 text-slate-400 hover:text-white'
                    }`}
                  >
                    <IconComp className="w-5 h-5" />
                    <span className="text-[10px] font-mono">{ic.label}</span>
                  </TVFocusable>
                );
              })}
            </div>
          </div>

          {/* Age Group Selector */}
          <div>
            <label className="block text-xs font-mono text-slate-400 mb-1.5">
              AGE GROUP (CORTEX-9 AI HANDICAP):
            </label>
            <div className="grid grid-cols-4 gap-2">
              {[
                { id: 'child', label: 'Child (8-12)', icon: '🧒' },
                { id: 'teen', label: 'Teen (13-17)', icon: '🎧' },
                { id: 'adult', label: 'Adult (18-64)', icon: '☕' },
                { id: 'senior', label: 'Senior (65+)', icon: '👓' },
              ].map((grp) => {
                const isSelected = ageGroup === grp.id;
                return (
                  <button
                    key={grp.id}
                    type="button"
                    onClick={() => setAgeGroup(grp.id)}
                    className={`py-2 px-2.5 rounded-xl border text-center transition ${
                      isSelected
                        ? 'bg-secondary/20 border-secondary text-secondary font-bold ring-1 ring-secondary'
                        : 'bg-surface border-outline-variant/40 text-slate-300 hover:text-white'
                    }`}
                  >
                    <span className="text-sm mr-1">{grp.icon}</span>
                    <span className="text-xs font-space">{grp.label}</span>
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      {/* 3. Action Buttons */}
      <div className="flex items-center justify-end gap-4 pt-4 border-t border-slate-800">
        <TVFocusable
          id="picker-btn-cancel"
          group="picker-actions"
          onActivate={onBack}
          className="px-6 py-3 rounded-2xl bg-surface border border-outline-variant text-slate-300 font-semibold text-sm hover:text-white"
        >
          Cancel [BACK]
        </TVFocusable>

        <TVFocusable
          id="picker-btn-save"
          group="picker-actions"
          onActivate={handleSave}
          className="flex items-center gap-2 px-8 py-3 rounded-2xl bg-secondary text-slate-950 font-space font-bold text-sm tracking-wide shadow-lg hover:brightness-110 active:scale-95 transition"
        >
          <Check className="w-5 h-5" />
          <span>Save Profile [OK]</span>
        </TVFocusable>
      </div>
    </div>
  );
}

export default PlayerPickerScreen;
