-- =====================================================
-- DANGER: This script will DELETE ALL DATA from your database
-- Use with extreme caution - THIS CANNOT BE UNDONE
-- =====================================================

-- IMPORTANT: Run this in Supabase SQL Editor
-- This will wipe all user data but keep the table structure

BEGIN;

-- Delete all data from tables (in correct order to respect foreign keys)

-- 1. Delete donations
DELETE FROM public.donations;

-- 2. Delete campaigns
DELETE FROM public.campaigns;

-- 3. Delete events
DELETE FROM public.events;

-- 4. Delete prayer requests
DELETE FROM public.prayer_requests;

-- 5. Delete songs
DELETE FROM public.songs;

-- 6. Delete sermons
DELETE FROM public.sermons;

-- 7. Delete committee members
DELETE FROM public.committee_members;

-- 8. Delete church members
DELETE FROM public.church_members;

-- 9. Delete churches
DELETE FROM public.churches;

-- 10. Delete profiles (but keep auth.users for now)
DELETE FROM public.profiles;

-- 11. OPTIONAL: Delete auth users (uncomment if you want to delete ALL users including authentication)
-- WARNING: This will require users to re-register
-- DELETE FROM auth.users;

COMMIT;

-- Verify tables are empty
SELECT 'profiles' as table_name, COUNT(*) as count FROM public.profiles
UNION ALL
SELECT 'churches', COUNT(*) FROM public.churches
UNION ALL
SELECT 'church_members', COUNT(*) FROM public.church_members
UNION ALL
SELECT 'committee_members', COUNT(*) FROM public.committee_members
UNION ALL
SELECT 'sermons', COUNT(*) FROM public.sermons
UNION ALL
SELECT 'songs', COUNT(*) FROM public.songs
UNION ALL
SELECT 'prayer_requests', COUNT(*) FROM public.prayer_requests
UNION ALL
SELECT 'events', COUNT(*) FROM public.events
UNION ALL
SELECT 'campaigns', COUNT(*) FROM public.campaigns
UNION ALL
SELECT 'donations', COUNT(*) FROM public.donations;
