-- =====================================================
-- Ekklesia Church Management App - Database Setup
-- =====================================================
-- Run this script in your Supabase SQL Editor
-- =====================================================

-- Users/Profiles table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  age INTEGER,
  gender TEXT,
  phone_number TEXT,
  address TEXT,
  photo_url TEXT,
  role TEXT DEFAULT 'member' CHECK (role IN ('member', 'admin', 'commander')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Churches table
CREATE TABLE public.churches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  pastor_name TEXT,
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
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Church members table (many-to-many relationship with roles)
CREATE TABLE public.church_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id UUID REFERENCES churches(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'pending' CHECK (role IN ('super_admin', 'admin', 'committee', 'member', 'pending')),
  approved_by UUID REFERENCES profiles(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(church_id, user_id)
);

-- Prayer requests table
CREATE TABLE public.prayer_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  church_id UUID REFERENCES churches(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'answered', 'closed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Events table
CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id UUID REFERENCES churches(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  event_date TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaigns table (for donations)
CREATE TABLE public.campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  target_amount DECIMAL(10, 2) NOT NULL,
  current_amount DECIMAL(10, 2) DEFAULT 0,
  image_url TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  created_by UUID REFERENCES profiles(id),
  start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Donations table
CREATE TABLE public.donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  amount DECIMAL(10, 2) NOT NULL,
  payment_id TEXT NOT NULL,
  payment_status TEXT DEFAULT 'success',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications table
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('general', 'prayerRequest', 'event', 'campaign', 'announcement')),
  related_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bible bookmarks table
CREATE TABLE public.bible_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  book TEXT NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Testimonies table (Faith Stories Archive)
CREATE TABLE public.testimonies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_photo_url TEXT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('healing', 'financialBreakthrough', 'salvation', 'deliverance', 'provision', 'protection', 'answeredPrayer', 'other')),
  type TEXT NOT NULL CHECK (type IN ('text', 'audio', 'video')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  audio_url TEXT,
  video_url TEXT,
  thumbnail_url TEXT,
  church_id UUID REFERENCES churches(id) ON DELETE SET NULL,
  approved_by UUID REFERENCES profiles(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  rejection_reason TEXT,
  is_featured BOOLEAN DEFAULT FALSE,
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Testimony likes table
CREATE TABLE public.testimony_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  testimony_id UUID REFERENCES testimonies(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(testimony_id, user_id)
);

-- =====================================================
-- Enable Row Level Security (RLS)
-- =====================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE churches ENABLE ROW LEVEL SECURITY;
ALTER TABLE church_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE prayer_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE bible_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonies ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimony_likes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS Policies
-- =====================================================

-- Profiles policies
CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Churches policies
CREATE POLICY "Anyone can view churches"
  ON churches FOR SELECT
  USING (true);

CREATE POLICY "Admins can insert churches"
  ON churches FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'commander')
    )
  );

-- Church members policies
CREATE POLICY "Anyone can view church members"
  ON church_members FOR SELECT
  USING (true);

CREATE POLICY "Users can join churches"
  ON church_members FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Prayer requests policies
CREATE POLICY "Anyone can view prayer requests"
  ON prayer_requests FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create prayer requests"
  ON prayer_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own prayer requests"
  ON prayer_requests FOR UPDATE
  USING (auth.uid() = user_id);

-- Events policies
CREATE POLICY "Anyone can view events"
  ON events FOR SELECT
  USING (true);

CREATE POLICY "Admins can create events"
  ON events FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'commander')
    )
  );

-- Campaigns policies
CREATE POLICY "Anyone can view campaigns"
  ON campaigns FOR SELECT
  USING (true);

CREATE POLICY "Admins can create campaigns"
  ON campaigns FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'commander')
    )
  );

-- Donations policies
CREATE POLICY "Users can view own donations"
  ON donations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create donations"
  ON donations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all donations"
  ON donations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'commander')
    )
  );

-- Notifications policies
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Bible bookmarks policies
CREATE POLICY "Users can manage own bookmarks"
  ON bible_bookmarks FOR ALL
  USING (auth.uid() = user_id);

-- Testimonies policies
CREATE POLICY "Anyone can view approved testimonies"
  ON testimonies FOR SELECT
  USING (status = 'approved');

