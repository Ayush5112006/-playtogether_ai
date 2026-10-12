// =============================================================================
// PlayTogether AI — Browser Supabase Client
// Client-side Supabase client using @supabase/ssr.
// Uses public environment variables ONLY (anon key).
// =============================================================================

import { createBrowserClient } from '@supabase/ssr';

export function createClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://xwgslqfpymsysastllnk.supabase.co';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

  return createBrowserClient(supabaseUrl, supabaseAnonKey);
}
