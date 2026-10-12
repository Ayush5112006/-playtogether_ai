import { NextResponse } from 'next/server';
import { getAdminSupabaseClient } from '@/lib/supabase/admin';

export const dynamic = 'force-dynamic';

export async function GET() {
  const adminClient = getAdminSupabaseClient();
  let dbStatus = 'DISCONNECTED';
  let questionCount = 0;
  let sessionCount = 0;

  if (adminClient) {
    try {
      const { count: qCount, error: qError } = await adminClient
        .from('questions')
        .select('*', { count: 'exact', head: true });

      const { count: sCount, error: sError } = await adminClient
        .from('sessions')
        .select('*', { count: 'exact', head: true });

      if (!qError && !sError) {
        dbStatus = 'CONNECTED_ONLINE';
        questionCount = qCount || 0;
        sessionCount = sCount || 0;
      } else {
        dbStatus = 'ERROR: ' + (qError?.message || sError?.message);
      }
    } catch (err: any) {
      dbStatus = 'EXCEPTION: ' + err.message;
    }
  }

  return NextResponse.json({
    status: 'ok',
    app: 'PlayTogether AI',
    engine: 'Next.js App Router (Production-Ready)',
    target: 'Amazon Fire TV / 10-foot UI',
    database: {
      status: dbStatus,
      liveQuestionsCount: questionCount,
      activeSessionsCount: sessionCount,
    },
    timestamp: new Date().toISOString(),
  });
}
