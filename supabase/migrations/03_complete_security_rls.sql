-- ==============================================================================
-- PlayTogether AI — Migration 03: Profiles, RLS, Indexes, & Security Hardening
-- ==============================================================================

-- 1. PROFILES TABLE (Linked to auth.users)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    display_name VARCHAR(128) NOT NULL DEFAULT 'Living Room Player',
    avatar_url TEXT,
    is_mfa_enabled BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger to auto-create profile on Supabase auth.users signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name)
    VALUES (
        NEW.id,
        COALESCE(NEW.email, ''),
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(COALESCE(NEW.email, 'Player'), '@', 1))
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. GAME CATEGORIES & GAME MODES TABLES
CREATE TABLE IF NOT EXISTS game_categories (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    emoji VARCHAR(16) NOT NULL DEFAULT '🎮',
    description TEXT NOT NULL DEFAULT '',
    question_count INT NOT NULL DEFAULT 7,
    order_index INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS game_modes (
    id VARCHAR(64) PRIMARY KEY,
    title VARCHAR(128) NOT NULL,
    subtitle VARCHAR(128) NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT '',
    icon VARCHAR(64) NOT NULL DEFAULT 'Sparkles',
    badge VARCHAR(64) NOT NULL DEFAULT 'Party Mode',
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed Categories & Modes
INSERT INTO game_categories (id, name, emoji, description, question_count, order_index)
VALUES
    ('cinema_clues', 'Cinema Clues', '🎬', 'Blockbuster quotes, Hollywood trivia, and iconic cinematic moments.', 7, 0),
    ('science_cosmos', 'Science & Cosmos', '🚀', 'Astrophysics, biology, deep space mysteries, and scientific discoveries.', 7, 1),
    ('pop_culture_music', 'Pop Culture & Music', '🎵', 'Chart-topping hits, viral trends, grammy winners, and retro classics.', 6, 2),
    ('animation_family', 'Animation & Family', '✨', 'Pixar, Disney, Studio Ghibli magic, and all-ages living room favorites.', 6, 3),
    ('general_knowledge', 'General Knowledge', '🧠', 'World history, geography, puzzles, and eclectic trivia for everyone.', 6, 4)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    emoji = EXCLUDED.emoji,
    description = EXCLUDED.description;

INSERT INTO game_modes (id, title, subtitle, description, icon, badge, is_available)
VALUES
    ('trivia', 'Party Trivia', 'Classic 4-Choice Showdown', 'Compete across Cinema, Science, Music, and Pop Culture with 15s timer per turn.', 'Sparkles', '10 Qs Standard', true),
    ('movie_guess', 'Movie Guess', 'Plot Clue Mystery Challenge', 'Uncover the hidden film title using progressively revealed cinematic clues.', 'Film', 'Clue-Based', true),
    ('ai_surprise', 'AI Surprise Blitz', 'Dynamic Living Room Mayhem', 'Host-triggered Buzzer Blitz and rapid lightning sprints with double points.', 'Zap', 'Bonus Round', true)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    subtitle = EXCLUDED.subtitle;

-- 3. AI EVENTS AUDIT TABLE
CREATE TABLE IF NOT EXISTS ai_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(64) NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    event_type VARCHAR(64) NOT NULL, -- 'ADAPTATION', 'SURPRISE_ROUND', 'HANDICAP_BOOST', 'RECAP'
    message TEXT NOT NULL,
    old_difficulty VARCHAR(16) NOT NULL DEFAULT 'MEDIUM',
    new_difficulty VARCHAR(16) NOT NULL DEFAULT 'MEDIUM',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add user_id column to sessions for ownership validation
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE sessions ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
    END IF;
END $$;

-- 4. VIEW ALIASES FOR BACKWARD COMPATIBILITY
CREATE OR REPLACE VIEW game_sessions AS SELECT * FROM sessions;
CREATE OR REPLACE VIEW players AS SELECT * FROM session_players;
CREATE OR REPLACE VIEW answer_events AS SELECT * FROM player_answers;

-- 5. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_modes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_recaps ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_events ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can view and update their own record
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Categories & Modes: Public read-only
DROP POLICY IF EXISTS "Public read categories" ON game_categories;
CREATE POLICY "Public read categories" ON game_categories
    FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Public read modes" ON game_modes;
CREATE POLICY "Public read modes" ON game_modes
    FOR SELECT USING (is_available = true);

-- Questions: Public read active questions
DROP POLICY IF EXISTS "Public read active questions" ON questions;
CREATE POLICY "Public read active questions" ON questions
    FOR SELECT USING (is_active = true);

-- Sessions: Public read/create/update for living room guest access and authenticated users
DROP POLICY IF EXISTS "Session read access" ON sessions;
CREATE POLICY "Session read access" ON sessions
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Session create access" ON sessions;
CREATE POLICY "Session create access" ON sessions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Session update access" ON sessions;
CREATE POLICY "Session update access" ON sessions
    FOR UPDATE USING (true);

-- Session Players: Read and modify within session
DROP POLICY IF EXISTS "Session players access" ON session_players;
CREATE POLICY "Session players access" ON session_players
    FOR ALL USING (true);

-- Player Answers: Insert and read within session
DROP POLICY IF EXISTS "Player answers access" ON player_answers;
CREATE POLICY "Player answers access" ON player_answers
    FOR ALL USING (true);

-- Game Recaps: Read and create
DROP POLICY IF EXISTS "Game recaps access" ON game_recaps;
CREATE POLICY "Game recaps access" ON game_recaps
    FOR ALL USING (true);

-- AI Events: Read and create
DROP POLICY IF EXISTS "AI events access" ON ai_events;
CREATE POLICY "AI events access" ON ai_events
    FOR ALL USING (true);

-- 6. PERFORMANCE INDEXES
CREATE INDEX IF NOT EXISTS idx_sessions_status_difficulty ON sessions(status, current_difficulty);
CREATE INDEX IF NOT EXISTS idx_session_players_session_score ON session_players(session_id, score DESC);
CREATE INDEX IF NOT EXISTS idx_questions_cat_diff ON questions(category, difficulty);
CREATE INDEX IF NOT EXISTS idx_player_answers_session_question ON player_answers(session_id, question_id);
CREATE INDEX IF NOT EXISTS idx_ai_events_session_time ON ai_events(session_id, created_at DESC);
