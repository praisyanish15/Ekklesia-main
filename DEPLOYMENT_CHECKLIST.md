# ✅ Deployment Checklist
## Ekklesia - Complete Setup Guide

Use this checklist to deploy your Ekklesia app from development to production.

---

## 📦 WHAT YOU HAVE

### ✅ Completed Features (Ready to Deploy)

1. **Prayer Wall** - Full ShepherdCare prayer system
2. **Testimony Vault** - Multi-format testimonies
3. **Onboarding Flow** - Pastor setup & member join
4. **Church Management** - Approval workflows, roles
5. **Discipleship Paths** - Models and service (screens pending)

### 📂 File Structure

```
ekklesia/
├── lib/
│   ├── models/
│   │   ├── church_model.dart
│   │   ├── user_model.dart
│   │   ├── prayer_request_model.dart ✅
│   │   ├── testimony_model.dart ✅
│   │   └── discipleship_path_model.dart ✅
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── church_service.dart
│   │   ├── prayer_service.dart ✅
│   │   ├── testimony_service.dart ✅
│   │   └── discipleship_service.dart ✅
│   ├── screens/
│   │   ├── onboarding/ ✅
│   │   ├── prayer/ ✅
│   │   └── testimony/ ✅
│   └── providers/
│       └── auth_provider.dart
├── database/
│   ├── prayer_wall_schema.sql ✅
│   ├── discipleship_paths_schema.sql ✅
│   └── (testimony schema in code)
└── Documentation/
    ├── PRAYER_WALL_GUIDE.md ✅
    ├── TESTIMONY_VAULT_GUIDE.md ✅
    ├── ONBOARDING_FLOW_GUIDE.md ✅
    ├── SUPABASE_DEPLOYMENT_GUIDE.md ✅
    └── RAZORPAY_INTEGRATION_GUIDE.md ✅
```

---

## 🚀 STEP-BY-STEP DEPLOYMENT

### STEP 1: Supabase Setup (30 minutes)

Follow `SUPABASE_DEPLOYMENT_GUIDE.md` exactly:

- [ ] Create Supabase project
- [ ] Run core schema (churches, church_members, profiles)
- [ ] Run prayer_wall_schema.sql
- [ ] Run discipleship_paths_schema.sql
- [ ] Create testimony-media storage bucket
- [ ] Set up storage policies
- [ ] Create helper functions
- [ ] Enable RLS on all tables
- [ ] Test with sample data
- [ ] Get API keys (URL, Anon Key)

**Verify**:
```sql
-- Run this to check all tables exist
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';
```

Expected tables:
- churches
- church_members
- profiles
- prayer_requests
- testimonies
- testimony_likes
- discipleship_paths
- weekly_steps
- user_progress

---

### STEP 2: Flutter App Configuration (15 minutes)

#### 2.1 Add Supabase Keys

Update `lib/services/supabase_service.dart`:

```dart
class SupabaseService {
  static final SupabaseClient client = SupabaseClient(
    'YOUR_SUPABASE_PROJECT_URL',  // ← Replace
    'YOUR_SUPABASE_ANON_KEY',     // ← Replace
  );
}
```

#### 2.2 Update pubspec.yaml

Ensure all dependencies are present:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.10.0
  provider: ^6.0.5
  intl: ^0.18.0
  share_plus: ^7.0.0
  file_picker: ^5.3.0
  razorpay_flutter: ^1.3.5  # If using donations
