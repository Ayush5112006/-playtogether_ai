'use client';

import React, { useState, useEffect, useCallback } from 'react';
import TVFocusManager, { playTVSound } from '@/components/tv/TVFocusManager';
import AnimatedAINetworkBackground from '@/components/tv/AnimatedAINetworkBackground';
import { SharedTopBar } from '@/components/tv/SharedTopBar';
import { SharedBottomHud } from '@/components/tv/SharedBottomHud';
import { HostListeningDialog } from '@/components/tv/HostListeningDialog';
import { AccountProfileDialog } from '@/components/tv/AccountProfileDialog';

// Screens
import { SplashScreen } from '@/components/screens/SplashScreen';
import { HomeScreen } from '@/components/screens/HomeScreen';
import { GameModeScreen } from '@/components/screens/GameModeScreen';
import { PlayerSetupScreen } from '@/components/screens/PlayerSetupScreen';
import { PlayerPickerScreen } from '@/components/screens/PlayerPickerScreen';
import { SettingsScreen } from '@/components/screens/SettingsScreen';
import { GeneratingScreen } from '@/components/screens/GeneratingScreen';
import { RoundIntroScreen } from '@/components/screens/RoundIntroScreen';
import { GameplayScreen } from '@/components/screens/GameplayScreen';
import { AnswerResultScreen } from '@/components/screens/AnswerResultScreen';
import ScoreUpdateScreen from '@/components/screens/ScoreUpdateScreen';
import AiAdaptationScreen from '@/components/screens/AiAdaptationScreen';
import SurpriseRoundScreen from '@/components/screens/SurpriseRoundScreen';
import FinalRoundScreen from '@/components/screens/FinalRoundScreen';
import WinnerScreen from '@/components/screens/WinnerScreen';
import RecapScreen from '@/components/screens/RecapScreen';

import { ScreenState, canTransition, resolveBackState } from '@/lib/game-engine/state-machine';
import { Session, Player, Question, GameMode, AnswerResult, GameSettings } from '@/lib/types';
import { SEED_QUESTIONS } from '@/lib/game-engine/seed-questions';

function normalizeCategoryToSeed(categoryName: string): string {
  const lower = (categoryName || '').toLowerCase().trim();
  if (lower.includes('cinema') || lower.includes('tv') || lower.includes('movie') || lower.includes('film')) {
    return 'Cinema Clues';
  }
  if (lower.includes('science') || lower.includes('cosmos') || lower.includes('space')) {
    return 'Science & Cosmos';
  }
  if (lower.includes('pop') || lower.includes('music') || lower.includes('hit') || lower.includes('song')) {
    return 'Pop Culture & Music';
  }
  if (lower.includes('animation') || lower.includes('universe') || lower.includes('family') || lower.includes('disney')) {
    return 'Animation & Family';
  }
  if (lower.includes('history') || lower.includes('wonder') || lower.includes('general') || lower.includes('trivia')) {
    return 'General Knowledge';
  }
  return categoryName || 'Science & Cosmos';
}

// Default Demo Family Roster
const DEFAULT_PLAYERS: Player[] = [
  { id: 'p1', name: 'Dad (Mark)', avatar: '👨‍💼', ageGroup: 'adult', score: 0, streak: 0, color: '#3b82f6' },
  { id: 'p2', name: 'Mom (Sarah)', avatar: '👩‍🏫', ageGroup: 'adult', score: 0, streak: 0, color: '#ec4899' },
  { id: 'p3', name: 'Leo', avatar: '👦', ageGroup: 'child', score: 0, streak: 0, color: '#10b981' },
  { id: 'p4', name: 'Grandma (Elena)', avatar: '👵', ageGroup: 'senior', score: 0, streak: 0, color: '#f59e0b' },
];

