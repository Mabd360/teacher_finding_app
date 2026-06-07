-- =============================================================================
-- ADD REVIEWS TABLE FOR TEACHER RATINGS
-- =============================================================================

CREATE TABLE IF NOT EXISTS reviews (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id      UUID         NOT NULL REFERENCES class_sessions(id) ON DELETE CASCADE,
    student_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    teacher_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating          INTEGER      NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment         TEXT,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Only one review per session
CREATE UNIQUE INDEX IF NOT EXISTS idx_reviews_unique_session ON reviews(session_id);
CREATE INDEX IF NOT EXISTS idx_reviews_teacher_id ON reviews(teacher_id);
CREATE INDEX IF NOT EXISTS idx_reviews_student_id ON reviews(student_id);
