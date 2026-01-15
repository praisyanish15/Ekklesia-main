-- ============================================
-- DISCIPLESHIP PATHS DATABASE SCHEMA
-- ============================================
-- This schema supports the Discipleship Paths feature:
-- - Pre-defined growth paths (New Believer, Youth, etc.)
-- - Weekly steps with verse, devotion, reflection, action
-- - User progress tracking
-- - "My Next Step" functionality
-- ============================================

-- Create discipleship_paths table
CREATE TABLE IF NOT EXISTS discipleship_paths (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('newBeliever', 'youth', 'prayerFasting', 'leadership', 'marriage', 'parenting')),
    duration_weeks INTEGER NOT NULL,
    icon_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create weekly_steps table
CREATE TABLE IF NOT EXISTS weekly_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    path_id UUID NOT NULL REFERENCES discipleship_paths(id) ON DELETE CASCADE,
    week_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    verse TEXT NOT NULL,
    verse_reference TEXT NOT NULL,
    devotion TEXT NOT NULL,
    reflection_question TEXT NOT NULL,
    action_step TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(path_id, week_number)
);

-- Create user_progress table
CREATE TABLE IF NOT EXISTS user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    path_id UUID NOT NULL REFERENCES discipleship_paths(id) ON DELETE CASCADE,
    current_week INTEGER DEFAULT 1,
    is_completed BOOLEAN DEFAULT false,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, path_id)
);

-- Create indexes
CREATE INDEX idx_weekly_steps_path_id ON weekly_steps(path_id);
CREATE INDEX idx_weekly_steps_week_number ON weekly_steps(week_number);
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_path_id ON user_progress(path_id);
CREATE INDEX idx_user_progress_completed ON user_progress(is_completed);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS
ALTER TABLE discipleship_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- Policies: Everyone can view paths and steps
CREATE POLICY "Anyone can view discipleship paths"
    ON discipleship_paths
    FOR SELECT
    USING (true);

CREATE POLICY "Anyone can view weekly steps"
    ON weekly_steps
    FOR SELECT
    USING (true);

-- Policies: Users can view their own progress
CREATE POLICY "Users can view their own progress"
    ON user_progress
    FOR SELECT
    USING (user_id = auth.uid());

-- Policies: Users can create their own progress
CREATE POLICY "Users can create their own progress"
    ON user_progress
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- Policies: Users can update their own progress
CREATE POLICY "Users can update their own progress"
    ON user_progress
    FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- ============================================
-- SEED DATA - NEW BELIEVER PATH
-- ============================================

-- Insert New Believer Path
INSERT INTO discipleship_paths (name, description, type, duration_weeks)
VALUES
    ('New Believer Journey', 'Your first steps in faith. Discover what it means to follow Jesus.', 'newBeliever', 8);