```

Run:
```bash
flutter pub get
```

#### 2.3 Initialize Supabase

In `main.dart`:

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

---

### STEP 3: Test Core Features (20 minutes)

#### 3.1 Test Authentication
- [ ] Sign up new user
- [ ] Verify user appears in Supabase Auth
- [ ] Test login
- [ ] Test logout

#### 3.2 Test Church Creation (Pastor Flow)
- [ ] Complete pastor setup
- [ ] Church created in database
- [ ] Referral code generated
- [ ] Creator is super_admin in church_members
- [ ] Check church focus saved

#### 3.3 Test Member Join
- [ ] Get referral code from church
- [ ] Join as member
- [ ] Status shows 'pending'
- [ ] Admin approves
- [ ] Status changes to 'member'

#### 3.4 Test Prayer Wall
- [ ] Submit public prayer
- [ ] Submit private prayer
- [ ] Submit leadership prayer (as leader)
- [ ] Click "I Prayed" button
- [ ] Prayer count increments
- [ ] Mark prayer as answered
- [ ] Convert to testimony

#### 3.5 Test Testimony Vault
- [ ] Submit text testimony
- [ ] Status is 'pending'
- [ ] Admin approves
- [ ] Testimony appears in vault
- [ ] Like testimony
- [ ] Share testimony

---

### STEP 4: Optional - Razorpay Integration (30 minutes)

**Only if you want donations feature**

Follow `RAZORPAY_INTEGRATION_GUIDE.md`:

- [ ] Create Razorpay account
- [ ] Get test API keys
- [ ] Add razorpay_flutter dependency
- [ ] Create donations table in Supabase
- [ ] Test payment with test card
- [ ] Verify donation recorded
- [ ] Switch to live keys for production

---

### STEP 5: Build & Deploy (30 minutes)

#### 5.1 Android Build

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Files generated:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

#### 5.2 iOS Build

```bash
# Build for iOS
flutter build ios --release
```

Then open in Xcode for final signing and upload to App Store.

---

### STEP 6: App Store Preparation

#### Google Play Store

Required:
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500)
- [ ] Screenshots (at least 2)
- [ ] App description
- [ ] Privacy policy URL
- [ ] Content rating

#### Apple App Store

Required:
- [ ] App icon (1024x1024 PNG)
- [ ] Screenshots (all device sizes)
- [ ] App description
- [ ] Privacy policy URL
- [ ] Age rating

---

## 🔐 SECURITY CHECKLIST

Before going live:

- [ ] All Supabase tables have RLS enabled
- [ ] Storage buckets have proper policies
- [ ] API keys are NOT in Git (use .env or secrets)
- [ ] Test RLS policies thoroughly
- [ ] Enable email confirmation (Supabase Auth)
- [ ] Rate limiting enabled (Supabase dashboard)
- [ ] HTTPS only for all API calls
- [ ] Razorpay keys secured (if using)

---

## 📊 MONITORING SETUP

### Supabase Monitoring

- [ ] Enable database webhooks for critical events
- [ ] Set up log retention
- [ ] Configure alerts for errors
- [ ] Monitor API usage

### App Analytics (Optional)

Consider adding:
- Firebase Analytics
- Mixpanel
- Custom event tracking

---

## 🎯 LAUNCH STRATEGY

### Soft Launch (Recommended)

**Week 1-2**: Beta Testing
- [ ] Invite 3-5 pilot churches
- [ ] Give them full access
- [ ] Collect feedback daily
- [ ] Fix critical bugs
- [ ] Document common issues

**Week 3-4**: Refinement
- [ ] Implement feedback
- [ ] Optimize performance
- [ ] Add requested features
- [ ] Create video tutorials

**Week 5+**: Public Launch
- [ ] Submit to app stores
- [ ] Launch marketing campaign
- [ ] Onboard churches systematically
- [ ] Provide support

---

## 🐛 TROUBLESHOOTING

### Common Issues & Fixes

**1. Supabase Connection Failed**
```
Error: Invalid API credentials
Fix: Double-check URL and Anon Key in supabase_service.dart
```

**2. RLS Policy Blocks Access**
```
Error: User not authorized
Fix: Check RLS policies, ensure user is church member
```

**3. Storage Upload Fails**
```
Error: File upload failed
Fix: Verify bucket exists, check MIME types allowed
```

**4. Build Errors**
```
Error: Gradle build failed
Fix: Clean build folder
Run: flutter clean && flutter pub get && flutter build apk
```

---

## 📞 SUPPORT RESOURCES

### Documentation
- Prayer Wall Guide: `PRAYER_WALL_GUIDE.md`
- Testimony Vault: `TESTIMONY_VAULT_GUIDE.md`
- Onboarding: `ONBOARDING_FLOW_GUIDE.md`
- Supabase: `SUPABASE_DEPLOYMENT_GUIDE.md`
- Razorpay: `RAZORPAY_INTEGRATION_GUIDE.md`

### External Resources
- Supabase Docs: https://supabase.com/docs
- Flutter Docs: https://flutter.dev/docs
- Razorpay Docs: https://razorpay.com/docs

---

## ✅ FINAL VERIFICATION

Before announcing to churches:

### Technical
- [ ] All features working in production
- [ ] No console errors
- [ ] App doesn't crash
- [ ] Performance is acceptable
- [ ] Backups configured

### User Experience
- [ ] Onboarding is smooth
- [ ] Navigation is intuitive
- [ ] Error messages are friendly
- [ ] Loading states are clear
- [ ] Success feedback is encouraging

### Business
- [ ] Privacy policy published
- [ ] Terms of service ready
- [ ] Support email active
- [ ] Pricing decided (if applicable)
- [ ] Marketing materials ready

---

## 🎉 YOU'RE READY TO LAUNCH!

Your Ekklesia app is production-ready with:
- ✅ Prayer Wall (ShepherdCare core)
- ✅ Testimony Vault (faith building)
- ✅ Church onboarding (2-minute setup)
- ✅ Member management (approval workflows)
- ✅ Secure backend (Supabase + RLS)
- ✅ Payment ready (Razorpay optional)

**Next**: Invite your first church and watch "Church beyond Sunday" become reality!

---

_"Now to him who is able to do immeasurably more than all we ask or imagine, according to his power that is at work within us, to him be glory in the church and in Christ Jesus throughout all generations, for ever and ever! Amen."_ - Ephesians 3:20-21