export default function TVApplication() {
  // Navigation & State
  const [currentScreen, setCurrentScreen] = useState<ScreenState>('SPLASH');
  const [isMicOpen, setIsMicOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);

  // Game Match State
  const [session, setSession] = useState<Session | null>(null);
  const [players, setPlayers] = useState<Player[]>(DEFAULT_PLAYERS);
  const [selectedMode, setSelectedMode] = useState<GameMode>('family-adaptive');
  const [selectedCategory, setSelectedCategory] = useState<string>('science');
  const [questions, setQuestions] = useState<Question[]>([]);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [activePlayerIndex, setActivePlayerIndex] = useState(0);
  const [editingPlayer, setEditingPlayer] = useState<Player | null>(null);

  // Settings State
  const [gameSettings, setGameSettings] = useState<GameSettings>({
    questionCount: 5,
    timerSeconds: 15,
    difficulty: 'ADAPTIVE',
    persona: 'Playful Host',
    adaptiveHandicap: true,
    voiceHostEnabled: true,
    sfxEnabled: true,
    reducedMotion: false,
    highContrast: false,
  });

  // Result & Scoring State
  const [lastAnswerResult, setLastAnswerResult] = useState<AnswerResult | null>(null);
  const [lastScoredPlayerId, setLastScoredPlayerId] = useState<string | null>(null);
  const [lastPointsEarned, setLastPointsEarned] = useState<number>(0);
  const [hasAdaptationTriggered, setHasAdaptationTriggered] = useState(false);
  const [hasSurpriseTriggered, setHasSurpriseTriggered] = useState(false);
  const [isBuzzerActive, setIsBuzzerActive] = useState(false);


  // Safe State Transition Function
  const transitionTo = useCallback((nextScreen: ScreenState) => {
    setCurrentScreen((prev) => {
      if (canTransition(prev, nextScreen)) {
        return nextScreen;
      }
      console.warn(`[State Machine] Transition blocked: ${prev} -> ${nextScreen}. Forcing safe transition.`);
      return nextScreen;
    });
  }, []);

  // Hardware Back Key Handler
  const handleBack = useCallback(() => {
    if (isMicOpen) {
      setIsMicOpen(false);
      return;
    }
    if (isProfileOpen) {
      setIsProfileOpen(false);
      return;
    }
    if (currentScreen === 'SETTINGS') {
      transitionTo('HOME');
      return;
    }

    const fallback = resolveBackState(currentScreen);
    if (fallback) {
      transitionTo(fallback);
    }
  }, [currentScreen, isMicOpen, isProfileOpen, transitionTo]);

  // Start Game Generation Process
  const handleStartGeneration = useCallback(async (
    activePlayers: Player[],
    mode: GameMode,
    category: string,
    customSettings?: GameSettings
  ) => {
    const currentSettings = customSettings || gameSettings;
    setPlayers(activePlayers);
    setSelectedMode(mode);
    setSelectedCategory(category);
    transitionTo('GENERATING');

    const totalQCount = currentSettings.questionCount || 5;

    try {
      // Create session in backend or fallback locally
      const res = await fetch('/api/sessions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          difficulty: currentSettings.difficulty || 'ADAPTIVE',
          category,
          settings: currentSettings,
          players: activePlayers.map((p) => ({
            id: p.id,
            name: p.name,
            avatarName: p.avatar || 'default',
            accentColor: p.accentColor || p.color || '#3b82f6',
            roleTag: p.roleTag || 'Player',
            score: 0,
            streak: 0,
          })),
        }),
      });

      if (res.ok) {
        const data = await res.json();
        setSession(data.session || {
          id: data.sessionId || `session-${Date.now()}`,
          joinCode: 'PLAY-26',
          mode,
          category,
          status: 'in_progress',
          currentRound: 1,
          totalRounds: totalQCount,
          currentQuestionIndex: 0,
          currentDifficulty: 2,
          players: activePlayers,
          adaptivePacing: 'normal',
          createdAt: new Date().toISOString(),
        });
        if (data.session?.players) {
          setPlayers(data.session.players);
        }
      } else {
        // Fallback local session
        const mockSession: Session = {
          id: `local-${Date.now()}`,
          joinCode: 'PLAY-26',
          mode,
          category,
          status: 'in_progress',
          currentRound: 1,
          totalRounds: totalQCount,
          currentQuestionIndex: 0,
          currentDifficulty: 2,
          players: activePlayers,
          adaptivePacing: 'normal',
          createdAt: new Date().toISOString(),
        };
        setSession(mockSession);
      }

      // Filter questions matching category or default pool
      const targetCategory = normalizeCategoryToSeed(category);
      const matched = SEED_QUESTIONS.filter((q) => {
        if (!category || category === 'mixed') return true;
        return (
          q.category === targetCategory ||
          q.category.toLowerCase() === targetCategory.toLowerCase() ||
          normalizeCategoryToSeed(q.category) === targetCategory
        );
      });
      const roundQuestions =
        matched.length >= totalQCount
          ? matched.slice(0, totalQCount)
          : matched.length > 0
          ? matched
          : SEED_QUESTIONS.slice(0, totalQCount);
      setQuestions(roundQuestions.length > 0 ? roundQuestions : SEED_QUESTIONS.slice(0, 5));
      setCurrentQuestionIndex(0);
      setActivePlayerIndex(0);
      setHasAdaptationTriggered(false);
      setHasSurpriseTriggered(false);

      setTimeout(() => {
        transitionTo('ROUND_INTRO');
      }, 1800);
    } catch (err) {
      console.error('Session creation error:', err);
      // Fallback
      setQuestions(SEED_QUESTIONS.slice(0, totalQCount));
      setCurrentQuestionIndex(0);
      setTimeout(() => {
        transitionTo('ROUND_INTRO');
      }, 1500);
    }
  }, [gameSettings, transitionTo]);


  // Answer Submission Handler
  const handleAnswerSubmit = useCallback(async (optionId: string, responseTimeMs: number) => {
    const currentQuestion = questions[currentQuestionIndex];
    const answeringPlayer = players[activePlayerIndex % players.length];
    if (!currentQuestion || !answeringPlayer) return;

    const hadBuzzer = isBuzzerActive;

    try {
      const sessionId = session?.id || 'local-session';
      const res = await fetch(`/api/sessions/${sessionId}/answer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          playerId: answeringPlayer.id,
          questionId: currentQuestion.id,
          selectedOptionId: optionId,
          responseTimeMs,
        }),
      });

      if (res.ok) {
        const data = await res.json();
        const buzzerBoost = hadBuzzer && data.correct ? 100 : 0;
        const totalDelta = data.scoreDelta + buzzerBoost;

        const result: AnswerResult = {
          correct: data.correct,
          isCorrect: data.correct,
          pointsEarned: totalDelta,
          scoreDelta: totalDelta,
          streak: data.streak,
          correctOptionId: data.correctOptionId,
          explanation: data.explanation,
          buzzerBonusApplied: hadBuzzer && data.correct,
          speedBonusApplied: data.speedBonusApplied || (data.correct && responseTimeMs <= 5000),
          player: answeringPlayer,
        };
        setLastAnswerResult(result);
        setLastScoredPlayerId(answeringPlayer.id);
        setLastPointsEarned(totalDelta);

        // Update player in local state
        setPlayers((prev) =>
          prev.map((p) =>
            p.id === answeringPlayer.id
              ? {
                  ...p,
                  score: p.score + totalDelta,
                  streak: data.streak,
                }
              : p
          )
        );
      } else {
        // Fallback local scoring calculation
        const isCorrect = optionId === currentQuestion.correctOptionId;
        const baseDelta = isCorrect ? (responseTimeMs <= 5000 ? 150 : 100) : 0;
        const buzzerBoost = isCorrect && hadBuzzer ? 100 : 0;
        const totalDelta = baseDelta + buzzerBoost;
        const newStreak = isCorrect ? answeringPlayer.streak + 1 : 0;

        setLastAnswerResult({
          correct: isCorrect,
          isCorrect,
          pointsEarned: totalDelta,
          scoreDelta: totalDelta,
          streak: newStreak,
          newStreak,
          correctOptionId: currentQuestion.correctOptionId,
          explanation: currentQuestion.explanation,
          buzzerBonusApplied: isCorrect && hadBuzzer,
          speedBonusApplied: isCorrect && responseTimeMs <= 5000,
          player: answeringPlayer,
        });
        setLastScoredPlayerId(answeringPlayer.id);
        setLastPointsEarned(totalDelta);

        setPlayers((prev) =>
          prev.map((p) =>
            p.id === answeringPlayer.id
              ? { ...p, score: p.score + totalDelta, streak: newStreak }
              : p
          )
        );
      }
    } catch (err) {
      console.error('Answer submission error:', err);
      // Client fallback
      const isCorrect = optionId === currentQuestion.correctOptionId;
      const totalDelta = isCorrect ? (hadBuzzer ? 200 : 100) : 0;
      setLastAnswerResult({
        correct: isCorrect,
        isCorrect,
        pointsEarned: totalDelta,
        scoreDelta: totalDelta,
        streak: isCorrect ? answeringPlayer.streak + 1 : 0,
        correctOptionId: currentQuestion.correctOptionId,
        explanation: currentQuestion.explanation,
        buzzerBonusApplied: isCorrect && hadBuzzer,
        player: answeringPlayer,
      });
      setLastPointsEarned(totalDelta);
    } finally {
      setIsBuzzerActive(false);
      transitionTo('ANSWER_RESULT');
    }
  }, [questions, currentQuestionIndex, players, activePlayerIndex, session, isBuzzerActive, transitionTo]);

  // Score Update Progression Handler
  const handleScoreUpdateContinue = useCallback(() => {
    const nextIdx = currentQuestionIndex + 1;

    // Check if match is complete
    if (nextIdx >= questions.length) {
      transitionTo('WINNER');
      return;
    }

    // Check for AI Adaptation trigger (e.g. at question 2)
    if (nextIdx === 2 && !hasAdaptationTriggered) {
      setHasAdaptationTriggered(true);
      setCurrentQuestionIndex(nextIdx);
      setActivePlayerIndex((prev) => (prev + 1) % players.length);
      transitionTo('AI_ADAPTATION');
      return;
    }

    // Check for Surprise Round trigger (e.g. at question 3)
    if (nextIdx === 3 && !hasSurpriseTriggered) {
      setHasSurpriseTriggered(true);
      setCurrentQuestionIndex(nextIdx);
      setActivePlayerIndex((prev) => (prev + 1) % players.length);
      transitionTo('SURPRISE_ROUND');
      return;
    }

    // Check for Final Round showdown (last question)
    if (nextIdx === questions.length - 1) {
      setCurrentQuestionIndex(nextIdx);
      setActivePlayerIndex((prev) => (prev + 1) % players.length);
      transitionTo('FINAL_ROUND');
      return;
    }

    // Standard Next Question
    setCurrentQuestionIndex(nextIdx);
    setActivePlayerIndex((prev) => (prev + 1) % players.length);
    transitionTo('GAMEPLAY');
  }, [currentQuestionIndex, questions.length, hasAdaptationTriggered, hasSurpriseTriggered, players.length, transitionTo]);

  // Restart Match
  const handlePlayAgain = useCallback(() => {
    // Reset player scores
    setPlayers((prev) => prev.map((p) => ({ ...p, score: 0, streak: 0 })));
    setCurrentQuestionIndex(0);
    setActivePlayerIndex(0);
    setHasAdaptationTriggered(false);
    setHasSurpriseTriggered(false);
    handleStartGeneration(players, selectedMode, selectedCategory);
  }, [players, selectedMode, selectedCategory, handleStartGeneration]);

  // Voice AI Action Handler
  const handleVoiceCommand = useCallback((cmdText: string) => {
    setIsMicOpen(false);
    if (cmdText.includes('science') || cmdText.includes('category')) {
      setSelectedCategory('science');
      playTVSound('correct');
    } else if (cmdText.includes('balance') || cmdText.includes('adapt')) {
      transitionTo('AI_ADAPTATION');
    } else if (cmdText.includes('surprise') || cmdText.includes('blitz')) {
      transitionTo('SURPRISE_ROUND');
    } else if (cmdText.includes('start') || cmdText.includes('play')) {
      handleStartGeneration(players, selectedMode, selectedCategory);
    }
  }, [players, selectedMode, selectedCategory, handleStartGeneration, transitionTo]);

  // Hardware Back Key & Global Shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // 1. NEVER intercept keys when typing in any input field
      const target = e.target as HTMLElement | null;
      const isInput =
        target &&
        (target.tagName === 'INPUT' ||
          target.tagName === 'TEXTAREA' ||
          target.tagName === 'SELECT' ||
          target.isContentEditable);
      const activeEl = typeof document !== 'undefined' ? document.activeElement : null;
      const isActiveInput =
        activeEl &&
        (activeEl.tagName === 'INPUT' ||
          activeEl.tagName === 'TEXTAREA' ||
          activeEl.tagName === 'SELECT' ||
          (activeEl as HTMLElement).isContentEditable);

      if (isInput || isActiveInput) {
        return;
      }

      // Hardware Back or Escape
      if (e.keyCode === 4 || e.key === 'Escape' || e.key === 'GoBack' || e.key === 'Back') {
        e.preventDefault();
        handleBack();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleBack]);

  const currentQuestion = questions[currentQuestionIndex] || SEED_QUESTIONS[0];
  const activePlayer = players[activePlayerIndex % players.length] || players[0];

  return (
    <TVFocusManager
      onBack={handleBack}
      onBuzz={() => {
        if (currentScreen === 'GAMEPLAY') {
          setIsBuzzerActive(true);
        }
      }}
    >
      <main className="tv-safe-container bg-[#070812] text-white">
        {/* Particle Canvas Background */}
        <AnimatedAINetworkBackground />

        {/* Global TV Top Bar (Visible on non-splash screens) */}
        {currentScreen !== 'SPLASH' && (
          <SharedTopBar
            screenState={currentScreen}
            onOpenMic={() => setIsMicOpen(true)}
            onOpenSettings={() => transitionTo('SETTINGS')}
            onOpenProfile={() => setIsProfileOpen(true)}
          />
        )}

        {/* Main Viewport Screen Router */}
        <div className="flex-1 w-full h-full relative z-10 overflow-hidden">
          {currentScreen === 'SPLASH' && (
            <SplashScreen onFinish={() => transitionTo('HOME')} />
          )}

          {currentScreen === 'HOME' && (
            <HomeScreen
              players={players}
              onQuickPlay={() => handleStartGeneration(players, 'family-adaptive', 'mixed')}
              onCustomGame={() => transitionTo('GAME_MODE')}
              onSettings={() => transitionTo('SETTINGS')}
              onSelectCategory={(categoryName) => {
                const norm = normalizeCategoryToSeed(categoryName);
                setSelectedCategory(norm);
                handleStartGeneration(players, 'family-adaptive', norm);
              }}
              onAddFamilyMember={(newMember) => setPlayers((prev) => [...prev, newMember])}
              onRemoveFamilyMember={(id) => setPlayers((prev) => prev.filter((p) => p.id !== id))}
            />
          )}

          {currentScreen === 'GAME_MODE' && (
            <GameModeScreen
              players={players}
              onSelectMode={(mode: any, cat: any) => {
                setSelectedMode(mode);
                setSelectedCategory(cat || 'science');
                transitionTo('PLAYER_SETUP');
              }}
              onBack={() => transitionTo('HOME')}
            />
          )}

          {currentScreen === 'PLAYER_SETUP' && (
            <PlayerSetupScreen
              players={players}
              onAddPlayer={(newPlayer) => {
                if (newPlayer) setPlayers((prev) => [...prev, newPlayer]);
              }}
              onRemovePlayer={(id) => {
                setPlayers((prev) => prev.filter((p) => p.id !== id));
              }}
              onEditPlayer={(p: Player) => {
                setEditingPlayer(p);
                transitionTo('PLAYER_PICKER');
              }}
              onComplete={(roster: Player[]) => {
                setPlayers(roster);
                handleStartGeneration(roster, selectedMode, selectedCategory, gameSettings);
              }}
              onBack={() => transitionTo('GAME_MODE')}
            />
          )}

          {currentScreen === 'PLAYER_PICKER' && (
            <PlayerPickerScreen
              player={editingPlayer || players[0]}
              players={players}
              onSave={(updatedPlayer: Player) => {
                setPlayers((prev) => prev.map((p) => (p.id === updatedPlayer.id ? updatedPlayer : p)));
                transitionTo('PLAYER_SETUP');
              }}
              onConfirmPlayers={(roster: Player[]) => {
                setPlayers(roster);
                transitionTo('PLAYER_SETUP');
              }}
              onBack={() => transitionTo('PLAYER_SETUP')}
            />
          )}


          {currentScreen === 'SETTINGS' && (
            <SettingsScreen
              players={players}
              settings={gameSettings}
              selectedCategory={selectedCategory}
              selectedDifficulty={gameSettings.difficulty}
              onUpdateSettings={(newSettings) => setGameSettings(newSettings)}
              onStartGame={() => handleStartGeneration(players, selectedMode, selectedCategory, gameSettings)}
              onBack={() => transitionTo('HOME')}
            />
          )}

          {currentScreen === 'GENERATING' && (
            <GeneratingScreen
              mode={selectedMode}
              category={selectedCategory}
              playerCount={players.length}
            />
          )}

          {currentScreen === 'ROUND_INTRO' && (
            <RoundIntroScreen
              roundNumber={currentQuestionIndex + 1}
              totalRounds={questions.length || gameSettings.questionCount || 5}
              category={selectedCategory}
              difficulty={gameSettings.difficulty || 'Adaptive'}
              players={players}
              activePlayer={activePlayer}
              onStartRound={() => transitionTo('GAMEPLAY')}
            />
          )}

          {currentScreen === 'GAMEPLAY' && (
            <GameplayScreen
              session={session || {
                id: 'local',
                joinCode: 'PLAY-26',
                mode: selectedMode,
                category: selectedCategory,
                status: 'in_progress',
                currentRound: currentQuestionIndex + 1,
                totalRounds: questions.length || gameSettings.questionCount || 5,
                currentQuestionIndex,
                currentDifficulty: 2,
                players,
                adaptivePacing: 'normal',
                createdAt: new Date().toISOString(),
              }}
              question={currentQuestion}
              questionIndex={currentQuestionIndex}
              totalQuestions={questions.length || gameSettings.questionCount || 5}
              players={players}
              activePlayer={activePlayer}
              timerDurationSeconds={gameSettings.timerSeconds || 15}
              onAnswerSelected={handleAnswerSubmit}
              onTriggerBuzz={() => setIsBuzzerActive(true)}
            />
          )}

          {currentScreen === 'ANSWER_RESULT' && lastAnswerResult && (
            <AnswerResultScreen
              result={{
                ...lastAnswerResult,
                isCorrect: Boolean(lastAnswerResult.isCorrect ?? lastAnswerResult.correct),
              }}
              question={currentQuestion}
              player={activePlayer}
              onContinue={() => transitionTo('SCORE_UPDATE')}
            />
          )}


          {currentScreen === 'SCORE_UPDATE' && (
            <ScoreUpdateScreen
              session={session || {
                id: 'local',
                joinCode: 'PLAY-26',
                mode: selectedMode,
                category: selectedCategory,
                status: 'in_progress',
                currentRound: 1,
                totalRounds: 5,
                currentQuestionIndex,
                currentDifficulty: 2,
                players,
                adaptivePacing: 'normal',
                createdAt: new Date().toISOString(),
              }}
              players={players}
              lastScoredPlayerId={lastScoredPlayerId}
              lastPointsEarned={lastPointsEarned}
              onContinue={handleScoreUpdateContinue}
            />
          )}

          {currentScreen === 'AI_ADAPTATION' && (
            <AiAdaptationScreen
              session={session || {
                id: 'local',
                joinCode: 'PLAY-26',
                mode: selectedMode,
                category: selectedCategory,
                status: 'in_progress',
                currentRound: 1,
                totalRounds: 5,
                currentQuestionIndex,
                currentDifficulty: 2,
                players,
                adaptivePacing: 'normal',
                createdAt: new Date().toISOString(),
              }}
              players={players}
              reason="CORTEX-9: Detected inter-generational synergy imbalance. Relaxing pacing & boosting underdog multipliers."
              onContinue={() => transitionTo('GAMEPLAY')}
            />
          )}

          {currentScreen === 'SURPRISE_ROUND' && (
            <SurpriseRoundScreen
              session={session || {
                id: 'local',
                joinCode: 'PLAY-26',
                mode: selectedMode,
                category: selectedCategory,
                status: 'in_progress',
                currentRound: 1,
                totalRounds: 5,
                currentQuestionIndex,
                currentDifficulty: 2,
                players,
                adaptivePacing: 'normal',
                createdAt: new Date().toISOString(),
              }}
              players={players}
              onStartRound={() => transitionTo('GAMEPLAY')}
            />
          )}

          {currentScreen === 'FINAL_ROUND' && (
            <FinalRoundScreen
              session={session || {
                id: 'local',
                joinCode: 'PLAY-26',
                mode: selectedMode,
                category: selectedCategory,
                status: 'in_progress',
                currentRound: 1,
                totalRounds: 5,
                currentQuestionIndex,
                currentDifficulty: 2,
                players,
                adaptivePacing: 'normal',
                createdAt: new Date().toISOString(),
              }}
              players={players}
              onStartFinalRound={() => transitionTo('GAMEPLAY')}
            />
          )}

          {currentScreen === 'WINNER' && (
            <WinnerScreen
              session={session || {
                id: 'local',
                joinCode: 'PLAY-26',
                mode: selectedMode,
                category: selectedCategory,
                status: 'in_progress',
                currentRound: 1,
                totalRounds: 5,
                currentQuestionIndex,
                currentDifficulty: 2,
                players,
                adaptivePacing: 'normal',
                createdAt: new Date().toISOString(),
              }}
              players={players}
              onShowRecap={() => transitionTo('RECAP')}
              onPlayAgain={handlePlayAgain}
              onReturnHome={() => transitionTo('HOME')}
            />
          )}

          {currentScreen === 'RECAP' && (
            <RecapScreen
              session={session || {
                id: 'local',
                joinCode: 'PLAY-26',
                mode: selectedMode,
                category: selectedCategory,
                status: 'in_progress',
                currentRound: 1,
                totalRounds: 5,
                currentQuestionIndex,
                currentDifficulty: 2,
                players,
                adaptivePacing: 'normal',
                createdAt: new Date().toISOString(),
              }}
              players={players}
              onPlayAgain={handlePlayAgain}
              onReturnHome={() => transitionTo('HOME')}
            />
          )}
        </div>

        {/* Global TV Bottom HUD Legend */}
        {currentScreen !== 'SPLASH' && (
          <SharedBottomHud
            currentScreen={currentScreen}
            onOkPress={() => {
              if (currentScreen === 'SURPRISE_ROUND' || currentScreen === 'FINAL_ROUND' || currentScreen === 'ROUND_INTRO' || currentScreen === 'AI_ADAPTATION') {
                transitionTo('GAMEPLAY');
              } else if (currentScreen === 'ANSWER_RESULT') {
                transitionTo('SCORE_UPDATE');
              }
            }}
            onBuzzPress={() => {
              if (currentScreen === 'GAMEPLAY') {
                setIsBuzzerActive(true);
              }
            }}
          />
        )}

        {/* Modal Overlays */}
        <HostListeningDialog
          isOpen={isMicOpen}
          onClose={() => setIsMicOpen(false)}
          onSimulateCommand={handleVoiceCommand}
        />

        <AccountProfileDialog
          isOpen={isProfileOpen}
          players={players}
          onClose={() => setIsProfileOpen(false)}
        />
      </main>
    </TVFocusManager>
  );
}
