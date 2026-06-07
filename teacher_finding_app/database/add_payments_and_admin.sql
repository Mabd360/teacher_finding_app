-- =============================================================================
-- ADD PAYMENT & ADMIN FUNCTIONALITY TO DATABASE
-- =============================================================================

-- 1. Add admin role support
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'admin';

-- 2. Create payments table
CREATE TABLE IF NOT EXISTS payments (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID         NOT NULL REFERENCES requests (id) ON DELETE CASCADE,
    student_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    teacher_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    amount          DECIMAL(10,2) NOT NULL,
    duration_hours  DECIMAL(5,2) NOT NULL DEFAULT 1.0,
    status          VARCHAR(20)  NOT NULL DEFAULT 'unpaid', -- unpaid, paid, cancelled
    payment_date    TIMESTAMP,
    notes           TEXT,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- 3. Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_payments_student_id ON payments(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_teacher_id ON payments(teacher_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);

-- 4. Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id        UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    payment_id      UUID         REFERENCES payments (id) ON DELETE CASCADE,
    type            VARCHAR(50)  NOT NULL, -- payment_confirmed, new_class, etc
    title           VARCHAR(255) NOT NULL,
    message         TEXT         NOT NULL,
    is_read         BOOLEAN      DEFAULT FALSE,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_admin_id ON notifications(admin_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- 5. Create sessions table (optional, for tracking class sessions)
CREATE TABLE IF NOT EXISTS class_sessions (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID         NOT NULL REFERENCES requests (id) ON DELETE CASCADE,
    student_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    teacher_id      UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    subject         VARCHAR(255) NOT NULL,
    scheduled_date  TIMESTAMP    NOT NULL,
    duration_hours  DECIMAL(5,2) NOT NULL DEFAULT 1.0,
    status          VARCHAR(20)  NOT NULL DEFAULT 'scheduled', -- scheduled, completed, cancelled
    notes           TEXT,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_class_sessions_teacher_id ON class_sessions(teacher_id);
CREATE INDEX IF NOT EXISTS idx_class_sessions_student_id ON class_sessions(student_id);
CREATE INDEX IF NOT EXISTS idx_class_sessions_status ON class_sessions(status);
