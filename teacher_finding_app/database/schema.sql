-- =============================================================================
-- Teacher Finder — PostgreSQL Database Schema
-- =============================================================================
-- Tech stack: Flutter (frontend) · Node.js + Express (backend) · PostgreSQL (DB)
-- =============================================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- ENUM TYPE
-- =============================================================================

CREATE TYPE user_role AS ENUM ('student', 'teacher');

-- =============================================================================
-- 1. USERS TABLE
-- =============================================================================

CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    role          user_role    NOT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 2. TEACHER_PROFILES TABLE
-- =============================================================================
-- availability JSONB structure:
-- [
--   { "day": "Monday", "slots": ["9:00-12:00", "14:00-17:00"] },
--   { "day": "Wednesday", "slots": ["10:00-13:00"] }
-- ]
-- =============================================================================

CREATE TABLE teacher_profiles (
    id           UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id      UUID          NOT NULL UNIQUE
                               REFERENCES users (id) ON DELETE CASCADE,
    subjects     TEXT[]        NOT NULL DEFAULT '{}',
    fee_per_hour DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    availability JSONB,
    bio          TEXT,
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_teacher_profiles_user_id ON teacher_profiles (user_id);

-- =============================================================================
-- 3. REQUESTS TABLE
-- =============================================================================

CREATE TABLE requests (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id  UUID        NOT NULL
                            REFERENCES users (id) ON DELETE CASCADE,
    teacher_id  UUID        NOT NULL
                            REFERENCES users (id) ON DELETE CASCADE,
    message     TEXT,
    status      VARCHAR(20) NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending', 'accepted', 'rejected')),
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_requests_student_id ON requests (student_id);
CREATE INDEX idx_requests_teacher_id ON requests (teacher_id);

-- Prevent duplicate pending requests from same student to same teacher
CREATE UNIQUE INDEX idx_unique_pending_request
    ON requests (student_id, teacher_id)
    WHERE status = 'pending';

-- =============================================================================
-- 4. AUTO-UPDATE updated_at TRIGGER
-- =============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER update_teacher_profiles_updated_at
    BEFORE UPDATE ON teacher_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_requests_updated_at
    BEFORE UPDATE ON requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- 5. SAMPLE DATA
-- =============================================================================
-- Passwords are bcrypt of "password123" — for testing only
-- =============================================================================

-- Student
INSERT INTO users (name, email, password_hash, role)
VALUES (
    'Ali Khan',
    'ali.khan@example.com',
    '$2b$10$EIXe0eK9pXIGh7OLYL5MQOQFpKv8aXkOeU6UGJcjGKzVmKBdWqLdi',
    'student'
);

-- Teacher
INSERT INTO users (name, email, password_hash, role)
VALUES (
    'Sara Ahmed',
    'sara.ahmed@example.com',
    '$2b$10$EIXe0eK9pXIGh7OLYL5MQOQFpKv8aXkOeU6UGJcjGKzVmKBdWqLdi',
    'teacher'
);

-- Teacher profile
INSERT INTO teacher_profiles (user_id, subjects, fee_per_hour, availability, bio)
VALUES (
    (SELECT id FROM users WHERE email = 'sara.ahmed@example.com'),
    ARRAY['Mathematics', 'Physics'],
    1500.00,
    '[
        { "day": "Monday",    "slots": ["9:00-12:00", "14:00-17:00"] },
        { "day": "Wednesday", "slots": ["10:00-13:00"] },
        { "day": "Friday",    "slots": ["9:00-11:00", "15:00-18:00"] }
    ]'::jsonb,
    'Experienced math and physics teacher with 5 years of tutoring.'
);

-- Request from student to teacher
INSERT INTO requests (student_id, teacher_id, message)
VALUES (
    (SELECT id FROM users WHERE email = 'ali.khan@example.com'),
    (SELECT id FROM users WHERE email = 'sara.ahmed@example.com'),
    'Hi Sara, I need help with calculus. Are you available on Mondays?'
);