CREATE POLICY "Users can view own testimonies"
  ON testimonies FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create testimonies"
  ON testimonies FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pending testimonies"
  ON testimonies FOR UPDATE
  USING (auth.uid() = user_id AND status = 'pending');

CREATE POLICY "Admins can update testimonies"
  ON testimonies FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'commander')
    )
  );

-- Testimony likes policies
CREATE POLICY "Users can manage own likes"
  ON testimony_likes FOR ALL
  USING (auth.uid() = user_id);

-- =====================================================
-- Functions and Triggers
-- =====================================================

-- Function to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles updated_at
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for prayer_requests updated_at
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON prayer_requests
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for testimonies updated_at
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON testimonies
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to increment testimony views
CREATE OR REPLACE FUNCTION public.increment_testimony_views(testimony_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE testimonies
  SET view_count = view_count + 1
  WHERE id = testimony_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment testimony likes
CREATE OR REPLACE FUNCTION public.increment_testimony_likes(testimony_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE testimonies
  SET like_count = like_count + 1
  WHERE id = testimony_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrement testimony likes
CREATE OR REPLACE FUNCTION public.decrement_testimony_likes(testimony_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE testimonies
  SET like_count = GREATEST(like_count - 1, 0)
  WHERE id = testimony_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Sample Data (Optional - for testing)
-- =====================================================

-- Uncomment to add sample churches
/*
INSERT INTO churches (name, area, city, description) VALUES
  ('Grace Community Church', 'Downtown', 'Mumbai', 'A vibrant community serving Christ'),
  ('Hope Fellowship', 'Suburb Area', 'Delhi', 'Where hope meets faith'),
  ('Faith Assembly', 'West End', 'Bangalore', 'Building faith together');
*/

-- Uncomment to add a sample campaign
/*
INSERT INTO campaigns (title, description, target_amount, end_date, created_by) VALUES
  (
    'Help Build New Community Center',
    'We are raising funds to build a new community center that will serve our neighborhood.',
    500000,
    '2026-12-31',
    auth.uid()
  );
*/

-- =====================================================
-- Verification Queries
-- =====================================================
-- Run these to verify your setup:

-- Check all tables were created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- =====================================================
-- Setup Complete! 🎉
-- =====================================================
-- Your Ekklesia Church Management App database is now set up and ready to use.
-- Remember to test all functionalities and adjust policies as needed for your specific use cases.
-- =====================================================
-- SERMONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.sermons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id UUID NOT NULL REFERENCES public.churches(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  pastor_name TEXT NOT NULL,
  description TEXT,
  key_points TEXT[] DEFAULT '{}',
  verses TEXT[] DEFAULT '{}',
  date TIMESTAMP NOT NULL,
  audio_url TEXT,
  video_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- RLS policies for sermons
ALTER TABLE public.sermons ENABLE ROW LEVEL SECURITY;

-- Anyone can view sermons from their church
CREATE POLICY "Users can view sermons from their church"
  ON public.sermons FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = sermons.church_id
      AND role IN ('super_admin', 'admin', 'committee', 'member')
    )
  );

-- Only admins and super_admins can insert sermons
CREATE POLICY "Admins can insert sermons"
  ON public.sermons FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = sermons.church_id
      AND role IN ('super_admin', 'admin')
    )
  );

-- Only admins and super_admins can update sermons
CREATE POLICY "Admins can update sermons"
  ON public.sermons FOR UPDATE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = sermons.church_id
      AND role IN ('super_admin', 'admin')
    )
  );

-- Only admins and super_admins can delete sermons
CREATE POLICY "Admins can delete sermons"
  ON public.sermons FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = sermons.church_id
      AND role IN ('super_admin', 'admin')
    )
  );

-- =====================================================
-- SONGS TABLE (Worship Songs/Hymns with Lyrics)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.songs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id UUID NOT NULL REFERENCES public.churches(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  artist TEXT,
  lyrics TEXT NOT NULL,
  category TEXT, -- worship, praise, hymn, etc.
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- RLS policies for songs
ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;

-- Anyone can view songs from their church
CREATE POLICY "Users can view songs from their church"
  ON public.songs FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = songs.church_id
      AND role IN ('super_admin', 'admin', 'committee', 'member')
    )
  );

