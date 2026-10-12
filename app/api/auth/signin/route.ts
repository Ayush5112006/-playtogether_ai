import { NextRequest, NextResponse } from 'next/server';
import { AuthSignInSchema } from '@/lib/security/validation';
import { checkRateLimit } from '@/lib/security/rate-limit';
import { createServerSupabaseClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export async function POST(req: NextRequest) {
  const ip = req.headers.get('x-forwarded-for') || '127.0.0.1';
  const rateLimit = checkRateLimit(ip, 'auth:signin', 8, 60);
  if (!rateLimit.allowed) {
    return NextResponse.json({ error: 'Too many login attempts. Please wait.' }, { status: 429 });
  }

  try {
    const body = await req.json();
    const parsed = AuthSignInSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: 'Invalid login details' }, { status: 400 });
    }

    const { email, password } = parsed.data;
    const supabase = createServerSupabaseClient();

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return NextResponse.json({ error: 'Invalid login credentials' }, { status: 401 });
    }

    // Check if MFA is required
    const { data: factors } = await supabase.auth.mfa.listFactors();
    const totpFactor = factors?.totp?.find((f) => f.status === 'verified');
    const mfaRequired = !!totpFactor;

    return NextResponse.json({
      success: true,
      user: {
        id: data.user?.id,
        email: data.user?.email,
      },
      mfaRequired,
      factorId: totpFactor?.id,
    });
  } catch (err: any) {
    return NextResponse.json({ error: 'Login error', message: err.message }, { status: 500 });
  }
}
