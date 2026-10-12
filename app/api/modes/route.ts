import { NextResponse } from 'next/server';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';
import { SEED_GAME_MODES } from '@/lib/game-engine/seed-questions';

export const dynamic = 'force-dynamic';

export async function GET() {
  const adminClient = getAdminSupabaseClient();

  if (adminClient) {
    try {
      const { data, error } = await adminClient
        .from('game_modes')
        .select('*');

      if (!error && data && data.length > 0) {
        return NextResponse.json({
          source: 'DATABASE',
          modes: data,
        });
      }
    } catch {
      // Fall through to seed modes
    }
  }

  return NextResponse.json({
    source: 'SEED_FALLBACK',
    modes: SEED_GAME_MODES,
  });
}
