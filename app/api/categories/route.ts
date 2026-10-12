import { NextResponse } from 'next/server';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';
import { SEED_CATEGORIES } from '@/lib/game-engine/seed-questions';

export const dynamic = 'force-dynamic';

export async function GET() {
  const adminClient = getAdminSupabaseClient();

  if (adminClient) {
    try {
      const { data, error } = await adminClient
        .from('game_categories')
        .select('*')
        .order('order_index', { ascending: true });

      if (!error && data && data.length > 0) {
        return NextResponse.json({
          source: 'DATABASE',
          categories: data,
        });
      }
    } catch {
      // Fall through to seed categories
    }
  }

  return NextResponse.json({
    source: 'SEED_FALLBACK',
    categories: SEED_CATEGORIES,
  });
}