-- Only admins and super_admins can insert songs
CREATE POLICY "Admins can insert songs"
  ON public.songs FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = songs.church_id
      AND role IN ('super_admin', 'admin')
    )
  );

-- Only admins and super_admins can update songs
CREATE POLICY "Admins can update songs"
  ON public.songs FOR UPDATE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = songs.church_id
      AND role IN ('super_admin', 'admin')
    )
  );

-- Only admins and super_admins can delete songs
CREATE POLICY "Admins can delete songs"
  ON public.songs FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = songs.church_id
      AND role IN ('super_admin', 'admin')
    )
  );

-- =====================================================
-- COMMITTEE MEMBERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.committee_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id UUID NOT NULL REFERENCES public.churches(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  position TEXT NOT NULL CHECK (position IN ('president', 'secretary', 'treasurer', 'member')),
  appointed_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(church_id, user_id)
);

-- RLS policies for committee members
ALTER TABLE public.committee_members ENABLE ROW LEVEL SECURITY;

-- Anyone can view committee members from their church
CREATE POLICY "Users can view committee members from their church"
  ON public.committee_members FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = committee_members.church_id
      AND role IN ('super_admin', 'admin', 'committee', 'member')
    )
  );

-- Only super_admins can insert committee members
CREATE POLICY "Super admins can insert committee members"
  ON public.committee_members FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = committee_members.church_id
      AND role = 'super_admin'
    )
  );

-- Only super_admins can update committee members
CREATE POLICY "Super admins can update committee members"
  ON public.committee_members FOR UPDATE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = committee_members.church_id
      AND role = 'super_admin'
    )
  );

-- Only super_admins can delete committee members
CREATE POLICY "Super admins can delete committee members"
  ON public.committee_members FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = committee_members.church_id
      AND role = 'super_admin'
    )
  );

-- Add latitude and longitude to churches table for Google Maps integration
ALTER TABLE public.churches ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE public.churches ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sermons_church_id ON public.sermons(church_id);
CREATE INDEX IF NOT EXISTS idx_sermons_date ON public.sermons(date DESC);
CREATE INDEX IF NOT EXISTS idx_songs_church_id ON public.songs(church_id);
CREATE INDEX IF NOT EXISTS idx_committee_members_church_id ON public.committee_members(church_id);
CREATE INDEX IF NOT EXISTS idx_committee_members_position ON public.committee_members(position);

-- =====================================================
-- CHURCH PAYMENT SETTINGS (QR Code & Bank Details)
-- =====================================================

-- Add payment fields to churches table
ALTER TABLE public.churches ADD COLUMN IF NOT EXISTS payment_qr_code_url TEXT;
ALTER TABLE public.churches ADD COLUMN IF NOT EXISTS upi_id TEXT;
ALTER TABLE public.churches ADD COLUMN IF NOT EXISTS razorpay_key_id TEXT;

-- Create church bank details table
CREATE TABLE IF NOT EXISTS public.church_bank_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id UUID NOT NULL REFERENCES public.churches(id) ON DELETE CASCADE,
  bank_name TEXT NOT NULL,
  account_holder_name TEXT NOT NULL,
  account_number TEXT NOT NULL,
  ifsc_code TEXT NOT NULL,
  branch_name TEXT,
  account_type TEXT CHECK (account_type IN ('savings', 'current')),
  is_primary BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(church_id, account_number)
);

-- RLS policies for church bank details
ALTER TABLE public.church_bank_details ENABLE ROW LEVEL SECURITY;

-- Members can view bank details of their church
CREATE POLICY "Members can view church bank details"
  ON public.church_bank_details FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = church_bank_details.church_id
      AND role IN ('super_admin', 'admin', 'committee', 'member')
    )
  );

-- Only super_admins can insert/update/delete bank details
CREATE POLICY "Super admins can insert bank details"
  ON public.church_bank_details FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = church_bank_details.church_id
      AND role = 'super_admin'
    )
  );

CREATE POLICY "Super admins can update bank details"
  ON public.church_bank_details FOR UPDATE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = church_bank_details.church_id
      AND role = 'super_admin'
    )
  );

CREATE POLICY "Super admins can delete bank details"
  ON public.church_bank_details FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.church_members
      WHERE church_id = church_bank_details.church_id
      AND role = 'super_admin'
    )
  );

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_church_bank_details_church_id ON public.church_bank_details(church_id);

