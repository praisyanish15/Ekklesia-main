# 🎯 What To Do Next
## Your Complete Ekklesia Deployment Guide

This is your step-by-step action plan to get Ekklesia live.

---

## 📊 WHAT YOU HAVE RIGHT NOW

### ✅ 100% Complete Features

1. **Prayer Wall** - Complete ShepherdCare prayer ecosystem
   - Public/Private/Leadership privacy levels
   - "I Prayed" tracking
   - Answered prayers → testimonies
   - Category filtering
   - Full CRUD operations

2. **Testimony Vault** - Multi-format testimonies
   - Text/Audio/Video submissions
   - Admin approval workflow
   - Featured testimonies
   - Like & share functionality

3. **Onboarding Flow** - Smooth church & member setup
   - Welcome screen
   - 2-minute pastor setup
   - Church focus selection (auto-configuration)
   - Member join with referral codes
   - Approval workflows

4. **Church Management** - Complete backend
   - Church creation with license validation
   - Referral code system
   - Role-based access (Super Admin → Member → Pending)
   - Member approval system

5. **Discipleship Paths** - Backend ready (UI pending)
   - Path models created
   - Service layer complete
   - Database schema with sample content
   - Progress tracking ready

---

## 🚀 ACTION PLAN (3 STEPS)

### STEP 1: Deploy Supabase Backend (1 hour)

**Open**: `SUPABASE_DEPLOYMENT_GUIDE.md`

**Do This**:
1. Go to https://supabase.com
2. Create new project (free tier works)
3. Go to **SQL Editor**
4. Run these SQL files in order:

```sql
-- 1. Core Schema (churches, profiles, members)
-- Copy the core schema from SUPABASE_DEPLOYMENT_GUIDE.md Step 1.1

-- 2. Prayer Wall Schema
-- Copy from database/prayer_wall_schema.sql

-- 3. Discipleship Paths Schema
-- Copy from database/discipleship_paths_schema.sql

-- 4. Helper Functions
-- Copy from SUPABASE_DEPLOYMENT_GUIDE.md Step 3
```

5. Go to **Storage** → Create bucket `testimony-media` (Public)
6. Go to **Settings** → **API** → Copy:
   - Project URL
   - Anon/Public Key

**Time**: 30-40 minutes

---

### STEP 2: Connect Flutter App (15 minutes)

**Update** `lib/services/supabase_service.dart`:

```dart
class SupabaseService {
  static final SupabaseClient client = SupabaseClient(
    'PASTE_YOUR_SUPABASE_URL_HERE',
    'PASTE_YOUR_ANON_KEY_HERE',
  );
}
```

**Update** `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(const MyApp());
}
```

**Run**:
```bash
flutter pub get
flutter run
```

**Time**: 10-15 minutes

---

### STEP 3: Test Everything (30 minutes)

**Follow**: `DEPLOYMENT_CHECKLIST.md` → Step 3

**Test**:
1. Sign up as user ✅
2. Create church (pastor flow) ✅
3. Join church (member flow) ✅
4. Submit prayer request ✅
5. Click "I Prayed" ✅
6. Mark prayer as answered ✅
7. Submit testimony ✅
8. Admin approve testimony ✅

**If all works**: You're ready to deploy! 🎉

**Time**: 20-30 minutes

---

## 💳 OPTIONAL: Add Donations (Razorpay)

**Only if you want donation features**

**Follow**: `RAZORPAY_INTEGRATION_GUIDE.md`

**Quick Steps**:
1. Create Razorpay account: https://razorpay.com
2. Get test API keys
3. Add `razorpay_flutter: ^1.3.5` to pubspec.yaml
4. Run donations schema (in Razorpay guide)
5. Test with card: `4111 1111 1111 1111`

**Time**: 30 minutes

---

## 📱 BUILD FOR PRODUCTION

### Android

```bash
# APK for direct install
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

**Files**:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Then open in Xcode, sign, and upload to App Store Connect.

---

## 🗄️ SUPABASE TODO LIST

### Database Tables to Create

Run these SQL scripts **in order**:

#### 1. Core Tables
```sql
-- Churches table
CREATE TABLE churches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    pastor_name TEXT NOT NULL,
    license_number TEXT UNIQUE NOT NULL,
    referral_code TEXT UNIQUE NOT NULL,
    area TEXT NOT NULL,
    primary_focus TEXT,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Church members table
CREATE TABLE church_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    church_id UUID REFERENCES churches(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'pending',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(church_id, user_id)
);

