import { NextRequest, NextResponse } from 'next/server';
import { AuthSignUpSchema } from '@/lib/security/validation';
import { checkRateLimit } from '@/lib/security/rate-limit';
import { createServerSupabaseClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export async function POST(req: NextRequest) {
  const ip = req.headers.get('x-forwarded-for') || '127.0.0.1';
  const rateLimit = checkRateLimit(ip, 'auth:signup', 5, 60);
  if (!rateLimit.allowed) {
    return NextResponse.json({ error: 'Too many registration attempts. Please wait.' }, { status: 429 });
  }

  try {
    const body = await req.json();
    const parsed = AuthSignUpSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: 'Invalid signup data', details: parsed.error.format() }, { status: 400 });
    }

    const { email, password, name } = parsed.data;
    const supabase = createServerSupabaseClient();

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          display_name: name || email.split('@')[0],
        },
      },
    });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({
      success: true,
      user: {
        id: data.user?.id,
        email: data.user?.email,
        confirmationSent: !data.session,
      },
    });
  } catch (err: any) {
    return NextResponse.json({ error: 'Signup error', message: err.message }, { status: 500 });
  }
}
