-- ==============================================================================
-- PlayTogether AI — PostgreSQL Database Schema & Seed Data (Supabase)
-- Phase 2: Core Game Tables, Constraints, RLS, & Trivia Seed Bank
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. TABLE DEFINITIONS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Table: sessions
-- Tracks active party game sessions, current round, difficulty, and settings.
-- Compatible with Flutter session models and /api/sessions contract.
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(64) PRIMARY KEY,                                -- e.g. "session_1234" or UUID
    status VARCHAR(32) NOT NULL DEFAULT 'active' 
        CHECK (status IN ('waiting', 'active', 'paused', 'completed')),
    current_difficulty VARCHAR(16) NOT NULL DEFAULT 'MEDIUM' 
        CHECK (current_difficulty IN ('EASY', 'MEDIUM', 'HARD')),
    settings JSONB NOT NULL DEFAULT '{}'::jsonb,              -- e.g. {"durationMinutes": 10, "familyFriendly": true}
    current_round INT NOT NULL DEFAULT 1 CHECK (current_round >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- Table: session_players
-- Tracks players connected to a specific session, their live scores, streaks, and stats.
-- Matches Flutter Player model (Mom, Dad, Maya, Aarav, etc.).
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS session_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(64) NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    player_id VARCHAR(64) NOT NULL,                           -- e.g. "p1", "p2", or device/client ID
    name VARCHAR(128) NOT NULL,
    avatar_name VARCHAR(64) NOT NULL DEFAULT 'default',
    role_tag VARCHAR(64) NOT NULL DEFAULT 'Player',           -- e.g. "Streak Leader", "Trivia Anchor"
    score INT NOT NULL DEFAULT 0 CHECK (score >= 0),
    streak INT NOT NULL DEFAULT 0 CHECK (streak >= 0),
    best_streak INT NOT NULL DEFAULT 0 CHECK (best_streak >= 0),
    correct_count INT NOT NULL DEFAULT 0 CHECK (correct_count >= 0),
    total_answered INT NOT NULL DEFAULT 0 CHECK (total_answered >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_session_player UNIQUE (session_id, player_id)
);

-- ------------------------------------------------------------------------------
-- Table: questions
-- Master trivia bank. Each question has exactly 4 options formatted for Flutter Option model.
-- Matches Question.fromJson contract in Flutter frontend.
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS questions (
    id VARCHAR(64) PRIMARY KEY,                               -- e.g. "q_001", "q_002"
    category VARCHAR(128) NOT NULL,                           -- e.g. "Cinema Clues", "Science & Cosmos"
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

-- ------------------------------------------------------------------------------
-- Table: player_answers
-- Logs every player's answer submission for scoring, streak audits, and adaptive difficulty.
-- Compatible with /api/sessions/:id/answer contract.
-- ------------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------------
-- Table: game_recaps
-- Stores end-game AI host insights, family synergy calculation, and next recommendations.
-- Matches SessionRecap model in Flutter and /api/sessions/:id/recap.
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS game_recaps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(64) NOT NULL UNIQUE REFERENCES sessions(id) ON DELETE CASCADE,
    host_insight TEXT NOT NULL,
    family_synergy_percent VARCHAR(16) NOT NULL DEFAULT '0%',
    avg_speed_sec VARCHAR(16) NOT NULL DEFAULT '0.0s',
    next_game_recommendation TEXT NOT NULL DEFAULT '',
    standings JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 3. INDEXES FOR PERFORMANCE
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_sessions_status ON sessions(status);
CREATE INDEX IF NOT EXISTS idx_session_players_session ON session_players(session_id);
CREATE INDEX IF NOT EXISTS idx_session_players_player ON session_players(player_id);
CREATE INDEX IF NOT EXISTS idx_questions_diff_cat ON questions(difficulty, category);
CREATE INDEX IF NOT EXISTS idx_questions_active ON questions(is_active);
CREATE INDEX IF NOT EXISTS idx_player_answers_session ON player_answers(session_id);
CREATE INDEX IF NOT EXISTS idx_player_answers_player ON player_answers(player_id);
CREATE INDEX IF NOT EXISTS idx_player_answers_question ON player_answers(question_id);
CREATE INDEX IF NOT EXISTS idx_game_recaps_session ON game_recaps(session_id);

-- ==============================================================================
-- 4. TIMESTAMP AUTO-UPDATE TRIGGERS
-- ==============================================================================

CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sessions_updated_at ON sessions;
CREATE TRIGGER trg_sessions_updated_at
BEFORE UPDATE ON sessions
FOR EACH ROW EXECUTE FUNCTION update_timestamp_column();

DROP TRIGGER IF EXISTS trg_session_players_updated_at ON session_players;
CREATE TRIGGER trg_session_players_updated_at
BEFORE UPDATE ON session_players
FOR EACH ROW EXECUTE FUNCTION update_timestamp_column();

-- ==============================================================================
-- 5. ROW LEVEL SECURITY (RLS) & ACCESS POLICIES
-- ==============================================================================

-- Enable RLS on all 5 tables
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_recaps ENABLE ROW LEVEL SECURITY;

-- Notice:
-- The PlayTogether AI backend connects using the service-role key (SUPABASE_SECRET_KEY / SUPABASE_SERVICE_ROLE_KEY).
-- In Supabase, the service-role automatically bypasses RLS for trusted server operations.

-- For client / public read access via the anon key:
-- 1. Allow reading active questions (safe for read-only consumption)
DROP POLICY IF EXISTS "Allow public read access to active questions" ON questions;
CREATE POLICY "Allow public read access to active questions" 
    ON questions FOR SELECT 
    USING (is_active = true);

-- 2. Allow read access to session info and recaps
DROP POLICY IF EXISTS "Allow public read access to sessions" ON sessions;
CREATE POLICY "Allow public read access to sessions" 
    ON sessions FOR SELECT 
    USING (true);

DROP POLICY IF EXISTS "Allow public read access to session players" ON session_players;
CREATE POLICY "Allow public read access to session players" 
    ON session_players FOR SELECT 
    USING (true);

DROP POLICY IF EXISTS "Allow public read access to game recaps" ON game_recaps;
CREATE POLICY "Allow public read access to game recaps" 
    ON game_recaps FOR SELECT 
    USING (true);

-- 3. Strict write control: Answers, score mutations, and recap generation MUST go through the backend
-- Client mutations are restricted to avoid bypassing scoring logic or cheating.

-- ==============================================================================
-- 6. SEED DATA: 32 FAMILY-FRIENDLY TRIVIA QUESTIONS
-- Balanced across EASY, MEDIUM, and HARD, with diverse categories and verified answers.
-- ==============================================================================

INSERT INTO questions (
    id, category, category_emoji, difficulty, question, quote_highlight,
    options, correct_option_id, explanation, point_value, is_active
) VALUES
-- ------------------------------------------------------------------------------
-- Category: Cinema Clues (🎬)
-- ------------------------------------------------------------------------------
(
    'q_001',
    'Cinema Clues',
    '🎬',
    'MEDIUM',
    'Which movie character is famous for the line:',
    '"May the Force be with you"',
    '[{"id":"A","text":"Luke Skywalker"},{"id":"B","text":"Han Solo"},{"id":"C","text":"Obi-Wan Kenobi"},{"id":"D","text":"Darth Vader"}]'::jsonb,
    'B',
    'Han Solo says "May the Force be with you" to Luke before the assault on the Death Star.',
    150,
    true
),
(
    'q_002',
    'Cinema Clues',
    '🎬',
    'EASY',
    'In The Wizard of Oz, what color brick road must Dorothy follow to reach Emerald City?',
    '"Follow the road to the Emerald City"',
    '[{"id":"A","text":"Yellow"},{"id":"B","text":"Red"},{"id":"C","text":"Blue"},{"id":"D","text":"Gold"}]'::jsonb,
    'A',
    'Dorothy must follow the Yellow Brick Road to find the Wizard in the Emerald City.',
    100,
    true
),
(
    'q_003',
    'Cinema Clues',
    '🎬',
    'MEDIUM',
    'Who directed the landmark 1993 cinematic dinosaur thriller Jurassic Park?',
    '"Life finds a way"',
    '[{"id":"A","text":"James Cameron"},{"id":"B","text":"Steven Spielberg"},{"id":"C","text":"George Lucas"},{"id":"D","text":"Ridley Scott"}]'::jsonb,
    'B',
    'Steven Spielberg directed Jurassic Park, which revolutionized visual effects in cinema.',
    150,
    true
),
(
    'q_004',
    'Cinema Clues',
    '🎬',
    'HARD',
    'In Christopher Nolan''s Inception, what object does Dom Cobb use as his personal totem?',
    '"An unmistakable check on reality"',
    '[{"id":"A","text":"A chess pawn"},{"id":"B","text":"A spinning top"},{"id":"C","text":"A loaded die"},{"id":"D","text":"A bronze coin"}]'::jsonb,
    'B',
    'Cobb uses a small brass spinning top originally belonging to his wife Mal to test if he is dreaming.',
    200,
    true
),
(
    'q_005',
    'Cinema Clues',
    '🎬',
    'HARD',
    'Which was the first animated feature film ever nominated for the Academy Award for Best Picture?',
    '"Tale as old as time"',
    '[{"id":"A","text":"The Lion King"},{"id":"B","text":"Snow White and the Seven Dwarfs"},{"id":"C","text":"Beauty and the Beast"},{"id":"D","text":"Toy Story"}]'::jsonb,
    'C',
    'Beauty and the Beast (1991) made history as the very first animated film nominated for Best Picture.',
    200,
    true
),
(
    'q_006',
    'Cinema Clues',
    '🎬',
    'EASY',
    'Which superhero is the secret identity of billionaire Bruce Wayne?',
    '"The Dark Knight of Gotham City"',
    '[{"id":"A","text":"Iron Man"},{"id":"B","text":"Spider-Man"},{"id":"C","text":"Batman"},{"id":"D","text":"Superman"}]'::jsonb,
    'C',
    'Bruce Wayne patrols Gotham City under the mantle of Batman.',
    100,
    true
),
(
    'q_007',
    'Cinema Clues',
    '🎬',
    'MEDIUM',
    'What fictional metal coats Wolverine''s skeleton and retractable claws?',
    '"Indestructible rare metal alloy"',
    '[{"id":"A","text":"Vibranium"},{"id":"B","text":"Mithril"},{"id":"C","text":"Adamantium"},{"id":"D","text":"Beskar"}]'::jsonb,
    'C',
    'Wolverine''s bones and claws are bonded with the indestructible fictional metal Adamantium.',
    150,
    true
),

-- ------------------------------------------------------------------------------
-- Category: Science & Cosmos (🚀)
-- ------------------------------------------------------------------------------
(
    'q_008',
    'Science & Cosmos',
    '🚀',
    'MEDIUM',
    'Which planet in our solar system has the highest surface temperature?',
    '"Surface temperature exceeds 860°F"',
    '[{"id":"A","text":"Mercury"},{"id":"B","text":"Venus"},{"id":"C","text":"Mars"},{"id":"D","text":"Jupiter"}]'::jsonb,
    'B',
    'Venus is hotter than Mercury due to an intense runaway greenhouse effect from dense carbon dioxide.',
    150,
    true
),
(
    'q_009',
    'Science & Cosmos',
    '🚀',
    'EASY',
    'What is the closest star to planet Earth?',
    '"Center of our solar system"',
    '[{"id":"A","text":"Proxima Centauri"},{"id":"B","text":"Betelgeuse"},{"id":"C","text":"The Sun"},{"id":"D","text":"Sirius"}]'::jsonb,
    'C',
    'The Sun is our home star, located roughly 93 million miles from Earth.',
    100,
    true
),
(
    'q_010',
    'Science & Cosmos',
    '🚀',
    'MEDIUM',
    'What is the most abundant gas in Earth''s atmosphere?',
    '"Comprises roughly 78% of the air we breathe"',
    '[{"id":"A","text":"Oxygen"},{"id":"B","text":"Nitrogen"},{"id":"C","text":"Carbon Dioxide"},{"id":"D","text":"Argon"}]'::jsonb,
    'B',
    'Nitrogen makes up approximately 78% of Earth''s atmosphere, while oxygen makes up about 21%.',
    150,
    true
),
(
    'q_011',
    'Science & Cosmos',
    '🚀',
    'HARD',
    'How many minutes does it take light emitted from the Sun to reach Earth?',
    '"Traveling across 93 million miles of vacuum"',
    '[{"id":"A","text":"Approx. 1 minute"},{"id":"B","text":"Approx. 4.5 minutes"},{"id":"C","text":"Approx. 8.3 minutes"},{"id":"D","text":"Approx. 15 minutes"}]'::jsonb,
    'C',
    'Light travels at 300,000 km/s and requires roughly 8 minutes and 20 seconds to reach Earth.',
    200,
    true
),
(
    'q_012',
    'Science & Cosmos',
    '🚀',
    'EASY',
    'What is the chemical symbol for the element Gold on the Periodic Table?',
    '"Derived from the Latin word Aurum"',
    '[{"id":"A","text":"Ag"},{"id":"B","text":"Au"},{"id":"C","text":"Fe"},{"id":"D","text":"Gd"}]'::jsonb,
    'B',
    'Au comes from the Latin word Aurum, meaning glowing dawn.',
    100,
    true
),
(
    'q_013',
    'Science & Cosmos',
    '🚀',
    'MEDIUM',
    'Which organ in the human body consumes roughly 20% of its total resting energy?',
    '"The central command center"',
    '[{"id":"A","text":"Heart"},{"id":"B","text":"Liver"},{"id":"C","text":"Brain"},{"id":"D","text":"Lungs"}]'::jsonb,
    'C',
    'Despite accounting for only 2% of body weight, the human brain consumes about 20% of resting metabolic energy.',
    150,
    true
),
(
    'q_014',
    'Science & Cosmos',
    '🚀',
    'HARD',
    'Which fundamental subatomic particle carries no electric charge?',
    '"Located alongside protons in the atomic nucleus"',
    '[{"id":"A","text":"Electron"},{"id":"B","text":"Positron"},{"id":"C","text":"Neutron"},{"id":"D","text":"Muon"}]'::jsonb,
    'C',
    'Neutrons are electrically neutral subatomic particles residing in the nucleus.',
    200,
    true
),

-- ------------------------------------------------------------------------------
-- Category: Pop Culture & Music (🎵)
-- ------------------------------------------------------------------------------
(
    'q_015',
    'Pop Culture & Music',
    '🎵',
    'EASY',
    'Which famous band performed an impromptu concert on the roof of Apple Records in 1969?',
    '"Get Back to where you once belonged"',
    '[{"id":"A","text":"The Rolling Stones"},{"id":"B","text":"The Beatles"},{"id":"C","text":"Queen"},{"id":"D","text":"Led Zeppelin"}]'::jsonb,
    'B',
    'The Beatles gave their final public rooftop performance at their London headquarters in January 1969.',
    100,
    true
),
(
    'q_016',
    'Pop Culture & Music',
    '🎵',
    'MEDIUM',
    'Which artist released the all-time best-selling studio album Thriller in 1982?',
    '"Cause this is thriller, thriller night"',
    '[{"id":"A","text":"Prince"},{"id":"B","text":"Stevie Wonder"},{"id":"C","text":"Michael Jackson"},{"id":"D","text":"Lionel Richie"}]'::jsonb,
    'C',
    'Michael Jackson''s Thriller became the best-selling album of all time worldwide.',
    150,
    true
),
(
    'q_017',
    'Pop Culture & Music',
    '🎵',
    'EASY',
    'What was Elvis Presley widely celebrated as in musical history?',
    '"Hail to the pioneer of rock n roll"',
    '[{"id":"A","text":"The Duke"},{"id":"B","text":"The Boss"},{"id":"C","text":"The King"},{"id":"D","text":"The Prince"}]'::jsonb,
    'C',
    'Elvis Presley is globally known as "The King of Rock and Roll".',
    100,
    true
),
(
    'q_018',
    'Pop Culture & Music',
    '🎵',
    'HARD',
    'In what year did the legendary original Woodstock Music & Art Fair take place?',
    '"3 Days of Peace & Music"',
    '[{"id":"A","text":"1967"},{"id":"B","text":"1969"},{"id":"C","text":"1971"},{"id":"D","text":"1973"}]'::jsonb,
    'B',
    'The historic Woodstock festival took place in August 1969 on Max Yasgur''s dairy farm in Bethel, New York.',
    200,
    true
),
(
    'q_019',
    'Pop Culture & Music',
    '🎵',
    'MEDIUM',
    'Who is the legendary Nintendo game designer who created Super Mario, Donkey Kong, and Zelda?',
    '"Father of modern interactive gaming"',
    '[{"id":"A","text":"Hideo Kojima"},{"id":"B","text":"Shigeru Miyamoto"},{"id":"C","text":"Satoru Iwata"},{"id":"D","text":"Masahiro Sakurai"}]'::jsonb,
    'B',
    'Shigeru Miyamoto is the celebrated visionary behind many of Nintendo''s most iconic franchises.',
    150,
    true
),

-- ------------------------------------------------------------------------------
-- Category: Animation & Family (✨)
-- ------------------------------------------------------------------------------
(
    'q_020',
    'Animation & Family',
    '✨',
    'EASY',
    'In Disney''s Toy Story, what is the name of Woody and Andy''s real pet Dachshund?',
    '"You''ve got a friend in me"',
    '[{"id":"A","text":"Slinky"},{"id":"B","text":"Buster"},{"id":"C","text":"Rex"},{"id":"D","text":"Scud"}]'::jsonb,
    'B',
    'Buster is Andy''s pet Dachshund who listens to Woody''s commands.',
    100,
    true
),
(
    'q_021',
    'Animation & Family',
    '✨',
    'MEDIUM',
    'In Pixar''s Finding Nemo, what address in Sydney is written on the diver''s scuba mask?',
    '"P. Sherman, 42 Wallaby Way..."',
    '[{"id":"A","text":"42 Wallaby Way, Sydney"},{"id":"B","text":"12 Ocean Boulevard, Sydney"},{"id":"C","text":"24 Coral Reef Drive, Sydney"},{"id":"D","text":"88 Harbour Bridge Way, Sydney"}]'::jsonb,
    'A',
    'Dory famously memorizes the dentist''s address: "P. Sherman, 42 Wallaby Way, Sydney".',
    150,
    true
),
(
    'q_022',
    'Animation & Family',
    '✨',
    'EASY',
    'In Disney''s The Lion King, what does the memorable phrase "Hakuna Matata" mean?',
    '"No worries for the rest of your days"',
    '[{"id":"A","text":"Be brave always"},{"id":"B","text":"No worries"},{"id":"C","text":"Family first"},{"id":"D","text":"Circle of life"}]'::jsonb,
    'B',
    'Timon and Pumbaa teach Simba that Hakuna Matata is a Swahili phrase meaning "no worries".',
    100,
    true
),
(
    'q_023',
    'Animation & Family',
    '✨',
    'MEDIUM',
    'What is the name of the superhero family''s multi-powered baby in The Incredibles?',
    '"A baby bursting with super abilities"',
    '[{"id":"A","text":"Dash"},{"id":"B","text":"Jack-Jack"},{"id":"C","text":"Buddy"},{"id":"D","text":"Bob Jr."}]'::jsonb,
    'B',
    'Jack-Jack Parr exhibits a hilarious variety of shapeshifting and energetic superpowers.',
    150,
    true
),
(
    'q_024',
    'Animation & Family',
    '✨',
    'HARD',
    'In Hayao Miyazaki''s masterpiece Spirited Away, what animals are Chihiro''s parents transformed into?',
    '"Punished for gorging on spirit feast"',
    '[{"id":"A","text":"Toads"},{"id":"B","text":"Pigs"},{"id":"C","text":"Wolves"},{"id":"D","text":"Crows"}]'::jsonb,
    'B',
    'Chihiro''s parents greedily consume food meant for spirits and are turned into pigs.',
    200,
    true
),

-- ------------------------------------------------------------------------------
-- Category: General Knowledge (🌍)
-- ------------------------------------------------------------------------------
(
    'q_025',
    'General Knowledge',
    '🌍',
    'EASY',
    'Which country is home to the famous ancient Great Pyramids of Giza?',
    '"Land of the Pharaohs along the Nile"',
    '[{"id":"A","text":"Greece"},{"id":"B","text":"Mexico"},{"id":"C","text":"Egypt"},{"id":"D","text":"Peru"}]'::jsonb,
    'C',
    'The Pyramids of Giza were built along the Nile River in Egypt.',
    100,
    true
),
(
    'q_026',
    'General Knowledge',
    '🌍',
    'MEDIUM',
    'Which is the largest ocean on planet Earth by total surface area?',
    '"Covers more area than all land masses combined"',
    '[{"id":"A","text":"Atlantic Ocean"},{"id":"B","text":"Indian Ocean"},{"id":"C","text":"Pacific Ocean"},{"id":"D","text":"Arctic Ocean"}]'::jsonb,
    'C',
    'The Pacific Ocean spans over 60 million square miles, covering over 30% of the globe.',
    150,
    true
),
(
    'q_027',
    'General Knowledge',
    '🌍',
    'HARD',
    'What is the official federal capital city of Australia?',
    '"A purpose-built planned national capital"',
    '[{"id":"A","text":"Sydney"},{"id":"B","text":"Melbourne"},{"id":"C","text":"Brisbane"},{"id":"D","text":"Canberra"}]'::jsonb,
    'D',
    'Canberra was selected as Australia''s capital in 1908 as a compromise between Sydney and Melbourne.',
    200,
    true
),
(
    'q_028',
    'General Knowledge',
    '🌍',
    'EASY',
    'How many continents are there on planet Earth?',
    '"Major land divisions of our planet"',
    '[{"id":"A","text":"5"},{"id":"B","text":"6"},{"id":"C","text":"7"},{"id":"D","text":"8"}]'::jsonb,
    'C',
    'Earth has seven continents: Asia, Africa, North America, South America, Antarctica, Europe, and Australia.',
    100,
    true
),
(
    'q_029',
    'General Knowledge',
    '🌍',
    'MEDIUM',
    'What is the hardest naturally occurring mineral discovered on Earth?',
    '"Pure crystalline carbon under extreme pressure"',
    '[{"id":"A","text":"Quartz"},{"id":"B","text":"Topaz"},{"id":"C","text":"Corundum"},{"id":"D","text":"Diamond"}]'::jsonb,
    'D',
    'Diamond rates as a 10 on the Mohs hardness scale, making it the hardest natural mineral.',
    150,
    true
),

-- ------------------------------------------------------------------------------
-- Category: Surprise Buzzer Blitz (⚡)
-- ------------------------------------------------------------------------------
(
    'q_030',
    'Surprise Buzzer Blitz',
    '⚡',
    'HARD',
    'Which mammal is documented to possess a bite force exceeding 1,200 PSI?',
    '"River giant with devastating jaw power"',
    '[{"id":"A","text":"Grizzly Bear"},{"id":"B","text":"Hippopotamus"},{"id":"C","text":"African Lion"},{"id":"D","text":"Jaguar"}]'::jsonb,
    'B',
    'Hippopotamuses have an astonishing bite force measured above 1,260 PSI, among the strongest on Earth.',
    300,
    true
),
(
    'q_031',
    'Surprise Buzzer Blitz',
    '⚡',
    'HARD',
    'What is the speed of light in a vacuum to the nearest thousand kilometers per second?',
    '"Fundamental physical constant c"',
    '[{"id":"A","text":"150,000 km/s"},{"id":"B","text":"300,000 km/s"},{"id":"C","text":"450,000 km/s"},{"id":"D","text":"600,000 km/s"}]'::jsonb,
    'B',
    'The speed of light in vacuum is approximately 299,792 km/s, rounded to 300,000 km/s.',
    300,
    true
),
(
    'q_032',
    'Surprise Buzzer Blitz',
    '⚡',
    'HARD',
    'Which bird species is clocked as the fastest animal on the planet during its hunting dive?',
    '"Speeds exceeding 240 mph during high-speed stoop"',
    '[{"id":"A","text":"Golden Eagle"},{"id":"B","text":"Peregrine Falcon"},{"id":"C","text":"Red-tailed Hawk"},{"id":"D","text":"Osprey"}]'::jsonb,
    'B',
    'The Peregrine Falcon reaches dive speeds exceeding 240 mph (389 km/h) when hunting in midair.',
    300,
    true
)
ON CONFLICT (id) DO UPDATE SET
    category = EXCLUDED.category,
    category_emoji = EXCLUDED.category_emoji,
    difficulty = EXCLUDED.difficulty,
    question = EXCLUDED.question,
    quote_highlight = EXCLUDED.quote_highlight,
    options = EXCLUDED.options,
    correct_option_id = EXCLUDED.correct_option_id,
    explanation = EXCLUDED.explanation,
    point_value = EXCLUDED.point_value,
    is_active = EXCLUDED.is_active;
