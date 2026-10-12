-- ==============================================================================
-- PlayTogether AI — Migration 02: Atomic RPC Helper Functions
-- ==============================================================================

-- 1. Atomic Session Creation with Players
CREATE OR REPLACE FUNCTION create_session_with_players(
    p_session_id VARCHAR(64),
    p_settings JSONB,
    p_initial_difficulty VARCHAR(16),
    p_players JSONB
)
RETURNS JSONB AS $$
DECLARE
    v_player JSONB;
BEGIN
    INSERT INTO sessions (id, status, current_difficulty, settings, current_round)
    VALUES (p_session_id, 'active', p_initial_difficulty, p_settings, 1)
    ON CONFLICT (id) DO UPDATE SET
        current_difficulty = EXCLUDED.current_difficulty,
        settings = EXCLUDED.settings,
        updated_at = NOW();

    FOR v_player IN SELECT * FROM jsonb_array_elements(p_players)
    LOOP
        INSERT INTO session_players (
            session_id,
            player_id,
            name,
            avatar_name,
            role_tag,
            score,
            streak,
            best_streak,
            correct_count,
            total_answered
        ) VALUES (
            p_session_id,
            v_player->>'playerId',
            v_player->>'name',
            COALESCE(v_player->>'avatarName', v_player->>'name', 'default'),
            COALESCE(v_player->>'roleTag', 'Player'),
            0,
            0,
            0,
            0,
            0
        )
        ON CONFLICT (session_id, player_id) DO UPDATE SET
            name = EXCLUDED.name,
            avatar_name = EXCLUDED.avatar_name,
            updated_at = NOW();
    END LOOP;

    RETURN jsonb_build_object(
        'success', true,
        'sessionId', p_session_id
    );
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to create session with players: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- 2. Atomic Submit Answer & Score Update
CREATE OR REPLACE FUNCTION submit_player_answer(
    p_session_id VARCHAR(64),
    p_player_id VARCHAR(64),
    p_question_id VARCHAR(64),
    p_selected_option_id VARCHAR(4),
    p_is_correct BOOLEAN,
    p_points_earned INT,
    p_response_time_seconds NUMERIC(6, 2)
)
RETURNS JSONB AS $$
DECLARE
    v_current_streak INT;
    v_current_best_streak INT;
    v_new_streak INT;
    v_new_best_streak INT;
BEGIN
    IF EXISTS (
        SELECT 1 FROM player_answers
        WHERE session_id = p_session_id
          AND player_id = p_player_id
          AND question_id = p_question_id
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'DuplicateSubmission',
            'message', 'Player has already answered this question in this session.'
        );
    END IF;

    INSERT INTO player_answers (
        session_id,
        player_id,
        question_id,
        selected_option_id,
        is_correct,
        points_earned,
        response_time_seconds
    ) VALUES (
        p_session_id,
        p_player_id,
        p_question_id,
        p_selected_option_id,
        p_is_correct,
        p_points_earned,
        p_response_time_seconds
    );

    SELECT streak, best_streak INTO v_current_streak, v_current_best_streak
    FROM session_players
    WHERE session_id = p_session_id AND player_id = p_player_id
    FOR UPDATE;

    IF FOUND THEN
        IF p_is_correct THEN
            v_new_streak := v_current_streak + 1;
            v_new_best_streak := GREATEST(v_current_best_streak, v_new_streak);

            UPDATE session_players
            SET score = score + p_points_earned,
                streak = v_new_streak,
                best_streak = v_new_best_streak,
                correct_count = correct_count + 1,
                total_answered = total_answered + 1,
                updated_at = NOW()
            WHERE session_id = p_session_id AND player_id = p_player_id;
        ELSE
            UPDATE session_players
            SET streak = 0,
                total_answered = total_answered + 1,
                updated_at = NOW()
            WHERE session_id = p_session_id AND player_id = p_player_id;
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'pointsEarned', p_points_earned,
        'newStreak', COALESCE(v_new_streak, 0)
    );
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to submit answer atomically: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
