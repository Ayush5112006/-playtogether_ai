import { NextRequest, NextResponse } from 'next/server';
import { MfaVerifySchema } from '@/lib/security/validation';
import { createServerSupabaseClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = MfaVerifySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: 'Invalid 6-digit MFA code' }, { status: 400 });
    }

    const { factorId, challengeId, code } = parsed.data;
    const supabase = createServerSupabaseClient();

    const { data, error } = await supabase.auth.mfa.verify({
      factorId,
      challengeId,
      code,
    });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({
      success: true,
      message: 'MFA verification successful',
    });
  } catch (err: any) {
    return NextResponse.json({ error: 'MFA verification failed', message: err.message }, { status: 500 });
  }
}
