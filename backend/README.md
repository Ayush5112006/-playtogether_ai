# PlayTogether AI — Backend & Supabase Database Setup

This directory contains the Express + TypeScript backend and PostgreSQL database schema for **PlayTogether AI**, built for the Amazon Fire TV hackathon.

---

## Database Architecture Overview (Phase 2)

The database schema (`schema.sql`) implements five PostgreSQL tables matching the Flutter frontend models and backend API contracts:

1. **`sessions`**: Active game sessions, current round, difficulty (`EASY`, `MEDIUM`, `HARD`), and settings JSON.
2. **`session_players`**: Players connected to a session, scores, streaks, best streak, and answer statistics.
3. **`questions`**: Master trivia question bank with `JSONB` 4-option arrays, correct option ID, category emoji, point values, and explanations.
4. **`player_answers`**: Audit log of submitted answers, correctness, response times, and points earned.
5. **`game_recaps`**: Post-game AI host insights, family synergy percentages, speed metrics, and recommended next games.

---

## How to Run `schema.sql` in Supabase

### Step 1: Open Supabase SQL Editor
1. Log in to your [Supabase Dashboard](https://supabase.com/dashboard).
2. Select your project (Project URL: `https://xwgslqfpymsysastllnk.supabase.co`).
3. In the left navigation menu, click on the **SQL Editor** icon (represented by the `>_` terminal symbol).
4. Click **New query** in the top-left corner.

### Step 2: Paste and Execute `schema.sql`
1. Open the [backend/schema.sql](file:///d:/SEM%205/-playtogether_ai/backend/schema.sql) file.
2. Copy the entire contents of `schema.sql`.
3. Paste the SQL into the Supabase SQL Editor query box.
4. Click **Run** (or press `Ctrl + Enter` / `Cmd + Enter`).
5. Ensure the result message shows `Success. No rows returned` or execution completed without errors.

---

## Verification Queries

Run these verification queries in the Supabase SQL Editor to confirm the setup:

### 1. Verify All 5 Tables Exist
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('sessions', 'session_players', 'questions', 'player_answers', 'game_recaps')
ORDER BY table_name;
```
*Expected Result:* Returns all 5 tables (`game_recaps`, `player_answers`, `questions`, `session_players`, `sessions`).

---

### 2. Verify Seed Questions Count and Categories
```sql
SELECT 
    category, 
    difficulty, 
    COUNT(*) AS question_count
FROM questions
GROUP BY category, difficulty
ORDER BY category, difficulty;
```
*Expected Result:* 32 total trivia questions categorized across Cinema Clues, Science & Cosmos, Pop Culture & Music, Animation & Family, General Knowledge, and Surprise Buzzer Blitz.

---

### 3. Verify All Questions Have Exactly 4 Valid Options
```sql
SELECT 
    id, 
    category,
    jsonb_array_length(options) AS option_count,
    correct_option_id
FROM questions
WHERE jsonb_array_length(options) != 4 
   OR correct_option_id NOT IN ('A', 'B', 'C', 'D');
```
*Expected Result:* **0 rows**. Every question strictly satisfies the 4-option constraint and valid correct option ID.

---

### 4. Verify Row Level Security (RLS) is Active
```sql
SELECT 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('sessions', 'session_players', 'questions', 'player_answers', 'game_recaps');
```
*Expected Result:* `rowsecurity` is `true` for all 5 tables.

---

## Troubleshooting SQL Errors

- **Error: `relation already exists`**
  - The script uses `CREATE TABLE IF NOT EXISTS` and `CREATE INDEX IF NOT EXISTS`. You do not need to drop existing tables.
- **Error: `check constraint violates`**
  - Check constraints ensure `difficulty` is strictly `'EASY'`, `'MEDIUM'`, or `'HARD'`, `options` has exactly 4 items, and `score`/`streak` are non-negative.
- **Trigger errors on re-run:**
  - The script uses `DROP TRIGGER IF EXISTS` before creating triggers to ensure safe, idempotent re-execution.
- **Duplicate Key Error on Questions:**
  - The seed questions use `ON CONFLICT (id) DO UPDATE`, allowing you to re-run the script safely at any time without duplicate key conflicts.

---

## Next Steps (Phase 3)
Once the schema is executed in your Supabase project:
- Update `GET /api/health` to reflect detected schema tables.
- Implement database services in `backend/src/services/` to query dynamic questions and persist player answers.
