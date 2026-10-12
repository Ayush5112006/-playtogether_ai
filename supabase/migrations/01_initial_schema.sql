-- ==============================================================================
-- PlayTogether AI — Migration 01: Core Game Tables & Seed Data
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Table: sessions
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(64) PRIMARY KEY,
    status VARCHAR(32) NOT NULL DEFAULT 'active' 
        CHECK (status IN ('waiting', 'active', 'paused', 'completed')),
    current_difficulty VARCHAR(16) NOT NULL DEFAULT 'MEDIUM' 
        CHECK (current_difficulty IN ('EASY', 'MEDIUM', 'HARD')),
    settings JSONB NOT NULL DEFAULT '{}'::jsonb,
    current_round INT NOT NULL DEFAULT 1 CHECK (current_round >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: session_players
CREATE TABLE IF NOT EXISTS session_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(64) NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    player_id VARCHAR(64) NOT NULL,
    name VARCHAR(128) NOT NULL,
    avatar_name VARCHAR(64) NOT NULL DEFAULT 'default',
    role_tag VARCHAR(64) NOT NULL DEFAULT 'Player',
    score INT NOT NULL DEFAULT 0 CHECK (score >= 0),
    streak INT NOT NULL DEFAULT 0 CHECK (streak >= 0),
    best_streak INT NOT NULL DEFAULT 0 CHECK (best_streak >= 0),
    correct_count INT NOT NULL DEFAULT 0 CHECK (correct_count >= 0),
    total_answered INT NOT NULL DEFAULT 0 CHECK (total_answered >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_session_player UNIQUE (session_id, player_id)
);

-- Table: questions
CREATE TABLE IF NOT EXISTS questions (
    id VARCHAR(64) PRIMARY KEY,
    category VARCHAR(128) NOT NULL,
    category_emoji VARCHAR(16) NOT NULL DEFAULT '🧠',
    difficulty VARCHAR(16) NOT NULL 
        CHECK (difficulty IN ('EASY', 'MEDIUM', 'HARD')),
    question TEXT NOT NULL,
    quote_highlight TEXT NOT NULL DEFAULT '',
    options JSONB NOT NULL 
        CHECK (jsonb_typeof(options) = 'array' AND jsonb_array_length(options) = 4),
    correct_option_id VARCHAR(4) NOT NULL 
        CHECK (correct_option_id IN ('A', 'B', 'C', 'D')),
    explanation TEXT NOT NULL DEFAULT '',
    point_value INT NOT NULL DEFAULT 100 CHECK (point_value >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: player_answers
CREATE TABLE IF NOT EXISTS player_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(64) NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    player_id VARCHAR(64) NOT NULL,
    question_id VARCHAR(64) NOT NULL REFERENCES questions(id) ON DELETE RESTRICT,
    selected_option_id VARCHAR(4) NOT NULL CHECK (selected_option_id IN ('A', 'B', 'C', 'D')),
    is_correct BOOLEAN NOT NULL,
    points_earned INT NOT NULL DEFAULT 0 CHECK (points_earned >= 0),
    response_time_seconds NUMERIC(6, 2) NOT NULL DEFAULT 0.0 CHECK (response_time_seconds >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: game_recaps
CREATE TABLE IF NOT EXISTS game_recaps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(64) NOT NULL UNIQUE REFERENCES sessions(id) ON DELETE CASCADE,
    host_insight TEXT NOT NULL,
    family_synergy_percent INT NOT NULL DEFAULT 90 CHECK (family_synergy_percent BETWEEN 0 AND 100),
    avg_speed_sec NUMERIC(4, 2) NOT NULL DEFAULT 2.0 CHECK (avg_speed_sec >= 0),
    next_game_recommendation VARCHAR(128) NOT NULL DEFAULT 'Cinema Clues',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