-- Profiles table
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    phone_number TEXT,
    photo_url TEXT,
    current_church_id UUID REFERENCES churches(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2. Prayer Requests Table
```sql
CREATE TABLE prayer_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    user_name TEXT NOT NULL,
    church_id UUID REFERENCES churches(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    privacy TEXT DEFAULT 'public',
    status TEXT DEFAULT 'active',
    is_urgent BOOLEAN DEFAULT false,
    prayer_count INTEGER DEFAULT 0,
    answered_testimony TEXT,
    answered_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 3. Testimonies Table
```sql
CREATE TABLE testimonies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    user_name TEXT NOT NULL,
    church_id UUID REFERENCES churches(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL,
    type TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    is_featured BOOLEAN DEFAULT false,
    like_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    audio_url TEXT,
    video_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE testimony_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    testimony_id UUID REFERENCES testimonies(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(testimony_id, user_id)
);
```

#### 4. Discipleship Tables
```sql
CREATE TABLE discipleship_paths (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    type TEXT NOT NULL,
    duration_weeks INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE weekly_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    path_id UUID REFERENCES discipleship_paths(id) ON DELETE CASCADE,
    week_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    verse TEXT NOT NULL,
    verse_reference TEXT NOT NULL,
    devotion TEXT NOT NULL,
    reflection_question TEXT NOT NULL,
    action_step TEXT NOT NULL,
    UNIQUE(path_id, week_number)
);

CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    path_id UUID REFERENCES discipleship_paths(id) ON DELETE CASCADE,
    current_week INTEGER DEFAULT 1,
    is_completed BOOLEAN DEFAULT false,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, path_id)
);
```

#### 5. Enable RLS on All Tables
```sql
ALTER TABLE churches ENABLE ROW LEVEL SECURITY;
ALTER TABLE church_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE prayer_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonies ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimony_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE discipleship_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
```

#### 6. Create Helper Functions
```sql
CREATE OR REPLACE FUNCTION increment_prayer_count(prayer_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    UPDATE prayer_requests SET prayer_count = prayer_count + 1 WHERE id = prayer_id;
END;
$$;

CREATE OR REPLACE FUNCTION increment_testimony_views(testimony_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    UPDATE testimonies SET view_count = view_count + 1 WHERE id = testimony_id;
END;
$$;

CREATE OR REPLACE FUNCTION increment_testimony_likes(testimony_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    UPDATE testimonies SET like_count = like_count + 1 WHERE id = testimony_id;
END;
$$;

CREATE OR REPLACE FUNCTION decrement_testimony_likes(testimony_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    UPDATE testimonies SET like_count = GREATEST(like_count - 1, 0) WHERE id = testimony_id;
END;
$$;
```

### Storage Buckets to Create

1. **testimony-media**
   - Public: Yes
   - Allowed MIME types: `audio/*`, `video/*`, `image/*`
   - Max size: 100MB

---

## 💳 RAZORPAY TODO (Optional)

**If you want donations/payments**:

1. **Create Account**: https://razorpay.com
2. **Get Keys**: Settings → API Keys
3. **Add to pubspec.yaml**:
   ```yaml
   razorpay_flutter: ^1.3.5
   ```
4. **Create donations table** (SQL in Razorpay guide)
5. **Test** with card: `4111 1111 1111 1111`

---

## 📚 DOCUMENTATION TO READ

**Essential** (Read these):
1. `SUPABASE_DEPLOYMENT_GUIDE.md` - Backend setup
2. `DEPLOYMENT_CHECKLIST.md` - Full deployment steps
3. `PRAYER_WALL_GUIDE.md` - Prayer feature explained
4. `TESTIMONY_VAULT_GUIDE.md` - Testimony feature explained
5. `ONBOARDING_FLOW_GUIDE.md` - Onboarding UX

**Optional** (If needed):
6. `RAZORPAY_INTEGRATION_GUIDE.md` - Payment setup
7. `SHEPHERDCARE_IMPLEMENTATION_STATUS.md` - Feature status

---

## ⏱️ TIME ESTIMATE

**Minimum viable deployment**:
- Supabase setup: 1 hour
- App configuration: 15 minutes
- Testing: 30 minutes
- Build APK: 10 minutes

**Total**: ~2 hours to go live!

**With Razorpay**: Add 30 minutes

---

## 🎯 LAUNCH STRATEGY

### Option 1: Soft Launch (Recommended)

**Week 1-2**: Beta with 3 churches
- Collect feedback
- Fix bugs
- Refine UX

**Week 3+**: Public launch

### Option 2: Direct Launch

- Deploy to production
- Submit to Play Store / App Store
- Market to churches immediately

---

## 🚨 TROUBLESHOOTING

### "Supabase connection failed"
→ Double-check URL and Anon Key in `supabase_service.dart`

### "RLS policy blocks access"
→ Check that user is a member of the church

### "Build errors"
→ Run: `flutter clean && flutter pub get`

### "Storage upload fails"
→ Verify `testimony-media` bucket exists and is public

---

## ✅ FINAL CHECKLIST

Before going live:

### Backend
- [ ] Supabase project created
- [ ] All tables created
- [ ] RLS enabled on all tables
- [ ] Helper functions created
- [ ] Storage bucket created
- [ ] API keys copied

### App
- [ ] API keys added to code
- [ ] Supabase initialized in main.dart
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App builds without errors
- [ ] All features tested

### Security
- [ ] RLS policies tested
- [ ] Email confirmation enabled (optional)
- [ ] API keys not in Git
- [ ] Service role key secured

### Ready
- [ ] APK/Bundle built
- [ ] Privacy policy ready
- [ ] Support email set up
- [ ] First church ready to onboard

---

## 🎉 YOU'RE READY!

Your app is **production-ready** with:
- ✅ Prayer Wall (complete)
- ✅ Testimony Vault (complete)
- ✅ Onboarding (complete)
- ✅ Church management (complete)
- ✅ Secure backend (Supabase + RLS)

**Launch and let churches experience "Church beyond Sunday!"** 🙏

---

## 📞 QUICK REFERENCE

**Supabase Dashboard**: https://app.supabase.com
**Razorpay Dashboard**: https://dashboard.razorpay.com
**Flutter Docs**: https://flutter.dev/docs

**Questions?** Check the comprehensive guides in your project folder!

---

_"Commit to the LORD whatever you do, and he will establish your plans."_ - Proverbs 16:3
