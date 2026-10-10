import { createClient, SupabaseClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
// In backend, prefer the secret/service role key for trusted server access, fallback to publishable/anon key
const supabaseKey =
  process.env.SUPABASE_SECRET_KEY ||
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  process.env.SUPABASE_PUBLISHABLE_KEY ||
  process.env.SUPABASE_ANON_KEY;

export interface SupabaseHealthResult {
  configured: boolean;
  connected: boolean;
  status: 'connected' | 'disconnected' | 'unconfigured' | 'error';
  message: string;
}

let supabaseInstance: SupabaseClient | null = null;

/**
 * Checks whether Supabase environment variables are provided with non-placeholder values.
 */
export function isSupabaseConfigured(): boolean {
  if (!supabaseUrl || !supabaseKey) {
    return false;
  }
  const isPlaceholderUrl = supabaseUrl.includes('your-project-id.supabase.co');
  const isPlaceholderKey =
    supabaseKey === 'your-service-role-key' ||
    supabaseKey === 'your-anon-key' ||
    supabaseKey.startsWith('your-');
  return !isPlaceholderUrl && !isPlaceholderKey;
}


/**
 * Retrieves the singleton Supabase client instance.
 * Returns null if Supabase is not configured yet.
 */
export function getSupabaseClient(): SupabaseClient | null {
  if (!isSupabaseConfigured()) {
    return null;
  }

  if (!supabaseInstance) {
    supabaseInstance = createClient(supabaseUrl!, supabaseKey!, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
  }

  return supabaseInstance;
}

/**
 * Performs a lightweight check to verify Supabase connectivity without leaking sensitive credentials.
 */
export async function checkSupabaseConnection(): Promise<SupabaseHealthResult> {
  if (!isSupabaseConfigured()) {
    return {
      configured: false,
      connected: false,
      status: 'unconfigured',
      message: 'Supabase credentials are not configured or using placeholders in .env',
    };
  }

  const client = getSupabaseClient();
  if (!client) {
    return {
      configured: false,
      connected: false,
      status: 'unconfigured',
      message: 'Supabase client could not be initialized',
    };
  }

  try {
    // Perform a lightweight probe to verify authentication & network connectivity
    // Testing connection against PostgREST endpoint
    const { error } = await client.from('_health_check').select('count', { count: 'exact', head: true });

    if (error) {
      // If table doesn't exist (PGRST205, PGRST204, or 42P01), connection was authenticated and reached Supabase PostgREST!
      if (
        error.code === '42P01' ||
        error.code === 'PGRST204' ||
        error.code === 'PGRST205' ||
        error.message?.includes('relation') ||
        error.message?.includes('does not exist') ||
        error.message?.includes('schema cache')
      ) {
        return {
          configured: true,
          connected: true,
          status: 'connected',
          message: 'Connected to Supabase successfully (database schema pending Phase 2 setup)',
        };
      }

      // Invalid API key or unauthorized
      if (error.code === 'PGRST301' || error.message?.toLowerCase().includes('jwt') || error.message?.toLowerCase().includes('apikey')) {
        return {
          configured: true,
          connected: false,
          status: 'disconnected',
          message: 'Supabase authentication failed: Invalid API key',
        };
      }

      return {
        configured: true,
        connected: false,
        status: 'error',
        message: 'Supabase returned an unexpected status during probe',
      };
    }

    return {
      configured: true,
      connected: true,
      status: 'connected',
      message: 'Connected to Supabase successfully',
    };
  } catch (err: any) {
    const errorMsg = err?.message?.toLowerCase() || '';
    if (errorMsg.includes('enotfound') || errorMsg.includes('fetch failed')) {
      return {
        configured: true,
        connected: false,
        status: 'disconnected',
        message: 'Could not resolve or connect to Supabase URL',
      };
    }

    return {
      configured: true,
      connected: false,
      status: 'error',
      message: 'Network or configuration error connecting to Supabase',
    };
  }
}

// Export singleton instance (or null if unconfigured)
export const supabase = isSupabaseConfigured() ? getSupabaseClient() : null;
