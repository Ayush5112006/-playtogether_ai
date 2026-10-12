'use client';

// =============================================================================
// PlayTogether AI — Shared TV Top Bar
// Navigation breadcrumbs, CORTEX-9 AI host status, mic trigger, settings, account.
// =============================================================================

import React from 'react';
import { Bot, Mic, Settings, User } from 'lucide-react';
import { TVFocusable } from './TVFocusManager';

export interface SharedTopBarProps {
  currentStep?: number; // 0: Hub, 1: Setup, 2: Game, 3: Settings, 4: Play
  screenState?: any;
  onOpenMic?: () => void;
  onOpenSettings?: () => void;
  onOpenProfile?: () => void;
  onMicTap?: () => void;
  onSettingsTap?: () => void;
  onAccountTap?: () => void;
  onStepTap?: (step: number) => void;
  hostCode?: string;
}

export function SharedTopBar({
  currentStep = 0,
  screenState,
  onOpenMic,
  onOpenSettings,
  onOpenProfile,
  onMicTap,
  onSettingsTap,
  onAccountTap,
  onStepTap,
  hostCode = '8942',
}: SharedTopBarProps) {
  const handleMic = onOpenMic || onMicTap;
  const handleSettings = onOpenSettings || onSettingsTap;
  const handleAccount = onOpenProfile || onAccountTap;
  const steps = [
    { num: 1, label: 'SETUP' },
    { num: 2, label: 'GAME' },
    { num: 3, label: 'SETTINGS' },
    { num: 4, label: 'PLAY' },
  ];

  return (
    <header className="relative z-30 flex items-center justify-between px-10 py-4 bg-background/80 backdrop-blur-md border-b border-outline-variant/40 select-none">
      {/* 1. App Logo & Brand */}
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-primary-inverse to-secondary flex items-center justify-center shadow-lg shadow-primary-container/30">
            <Bot className="w-6 h-6 text-white" />
          </div>
          <span className="font-space font-bold text-2xl tracking-tight text-white">
            PlayTogether <span className="text-secondary">AI</span>
          </span>
        </div>

        {/* 2. Step Breadcrumbs (when in setup/play funnel) */}
        {currentStep > 0 && (
          <div className="hidden lg:flex items-center gap-2 pl-4 border-l border-outline-variant/40 text-xs font-mono">
            <span className="text-secondary font-bold">
              STEP {currentStep} OF 4:
            </span>
            {steps.map((st, idx) => {
              const isCurrent = currentStep === st.num;
              const isPast = currentStep > st.num;
              return (
                <React.Fragment key={st.num}>
                  <button
                    onClick={() => onStepTap?.(st.num)}
                    className={`font-semibold tracking-wider transition ${
                      isCurrent
                        ? 'text-white underline decoration-secondary decoration-2 underline-offset-4'
                        : isPast
                        ? 'text-primary'
                        : 'text-slate-500'
                    }`}
                  >
                    {st.label}
                  </button>
                  {idx < steps.length - 1 && <span className="text-slate-600">•</span>}
                </React.Fragment>
              );
            })}
          </div>
        )}
      </div>

      {/* 3. Right Status Controls */}
      <div className="flex items-center gap-3">
        {/* CORTEX-9 Status Pill */}
        <div className="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-surface-high/80 border border-secondary/30 text-xs font-medium text-slate-200">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
          <span className="font-semibold text-white">CORTEX-9 Active</span>
          <span className="text-slate-400">Host Code: #{hostCode}</span>
        </div>

        {/* Host Listening Mic Action */}
        <TVFocusable
          id="topbar-btn-mic"
          group="topbar"
          onActivate={handleMic}
          className="flex items-center gap-2 px-4 py-1.5 rounded-full bg-purple-950/60 border border-purple-400/40 text-purple-200 hover:bg-purple-900/80 text-xs font-semibold tracking-wide transition"
        >
          <Mic className="w-3.5 h-3.5 text-purple-300" />
          <span>Host Listening</span>
        </TVFocusable>

        {/* Settings Button */}
        <TVFocusable
          id="topbar-btn-settings"
          group="topbar"
          onActivate={handleSettings}
          className="p-2 rounded-xl bg-surface-high/60 border border-outline-variant/50 hover:bg-surface-high text-slate-300 hover:text-white transition"
          aria-label="Settings"
        >
          <Settings className="w-4 h-4" />
        </TVFocusable>

        {/* Account / Profile Dialog Trigger */}
        <TVFocusable
          id="topbar-btn-account"
          group="topbar"
          onActivate={handleAccount}
          className="p-2 rounded-xl bg-surface-high/60 border border-outline-variant/50 hover:bg-surface-high text-slate-300 hover:text-white transition"
          aria-label="Account Profile"
        >
          <User className="w-4 h-4" />
        </TVFocusable>
      </div>
    </header>
  );
}
