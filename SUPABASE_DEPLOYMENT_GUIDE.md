# 🚀 Supabase Deployment Guide
## Ekklesia - Complete Setup Instructions

This guide will walk you through setting up your complete Supabase backend for the Ekklesia app.

---

## 📋 Prerequisites

- Supabase account (free tier works): https://supabase.com
- Project created in Supabase dashboard
- API keys ready (you'll find them in Settings > API)

---

## 🗄️ DATABASE SETUP

### Step 1: Run Database Schemas (in order)

Go to your Supabase project → **SQL Editor** → Create a new query, then run these files **in order**:

#### 1.1 Core Schema (Churches & Users)
```sql
-- Run this first
-- File: database/core_schema.sql
```

Create and run this schema:

```sql
-- ============================================
-- CORE SCHEMA - CHURCHES & USERS
-- ============================================

-- Create churches table
CREATE TABLE IF NOT EXISTS churches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    pastor_name TEXT NOT NULL,
    license_number TEXT NOT NULL UNIQUE,
    referral_code TEXT NOT NULL UNIQUE,
    area TEXT NOT NULL,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    phone_number TEXT,
    email TEXT,
    description TEXT,
    photo_url TEXT,
    primary_focus TEXT CHECK (primary_focus IN ('prayer', 'newBelievers', 'memberCare', 'youth')),
    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create church_members table
CREATE TABLE IF NOT EXISTS church_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    church_id UUID NOT NULL REFERENCES churches(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'pending' CHECK (role IN ('pending', 'member', 'committee', 'admin', 'super_admin')),
    approved_by UUID REFERENCES auth.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(church_id, user_id)
);

-- Create profiles table (extended user info)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    phone_number TEXT,
    photo_url TEXT,
    current_church_id UUID REFERENCES churches(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_churches_referral_code ON churches(referral_code);
CREATE INDEX idx_church_members_church_id ON church_members(church_id);
CREATE INDEX idx_church_members_user_id ON church_members(user_id);
CREATE INDEX idx_church_members_role ON church_members(role);

-- RLS Policies
ALTER TABLE churches ENABLE ROW LEVEL SECURITY;
ALTER TABLE church_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Churches: Anyone can view
CREATE POLICY "Anyone can view churches"
    ON churches FOR SELECT USING (true);

-- Churches: Only creator can insert
CREATE POLICY "Users can create churches"
    ON churches FOR INSERT
    WITH CHECK (created_by = auth.uid());

-- Church Members: Can view if member
CREATE POLICY "Members can view their churches"
    ON church_members FOR SELECT
    USING (user_id = auth.uid() OR church_id IN (
        SELECT church_id FROM church_members WHERE user_id = auth.uid()
    ));

-- Profiles: Users can view their own
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (id = auth.uid());

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (id = auth.uid());
```

#### 1.2 Prayer Wall Schema
Copy and run: `database/prayer_wall_schema.sql`

#### 1.3 Testimony Vault Schema
```sql
-- Run the testimony vault schema (if not already created)
-- Check if testimonies table exists first
```

#### 1.4 Discipleship Paths Schema
Copy and run: `database/discipleship_paths_schema.sql`

---

### Step 2: Create Storage Buckets

Go to **Storage** in your Supabase dashboard:

#### 2.1 Create `testimony-media` bucket
```
Name: testimony-media
Public: Yes (for public testimonies)
Allowed MIME types: audio/*, video/*, image/*
File size limit: 100MB
```

#### 2.2 Storage Policies for `testimony-media`
```sql
-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload testimony media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'testimony-media');

-- Anyone can view public media
CREATE POLICY "Anyone can view testimony media"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'testimony-media');

-- Users can delete their own uploads
CREATE POLICY "Users can delete own testimony media"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'testimony-media' AND owner = auth.uid());
```

---

### Step 3: Create Database Functions

Run these helper functions in SQL Editor:

```sql
-- Function: Increment testimony views
CREATE OR REPLACE FUNCTION increment_testimony_views(testimony_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE testimonies
    SET view_count = view_count + 1
    WHERE id = testimony_id;
END;
$$;

-- Function: Increment testimony likes
CREATE OR REPLACE FUNCTION increment_testimony_likes(testimony_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE testimonies
    SET like_count = like_count + 1
    WHERE id = testimony_id;
END;
$$;

-- Function: Decrement testimony likes
CREATE OR REPLACE FUNCTION decrement_testimony_likes(testimony_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE testimonies
    SET like_count = GREATEST(like_count - 1, 0)
    WHERE id = testimony_id;
END;
$$;

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
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Triggers for auto-updating updated_at
CREATE TRIGGER churches_updated_at
    BEFORE UPDATE ON churches
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
```

---

## 🔐 AUTHENTICATION SETUP

### Step 1: Email Configuration

Go to **Authentication** → **Providers** → **Email**

- Enable Email provider
- **Disable** "Confirm email" (for faster onboarding) OR
- **Enable** "Confirm email" for production security
- Set email templates (use default for now)

### Step 2: Social Auth (Optional)

Enable providers you want:
- Google OAuth (recommended for easy sign-in)
- Facebook
- Apple

Follow Supabase docs for each provider's setup.

### Step 3: Email Templates

Go to **Authentication** → **Email Templates**

Customize these templates with your branding:
- **Confirm signup**: Welcome email
- **Invite user**: Church admin invitations
- **Magic link**: Passwordless sign-in
- **Reset password**: Password recovery

---

## 🔑 API KEYS SETUP

### Step 1: Get Your Keys

Go to **Settings** → **API**

You'll need:
1. **Project URL**: `https://your-project.supabase.co`
2. **Anon/Public Key**: `eyJhbG...` (public, safe for client)
3. **Service Role Key**: `eyJhbG...` (private, server-only)

### Step 2: Add to Flutter App

Create `.env` file in your project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

Update `lib/services/supabase_service.dart`:

```dart
class SupabaseService {
  static final SupabaseClient client = SupabaseClient(
    'YOUR_SUPABASE_URL',
    'YOUR_SUPABASE_ANON_KEY',
  );
}
```

**🚨 IMPORTANT**: Never commit your Service Role Key to Git!

---

## 📊 VERIFY SETUP

### Run These Queries to Verify

```sql
-- Check all tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Expected tables:
-- churches, church_members, profiles
-- prayer_requests, testimony_likes
-- testimonies, discipleship_paths
-- weekly_steps, user_progress

-- Check storage buckets
SELECT * FROM storage.buckets;

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
-- All should show 't' (true) for rowsecurity

-- Check functions exist
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public';
```

---

## 🧪 TEST YOUR SETUP

### Test 1: User Registration
1. Open your app
2. Sign up with email
3. Check Supabase **Authentication** → **Users**
4. User should appear

### Test 2: Church Creation
1. Complete pastor setup flow
2. Check `churches` table in **Table Editor**
3. Verify referral code generated
4. Check `church_members` table - creator should be super_admin

### Test 3: Prayer Submission
1. Submit a test prayer
2. Check `prayer_requests` table
3. Verify privacy level correct
4. Test "I Prayed" button
5. Check prayer_count increments

### Test 4: Testimony Upload (if using media)
1. Submit a text testimony
2. Check `testimonies` table
3. Status should be 'pending'
4. Admin approves
5. Status changes to 'approved'

---

## 🔒 SECURITY CHECKLIST

Before going to production:

- [ ] All tables have RLS enabled
- [ ] Test RLS policies (users can't see other churches' data)
- [ ] Storage policies correct
- [ ] Service Role Key is NOT in client code
- [ ] Email confirmation enabled (for production)
- [ ] Rate limiting configured (Supabase dashboard)
- [ ] Backup strategy in place

---

## 📈 MONITORING & ANALYTICS

### Enable Monitoring

Go to **Settings** → **Database**
- Enable **Database Webhooks** for real-time events
- Set up **Connection Pooling** for better performance

### View Logs

Go to **Logs** → **Database**
- Monitor query performance
- Check for errors
- Optimize slow queries

---

## 🚨 TROUBLESHOOTING

### Common Issues

**1. "User not authorized" errors**
- Check RLS policies
- Verify user is member of church
- Test with auth.uid() in SQL

**2. "Foreign key violation"**
- Ensure churches exist before adding members
- Check user IDs are valid

**3. Media upload fails**
- Check storage bucket exists
- Verify MIME types allowed
- Check file size limits

**4. Functions not working**
- Ensure functions created with SECURITY DEFINER
- Check function permissions
- Test functions directly in SQL Editor

---

## 🔄 MIGRATION & UPDATES

### Adding New Features

When adding new tables/columns:

1. Create migration SQL file
2. Test in development project first
3. Run in production during low-traffic time
4. Verify with SELECT queries
5. Update RLS policies if needed

### Backup Strategy

**Automatic Backups** (Pro plan):
- Daily automated backups
- Point-in-time recovery

**Manual Backups** (Free tier):
1. Go to **Database** → **Backups**
2. Download SQL dump
3. Store securely
4. Test restore procedure

---

## 📞 SUPPORT RESOURCES

- Supabase Docs: https://supabase.com/docs
- Discord Community: https://discord.supabase.com
- GitHub Issues: https://github.com/supabase/supabase/issues

---

## ✅ FINAL CHECKLIST

Before launching:

### Database
- [x] All schemas created
- [x] RLS policies enabled
- [x] Helper functions created
- [x] Triggers active
- [x] Indexes created

### Storage
- [x] Buckets created
- [x] Policies configured
- [x] File size limits set

### Authentication
- [x] Email provider enabled
- [x] Templates customized
- [x] Social auth configured (if needed)

### Security
- [x] RLS tested thoroughly
- [x] API keys secured
- [x] Service role key protected
- [x] Rate limiting enabled

### Monitoring
- [x] Logs accessible
- [x] Backups configured
- [x] Error tracking setup

---

## 🎉 YOU'RE READY!

Your Supabase backend is now fully configured for Ekklesia!

**Next Steps**:
1. Test all features thoroughly
2. Invite beta testers
3. Monitor performance
4. Gather feedback
5. Iterate and improve

_"For we are God's handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do."_ - Ephesians 2:10
