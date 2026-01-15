-- ============================================
-- PRAYER WALL (ShepherdCare) DATABASE SCHEMA
-- ============================================
-- This schema supports the Prayer Wall feature with:
-- - Public/Private/Leadership privacy levels
-- - Active/Answered/Archived status tracking
-- - Prayer count tracking
-- - Answered prayer testimonies
-- - Category-based organization
-- ============================================

-- Create prayer_requests table
CREATE TABLE IF NOT EXISTS prayer_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_photo_url TEXT,
    church_id UUID NOT NULL REFERENCES churches(id) ON DELETE CASCADE,

    -- Prayer content
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('general', 'health', 'family', 'financial', 'spiritual', 'other')),

    -- Privacy & Status
    privacy TEXT NOT NULL DEFAULT 'public' CHECK (privacy IN ('public', 'private', 'leadership')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'answered', 'archived')),

    -- Flags
    is_urgent BOOLEAN DEFAULT false,
    is_anonymous BOOLEAN DEFAULT false,

    -- Metrics
    prayer_count INTEGER DEFAULT 0,

    -- Answered prayer data
    answered_testimony TEXT,
    answered_at TIMESTAMP WITH TIME ZONE,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_prayer_requests_church_id ON prayer_requests(church_id);
CREATE INDEX idx_prayer_requests_user_id ON prayer_requests(user_id);
CREATE INDEX idx_prayer_requests_status ON prayer_requests(status);
CREATE INDEX idx_prayer_requests_privacy ON prayer_requests(privacy);
CREATE INDEX idx_prayer_requests_category ON prayer_requests(category);
CREATE INDEX idx_prayer_requests_created_at ON prayer_requests(created_at DESC);
CREATE INDEX idx_prayer_requests_is_urgent ON prayer_requests(is_urgent);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS
ALTER TABLE prayer_requests ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view public prayers in their church
CREATE POLICY "Users can view public prayers in their church"
    ON prayer_requests
    FOR SELECT
    USING (
        privacy = 'public'
        AND status = 'active'
        AND church_id IN (
            SELECT church_id
            FROM church_members
            WHERE user_id = auth.uid()
        )
    );

-- Policy: Users can view their own prayers (any privacy level)
CREATE POLICY "Users can view their own prayers"
    ON prayer_requests
    FOR SELECT
    USING (user_id = auth.uid());

-- Policy: Leadership can view all prayers in their church
CREATE POLICY "Leadership can view all prayers in their church"
    ON prayer_requests
    FOR SELECT
    USING (
        church_id IN (
            SELECT cm.church_id
            FROM church_members cm
            WHERE cm.user_id = auth.uid()
            AND cm.role IN ('super_admin', 'admin', 'committee')
        )
    );

-- Policy: Users can create prayer requests
CREATE POLICY "Users can create prayer requests"
    ON prayer_requests
    FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND church_id IN (
            SELECT church_id
            FROM church_members
            WHERE user_id = auth.uid()
        )
    );

-- Policy: Users can update their own prayers
CREATE POLICY "Users can update their own prayers"
    ON prayer_requests
    FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Policy: Users can delete their own prayers
CREATE POLICY "Users can delete their own prayers"
    ON prayer_requests
    FOR DELETE
    USING (user_id = auth.uid());

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function: Increment prayer count
CREATE OR REPLACE FUNCTION increment_prayer_count(prayer_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE prayer_requests
    SET prayer_count = prayer_count + 1
    WHERE id = prayer_id;
END;
$$;

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_prayer_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Trigger: Auto-update updated_at
CREATE TRIGGER prayer_requests_updated_at
    BEFORE UPDATE ON prayer_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_prayer_updated_at();

-- ============================================
-- SAMPLE DATA (FOR TESTING)
-- ============================================

-- Insert sample prayer requests (replace with actual church_id and user_id)
/*
INSERT INTO prayer_requests (user_id, user_name, church_id, title, description, category, privacy, is_urgent)
VALUES
    ('user-uuid-here', 'John Doe', 'church-uuid-here', 'Prayer for Healing', 'Please pray for my mother who is recovering from surgery', 'health', 'public', true),
    ('user-uuid-here', 'Jane Smith', 'church-uuid-here', 'Financial Breakthrough', 'Believing God for provision', 'financial', 'public', false),
    ('user-uuid-here', 'Anonymous', 'church-uuid-here', 'Family Restoration', 'Praying for reconciliation', 'family', 'private', false);
*/

-- ============================================
-- USEFUL QUERIES FOR ADMINS
-- ============================================

-- Get all active prayers by church
-- SELECT * FROM prayer_requests WHERE church_id = 'your-church-id' AND status = 'active' ORDER BY is_urgent DESC, created_at DESC;

-- Get prayer statistics by category
-- SELECT category, COUNT(*) as count FROM prayer_requests WHERE church_id = 'your-church-id' AND status = 'active' GROUP BY category;

-- Get answered prayers
-- SELECT * FROM prayer_requests WHERE church_id = 'your-church-id' AND status = 'answered' ORDER BY answered_at DESC;

-- Get urgent prayers
-- SELECT * FROM prayer_requests WHERE church_id = 'your-church-id' AND status = 'active' AND is_urgent = true ORDER BY created_at DESC;

-- ============================================
-- NOTES
-- ============================================
-- 1. Make sure to run this after creating the churches and profiles tables
-- 2. Update sample data with actual UUIDs from your database
-- 3. Test RLS policies thoroughly before production
-- 4. Consider adding notification triggers for new urgent prayers
-- 5. Regularly archive old prayers (status = 'archived') to keep the wall fresh
