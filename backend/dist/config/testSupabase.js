"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const supabase_1 = require("./supabase");
async function testSupabaseConnection() {
    if (!supabase_1.supabase) {
        console.error('❌ Supabase is not configured in environment');
        process.exitCode = 1;
        return;
    }
    const { data, error } = await supabase_1.supabase
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
