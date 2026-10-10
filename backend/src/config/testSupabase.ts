import { supabase } from './supabase';

async function testSupabaseConnection() {
  const { data, error } = await supabase
    .from('game_sessions')
    .select('*')
    .limit(1);

  if (error) {
    console.error('❌ Supabase connection failed:', error.message);
    process.exitCode = 1;
    return;
  }

  console.log('✅ Supabase connection successful!');
  console.log('Query result:', data);
}

testSupabaseConnection();