import { NextRequest, NextResponse } from 'next/server';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';

export const dynamic = 'force-dynamic';

export async function POST(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const sessionId = params.id;
  const adminClient = getAdminSupabaseClient();
  const body = await req.json().catch(() => ({}));
  const bodyPlayers = Array.isArray(body?.players) ? body.players : [];

  const recommendations = [
    'Cinema Clues (Adaptive Co-Op)',
    'Space & Deep Cosmos',
    'Pop Culture & Retro Beats',
    'Animation & Family Gold',
    'Global Wonders & Geography',
  ];
  const nextGame = recommendations[Math.floor(Math.random() * recommendations.length)];

  const awardNames = [
    'Match MVP',
    'Speed Demon',
    'Trivia Strategist',
    'Clutch Performer',
    'Comeback Star',
    'Family Anchor',
    'Knowledge Guardian',
    'Rapid Responder',
  ];
  const awardDescs = [
    'Highest overall accuracy & score',
    'Lightning buzzer reaction time',
    'Key living room knowledge anchor',
    'Sharp precision in clutch rounds',
    'Dynamic momentum and determination',
    'Consistent performance & team balance',
    'Steadfast knowledge mastery',
    'Lightning fast instinct and play',
  ];

  let dbPlayers: any[] = [];
  let synergy = 94;
  let avgSpeed = 1.9;

  if (adminClient && sessionId !== 'local') {
    try {
      const { data } = await adminClient
        .from('session_players')
        .select('*')
        .eq('session_id', sessionId)
        .order('score', { ascending: false });
      if (data && data.length > 0) {
        dbPlayers = data;
      }

      const { data: answers } = await adminClient
        .from('player_answers')
        .select('is_correct, response_time_seconds')
        .eq('session_id', sessionId);

      if (answers && answers.length > 0) {
        const correctCount = answers.filter((a) => a.is_correct).length;
        const rawSynergy = Math.round((correctCount / answers.length) * 100);
        synergy = Math.max(78, Math.min(99, rawSynergy + 8));

        const totalTime = answers.reduce((sum, a) => sum + Number(a.response_time_seconds || 2.0), 0);
        avgSpeed = Number((totalTime / answers.length).toFixed(1));
      }
    } catch (e) {
      // Supabase query error, fallback to body players
    }
  }

  const effectivePlayers = dbPlayers.length > 0
    ? dbPlayers
    : bodyPlayers.length > 0
      ? bodyPlayers
      : [{ id: 'p1', name: 'Family Team', score: 1200 }];

  const sortedPlayers = [...effectivePlayers].sort((a, b) => (b.score || 0) - (a.score || 0));
  const winner = sortedPlayers[0];

  const awards = sortedPlayers.map((p, idx) => ({
    playerId: p.player_id || p.id,
    awardName: awardNames[idx] || `Living Room Ace ${idx + 1}`,
    description: awardDescs[idx] || 'Consistent performance and team balance',
  }));

  const hostInsight = `"Sensational family showdown! ${winner.name} seized first place with ${winner.score || 0} PTS, while the whole living room maintained an electrifying ${synergy}% synergy rating. Next recommended match: ${nextGame}."`;
  const aiSummary = hostInsight.replace(/^"|"$/g, '');

  if (adminClient && sessionId !== 'local') {
    try {
      await adminClient.from('game_recaps').upsert({
        session_id: sessionId,
        host_insight: hostInsight,
        family_synergy_percent: synergy,
        avg_speed_sec: avgSpeed,
        next_game_recommendation: nextGame,
      });
    } catch (e) {
      // Continue even if database upsert fails
    }
  }

  return NextResponse.json({
    success: true,
    recap: {
      winnerPlayerId: winner.player_id || winner.id || '',
      winnerName: winner.name,
      winnerScore: winner.score || 0,
      hostInsight,
      aiSummary,
      familySynergyPercent: `${synergy}%`,
      familySynergyScore: synergy,
      avgSpeedSec: `${avgSpeed}s`,
      nextGameRecommendation: nextGame,
      recommendedNextCategory: nextGame,
      awards,
    },
  });
}