-- Get the path ID for reference (you'll need to update this after running)
-- For now, we'll use a placeholder - replace 'NEW_BELIEVER_PATH_ID' with actual UUID after creation

-- Week 1: Salvation
INSERT INTO weekly_steps (path_id, week_number, title, verse, verse_reference, devotion, reflection_question, action_step)
SELECT id, 1,
    'Understanding Salvation',
    'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
    'John 3:16',
    'Salvation is a gift from God. You didn''t earn it, and you can''t lose it. When you accepted Jesus, God forgave all your sins - past, present, and future. This week, let this truth sink deep into your heart: You are saved, loved, and secure in Christ.',
    'What does it mean to you personally that salvation is a gift, not something you earned?',
    'Share your salvation story with one person this week - a friend, family member, or someone at church.'
FROM discipleship_paths WHERE type = 'newBeliever';

-- Week 2: Prayer
INSERT INTO weekly_steps (path_id, week_number, title, verse, verse_reference, devotion, reflection_question, action_step)
SELECT id, 2,
    'Learning to Pray',
    'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.',
    'Philippians 4:6',
    'Prayer is simply talking to God. You don''t need fancy words or religious language. God wants to hear from you - your joys, struggles, questions, and thanks. This week, practice praying throughout your day, not just at meals or bedtime.',
    'What has stopped you from praying more regularly? How can you overcome that this week?',
    'Set aside 10 minutes each day this week to pray. Start by thanking God, then share your needs.'
FROM discipleship_paths WHERE type = 'newBeliever';

-- Week 3: Reading the Bible
INSERT INTO weekly_steps (path_id, week_number, title, verse, verse_reference, devotion, reflection_question, action_step)
SELECT id, 3,
    'God''s Word',
    'Your word is a lamp for my feet, a light on my path.',
    'Psalm 119:105',
    'The Bible is God''s love letter to you. It''s how He speaks to us today. Start small - even 5 minutes a day. Read the Gospel of John to learn about Jesus'' life. Don''t worry if you don''t understand everything; God will reveal truth as you grow.',
    'What questions do you have about the Bible? Who can you ask for help understanding it?',
    'Read John chapters 1-3 this week. Write down one thing that stands out to you each day.'
FROM discipleship_paths WHERE type = 'newBeliever';

-- Week 4: Church Family
INSERT INTO weekly_steps (path_id, week_number, title, verse, verse_reference, devotion, reflection_question, action_step)
SELECT id, 4,
    'Finding Your Church Family',
    'And let us consider how we may spur one another on toward love and good deeds, not giving up meeting together.',
    'Hebrews 10:24-25',
    'You weren''t meant to follow Jesus alone. The church is your spiritual family - people who will pray for you, encourage you, and walk with you. Get involved! Join a small group, serve in a ministry, and build friendships.',
    'What fears or hesitations do you have about getting involved in church?',
    'Introduce yourself to three new people at church this week. Consider joining a small group or ministry.'
FROM discipleship_paths WHERE type = 'newBeliever';

-- Week 5: Baptism
INSERT INTO weekly_steps (path_id, week_number, title, verse, verse_reference, devotion, reflection_question, action_step)
SELECT id, 5,
    'Public Declaration',
    'We were therefore buried with him through baptism into death in order that, just as Christ was raised from the dead through the glory of the Father, we too may live a new life.',
    'Romans 6:4',
    'Baptism is your public declaration that you belong to Jesus. It symbolizes your old life dying and your new life beginning in Christ. If you haven''t been baptized since believing in Jesus, this is your next step of obedience.',
    'Have you been baptized as a believer? If not, what''s holding you back?',
    'Talk to a pastor or leader about baptism. If you''re ready, sign up for the next baptism class.'
FROM discipleship_paths WHERE type = 'newBeliever';

-- Week 6: The Holy Spirit
INSERT INTO weekly_steps (path_id, week_number, title, verse, verse_reference, devotion, reflection_question, action_step)
SELECT id, 6,
    'Your Helper',
    'But the Advocate, the Holy Spirit, whom the Father will send in my name, will teach you all things and will remind you of everything I have said to you.',
    'John 14:26',
    'When you accepted Jesus, the Holy Spirit came to live in you. He is your helper, guide, and comforter. He gives you power to live for God and helps you understand the Bible. Learn to listen to His gentle voice.',
    'Have you experienced the Holy Spirit''s guidance? How?',
    'Ask the Holy Spirit to fill you afresh each morning this week. Pay attention to His promptings throughout the day.'
FROM discipleship_paths WHERE type = 'newBeliever';

-- Week 7: Sharing Your Faith
INSERT INTO weekly_steps (path_id, week_number, title, verse, verse_reference, devotion, reflection_question, action_step)
SELECT id, 7,
    'Telling Others',
    'But in your hearts revere Christ as Lord. Always be prepared to give an answer to everyone who asks you to give the reason for the hope that you have. But do this with gentleness and respect.',
    '1 Peter 3:15',
    'You don''t need to know everything to share your faith. Simply share what Jesus has done in your life. Your story is powerful! Be ready to tell others why you believe and how Jesus has changed you.',
    'Who in your life needs to hear about Jesus? What''s one way you can show them God''s love this week?',
    'Pray for one non-believing friend or family member daily. Ask God for an opportunity to share your faith.'
FROM discipleship_paths WHERE type = 'newBeliever';

-- Week 8: Keep Growing
INSERT INTO weekly_steps (path_id, week_number, title, verse, verse_reference, devotion, reflection_question, action_step)
SELECT id, 8,
    'Your Journey Continues',
    'Therefore, since we are surrounded by such a great cloud of witnesses, let us throw off everything that hinders and the sin that so easily entangles. And let us run with perseverance the race marked out for us.',
    'Hebrews 12:1',
    'Congratulations on completing this path! But this is just the beginning. Your faith journey is a lifelong adventure with Jesus. Keep praying, reading the Bible, serving, and growing. The best is yet to come!',
    'What''s the most important thing you''ve learned in these 8 weeks?',
    'Choose your next growth step: Join a Bible study, start serving regularly, or begin mentoring another new believer.'
FROM discipleship_paths WHERE type = 'newBeliever';

-- ============================================
-- SEED DATA - YOUTH PATH
-- ============================================

INSERT INTO discipleship_paths (name, description, type, duration_weeks)
VALUES
    ('Youth Growth Journey', 'Navigate faith, friends, and your future with Jesus.', 'youth', 6);

-- ============================================
-- SEED DATA - PRAYER & FASTING PATH
-- ============================================

INSERT INTO discipleship_paths (name, description, type, duration_weeks)
VALUES
    ('Prayer & Fasting', 'Deepen your intimacy with God through prayer and fasting.', 'prayerFasting', 4);

-- ============================================
-- USEFUL QUERIES FOR ADMINS
-- ============================================

-- Get all paths with step counts
-- SELECT p.name, p.type, COUNT(w.id) as total_weeks
-- FROM discipleship_paths p
-- LEFT JOIN weekly_steps w ON p.id = w.path_id
-- GROUP BY p.id, p.name, p.type;

-- Get user progress summary
-- SELECT u.email, p.name, up.current_week, up.is_completed
-- FROM user_progress up
-- JOIN auth.users u ON up.user_id = u.id
-- JOIN discipleship_paths p ON up.path_id = p.id
-- ORDER BY up.last_accessed_at DESC;

-- Get completion rate by path
-- SELECT p.name,
--        COUNT(*) as total_users,
--        SUM(CASE WHEN up.is_completed THEN 1 ELSE 0 END) as completed,
--        ROUND(100.0 * SUM(CASE WHEN up.is_completed THEN 1 ELSE 0 END) / COUNT(*), 2) as completion_rate
-- FROM user_progress up
-- JOIN discipleship_paths p ON up.path_id = p.id
-- GROUP BY p.id, p.name;
