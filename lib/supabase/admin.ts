// =============================================================================
// PlayTogether AI — Privileged Admin Supabase Client
// Server-only client using service role key.
// STRICTLY FORBIDDEN IN CLIENT-SIDE CODE.
// =============================================================================

import { createClient, SupabaseClient } from '@supabase/supabase-js';

let adminClientInstance: SupabaseClient | null = null;

export function getAdminSupabaseClient(): SupabaseClient | null {
  if (typeof window !== 'undefined') {
    throw new Error('FATAL SECURITY ERROR: Admin Supabase client cannot be accessed from the browser.');
  }

  if (adminClientInstance) {
    return adminClientInstance;
  }

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://xwgslqfpymsysastllnk.supabase.co';
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    console.warn('⚠️ Admin Supabase credentials not found. Check environment configuration.');
    return null;
  }

  adminClientInstance = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  return adminClientInstance;
}
