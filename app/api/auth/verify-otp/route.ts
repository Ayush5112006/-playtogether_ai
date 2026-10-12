import { NextRequest, NextResponse } from 'next/server';
import { AuthVerifyOtpSchema } from '@/lib/security/validation';
import { checkRateLimit } from '@/lib/security/rate-limit';
import { createServerSupabaseClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export async function POST(req: NextRequest) {
  const ip = req.headers.get('x-forwarded-for') || '127.0.0.1';
  const rateLimit = checkRateLimit(ip, 'auth:otp', 5, 60);
  if (!rateLimit.allowed) {
    return NextResponse.json({ error: 'Too many verification attempts' }, { status: 429 });
  }

  try {
    const body = await req.json();
    const parsed = AuthVerifyOtpSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: 'Invalid OTP payload', details: parsed.error.format() }, { status: 400 });
    }

    const { email, token, type } = parsed.data;
    const supabase = createServerSupabaseClient();

    const { data, error } = await supabase.auth.verifyOtp({
      email,
      token,
      type: type as any,
    });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({
      success: true,
      user: {
        id: data.user?.id,
        email: data.user?.email,
      },
    });
  } catch (err: any) {
    return NextResponse.json({ error: 'OTP verification failed', message: err.message }, { status: 500 });
  }
}
