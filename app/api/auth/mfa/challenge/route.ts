import { NextRequest, NextResponse } from 'next/server';
import { createServerSupabaseClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export async function POST(req: NextRequest) {
  try {
    const { factorId } = await req.json();
    if (!factorId) {
      return NextResponse.json({ error: 'factorId is required' }, { status: 400 });
    }

    const supabase = createServerSupabaseClient();
    const { data, error } = await supabase.auth.mfa.challenge({ factorId });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({
      success: true,
      challengeId: data.id,
      expiresAt: data.expires_at,
    });
  } catch (err: any) {
    return NextResponse.json({ error: 'Failed to create challenge', message: err.message }, { status: 500 });
  }
}
