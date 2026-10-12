'use client';

import React, { useEffect, useState } from 'react';
import { Sparkles, Trophy, RotateCcw, Home, Award, Zap, Brain, Heart, ArrowRight } from 'lucide-react';
import AIObsorbOrb from '@/components/tv/AIObsorbOrb';
import { playTVSound, TVFocusable, useTVFocus } from '@/components/tv/TVFocusManager';
import { Player, Session, GameRecap } from '@/lib/types';

interface RecapScreenProps {
  session: Session;
  players: Player[];
  onPlayAgain: () => void;
  onReturnHome: () => void;
}

export default function RecapScreen({
  session,
  players,
  onPlayAgain,
  onReturnHome,
}: RecapScreenProps) {
  const { setActiveFocusId } = useTVFocus();
  const [recap, setRecap] = useState<GameRecap | null>(null);
  const [loading, setLoading] = useState(true);

  const sortedPlayers = [...players].sort((a, b) => b.score - a.score);

  useEffect(() => {
    setActiveFocusId('btn-recap-play-again');
    playTVSound('ai');

    // Fetch or generate recap from authoritative endpoint
    const fetchRecap = async () => {
      try {
        const res = await fetch(`/api/sessions/${session.id}/recap`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ players: sortedPlayers }),
        });
        if (res.ok) {
          const data = await res.json();
          if (data?.recap) {
            setRecap(data.recap);
            return;
          }
        }
      } catch (err) {
        console.error('Error fetching recap:', err);
      } finally {
        setLoading(false);
      }

      // Safe local fallback
      const topWinner = sortedPlayers[0]?.name || 'Family';
      const fallbackAwards = [
        { awardName: 'Match MVP', description: 'Highest overall accuracy & score' },
        { awardName: 'Speed Demon', description: 'Lightning buzzer reaction time' },
        { awardName: 'Trivia Strategist', description: 'Key living room knowledge anchor' },
        { awardName: 'Clutch Performer', description: 'Sharp precision in clutch rounds' },
        { awardName: 'Comeback Star', description: 'Dynamic momentum and determination' },
        { awardName: 'Family Anchor', description: 'Consistent performance and team balance' },
      ];

      setRecap({
        id: 'local-recap',
        sessionId: session.id,
        winnerId: sortedPlayers[0]?.id || '',
        winnerName: topWinner,
        highestStreak: Math.max(...players.map((p) => p.streak || 0), 3),
        totalQuestions: 5,
        familySynergyScore: 94,
        familySynergyPercent: '94%',
        aiSummary: `Outstanding multi-generational showdown! ${topWinner} led the living room, while all generations displayed lightning reflexes and balanced teamwork.`,
        hostInsight: `Outstanding multi-generational showdown! ${topWinner} led the living room, while all generations displayed lightning reflexes and balanced teamwork.`,
        awards: sortedPlayers.map((p, idx) => ({
          playerId: p.id,
          awardName: fallbackAwards[idx]?.awardName || `Living Room Ace ${idx + 1}`,
          description: fallbackAwards[idx]?.description || 'Consistent performance and team balance',
        })),
        recommendedNextCategory: 'Cinema Clues (Adaptive Co-Op)',
        nextGameRecommendation: 'Cinema Clues (Adaptive Co-Op)',
        createdAt: new Date().toISOString(),
      });
      setLoading(false);
    };

    fetchRecap();
  }, [session.id]);

  const synergyScore =
    recap?.familySynergyScore ??
    (recap?.familySynergyPercent ? parseInt(String(recap.familySynergyPercent).replace(/\D/g, ''), 10) : null) ??
    94;
  const synergyDisplay = `${synergyScore}%`;

  const topWinner = sortedPlayers[0]?.name || 'Family';
  const defaultDebrief = `Sensational family showdown! ${topWinner} seized first place with stellar answers, while the whole room sustained an electrifying ${synergyDisplay} synergy rating.`;
  const aiDebrief = (recap?.aiSummary || recap?.hostInsight || defaultDebrief).replace(/^"|"$/g, '');

  const recommendedCategory =
    recap?.recommendedNextCategory ||
    recap?.nextGameRecommendation ||
    'Cinema Clues (Adaptive Co-Op)';

  const fallbackAwards = [
    { awardName: 'Match MVP', description: 'Highest overall accuracy & score' },
    { awardName: 'Speed Demon', description: 'Lightning buzzer reaction time' },
    { awardName: 'Trivia Strategist', description: 'Key living room knowledge anchor' },
    { awardName: 'Clutch Performer', description: 'Sharp precision in clutch rounds' },
    { awardName: 'Comeback Star', description: 'Dynamic momentum & enthusiasm' },
    { awardName: 'Family Anchor', description: 'Consistent team spirit and balance' },
  ];

  return (
    <div className="w-full h-full flex flex-col justify-between px-10 py-5 relative overflow-hidden">
      {/* Top Banner */}
      <div className="flex items-center justify-between z-10">
        <div className="flex items-center gap-4">
          <div className="w-13 h-13 rounded-2xl bg-purple-500/20 border border-purple-400/50 flex items-center justify-center shadow-lg shadow-purple-500/30">
            <Brain className="w-7 h-7 text-purple-300" />
          </div>
          <div>
            <span className="text-xs font-mono uppercase tracking-widest text-purple-400 flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5" /> POST-GAME ANALYSIS
            </span>
            <h1 className="text-3xl lg:text-4xl font-black text-white tracking-tight">CORTEX-9 Family Synergy Report</h1>
          </div>
        </div>

        <div className="flex items-center gap-3 bg-purple-950/40 border border-purple-500/40 rounded-2xl px-5 py-2">
          <Heart className="w-5 h-5 text-pink-400 fill-pink-400 animate-pulse" />
          <div>
            <span className="text-[11px] font-mono text-purple-300 uppercase block">FAMILY SYNERGY</span>
            <span className="text-2xl font-black text-white font-mono">{synergyDisplay}</span>
          </div>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-center max-w-6xl mx-auto w-full my-auto z-10 py-2">
        {/* Left: AI Assessment */}
        <div className="lg:col-span-5 space-y-3.5">
          <div className="flex items-center gap-3">
            <AIObsorbOrb size="sm" state="idle" />
            <div>
              <span className="text-xs font-mono text-purple-300 uppercase">AI HOST CORTEX-9</span>
              <p className="font-bold text-white text-base">Match Debrief</p>
            </div>
          </div>

          <div className="p-5 rounded-2xl bg-purple-950/30 border border-purple-500/30 backdrop-blur-md shadow-lg shadow-purple-900/20">
            <p className="text-base lg:text-lg text-purple-100/90 leading-relaxed italic">
              &ldquo;{aiDebrief}&rdquo;
            </p>
          </div>

          <div className="p-4 rounded-2xl bg-white/5 border border-white/10">
            <span className="text-xs font-mono text-white/50 uppercase block mb-1">RECOMMENDED NEXT MATCH</span>
            <span className="text-lg font-black text-amber-300">
              {recommendedCategory} <span className="text-xs text-white/60 font-normal">(Adaptive Level 3)</span>
            </span>
          </div>
        </div>

        {/* Right: Awards & Honors */}
        <div className="lg:col-span-7 space-y-2">
          <span className="text-xs font-mono text-white/40 uppercase tracking-widest block mb-1">
            INDIVIDUAL RECOGNITION & METRICS
          </span>

          <div className="max-h-[290px] overflow-y-auto pr-1 space-y-2.5">
            {sortedPlayers.map((player, idx) => {
              const matchedAward = recap?.awards?.find((a) => a.playerId === player.id);
              const award = matchedAward || fallbackAwards[idx] || {
                awardName: idx === 0 ? 'Match MVP' : `Living Room Ace ${idx + 1}`,
                description: 'Consistent performance and team balance',
              };

              return (
                <div
                  key={player.id}
                  className="p-3.5 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-between hover:bg-white/[0.08] transition-colors"
                >
                  <div className="flex items-center gap-3.5">
                    <div
                      className="w-11 h-11 rounded-xl flex items-center justify-center text-lg font-bold flex-shrink-0"
                      style={{ backgroundColor: `${player.color || '#8b5cf6'}30`, border: `2px solid ${player.color || '#8b5cf6'}` }}
                    >
                      <span style={{ color: player.color || '#c084fc' }}>{player.avatar || '⭐'}</span>
                    </div>
                    <div>
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="font-black text-white text-base">{player.name}</span>
                        <span className="text-xs px-2.5 py-0.5 rounded-full bg-amber-400/20 text-amber-300 font-mono font-bold flex items-center gap-1">
                          <Award className="w-3 h-3" /> {award.awardName}
                        </span>
                      </div>
                      <p className="text-xs text-white/60 mt-0.5">{award.description}</p>
                    </div>
                  </div>

                  <div className="text-right flex-shrink-0 pl-3">
                    <span className="text-xl font-black text-white font-mono">{player.score}</span>
                    <span className="text-[10px] text-white/40 font-mono block">FINAL PTS</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Action Footer */}
      <div className="flex items-center justify-between border-t border-white/10 pt-4 z-10">
        <TVFocusable
          id="btn-recap-home"
          group="recap-actions"
          onActivate={() => {
            playTVSound('click');
            onReturnHome();
          }}
          className="flex items-center gap-2 px-6 py-3.5 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-bold border border-white/20 transition-all text-base cursor-pointer"
        >
          <Home className="w-5 h-5 text-purple-400" />
          <span>RETURN TO HOME</span>
        </TVFocusable>

        <TVFocusable
          id="btn-recap-play-again"
          group="recap-actions"
          onActivate={() => {
            playTVSound('click');
            onPlayAgain();
          }}
          className="flex items-center gap-3 px-8 py-4 rounded-2xl bg-gradient-to-r from-amber-400 via-orange-500 to-amber-500 text-black font-black text-xl hover:scale-105 active:scale-95 transition-all shadow-xl shadow-amber-400/40 cursor-pointer"
        >
          <RotateCcw className="w-6 h-6" />
          <span>PLAY ANOTHER GAME</span>
          <span className="text-xs px-2 py-0.5 rounded bg-black/20 text-black/80 font-mono">OK</span>
        </TVFocusable>
      </div>
    </div>
  );
}
