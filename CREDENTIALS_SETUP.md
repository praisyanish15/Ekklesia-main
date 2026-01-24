# 🔐 Credentials Setup Guide

This guide will walk you through setting up Supabase and Razorpay credentials for your Ekklesia app.

---

## 📊 Part 1: Supabase Setup (Backend & Database)

### Step 1: Create Supabase Account
1. Visit [https://supabase.com](https://supabase.com)
2. Click **"Start your project"**
3. Sign up with GitHub, Google, or email

### Step 2: Create New Project
1. Click **"New Project"** in your dashboard
2. Fill in project details:
   - **Name**: `Ekklesia` (or your preferred name)
   - **Database Password**: Create a strong password (SAVE THIS!)
   - **Region**: Choose closest to your users (e.g., "Southeast Asia")
   - **Pricing Plan**: Free (perfect for development)
3. Click **"Create new project"**
4. ⏱️ Wait 2-3 minutes for provisioning

### Step 3: Get API Credentials
1. In your project, click **⚙️ Settings** (left sidebar)
2. Click **API** under Settings
3. Copy these values:
   ```
   📍 Project URL: https://xxxxxxxxxxxxx.supabase.co
   🔑 anon/public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```
4. Keep these safe - you'll add them to your app!

### Step 4: Create Database Tables
1. Click **🗄️ SQL Editor** (left sidebar)
2. Click **"New Query"**
3. Copy the entire SQL script from `database_setup.sql` (see below)
4. Click **▶️ Run**
5. ✅ You should see "Success. No rows returned"

### Step 5: Enable Storage (for profile photos)
1. Click **🗂️ Storage** (left sidebar)
2. Click **"New bucket"**
3. Create bucket:
   - **Name**: `profile-photos`
   - **Public**: ✅ Yes (checked)
4. Click **"Create bucket"**

5. Repeat for church photos:
   - **Name**: `church-photos`
   - **Public**: ✅ Yes

6. Repeat for campaign images:
   - **Name**: `campaign-images`
   - **Public**: ✅ Yes

---

## 💳 Part 2: Razorpay Setup (Payments)

### Step 1: Create Razorpay Account
1. Visit [https://razorpay.com](https://razorpay.com)
2. Click **"Sign Up"** (top right)
3. Enter:
   - Business/Your Name
   - Email
   - Phone Number
4. Verify email and phone OTP

### Step 2: Access Dashboard
1. Login to [Razorpay Dashboard]1
2. Toggle to **Test Mode** (switch at top of page)
   - 🧪 Test Mode = For development (no real money)
   - 💰 Live Mode = For production (real payments)

### Step 3: Generate API Keys
1. Click **⚙️ Settings** (left sidebar)
2. Click **API Keys** under "Developer Controls"
3. Click **"Generate Test Key"** (blue button)
4. A popup will show:
   ```
   Key ID: rzp_test_xxxxxxxxxxxxx
   Key Secret: xxxxxxxxxxxxxxxx (click eye icon to reveal)
   ```
5. **Download** or copy both keys

⚠️ **Important Notes**:
- **Test Keys** (`rzp_test_`) = Free testing, fake payments
- **Live Keys** (`rzp_live_`) = Real money (need KYC verification)
- Use Test Mode during development!

### Step 4: Test Payment Details (for development)
When testing donations, use these Razorpay test cards:

**Test Card Numbers**:
- Success: `4111 1111 1111 1111`
- Failure: `4111 1111 1111 1112`
- CVV: Any 3 digits (e.g., `123`)
- Expiry: Any future date (e.g., `12/25`)
- Name: Any name

**Test UPI**:
- UPI ID: `success@razorpay`

---

## 🔧 Part 3: Add Credentials to Your App

### Step 1: Open app_constants.dart
Open the file: `lib/constants/app_constants.dart`

### Step 2: Replace Placeholder Values

Replace these lines:
```dart
// ❌ BEFORE:
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
static const String razorpayKeySecret = 'YOUR_RAZORPAY_KEY_SECRET';

// ✅ AFTER (with your actual values):
static const String supabaseUrl = 'https://xxxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
static const String razorpayKeyId = 'rzp_test_xxxxxxxxxxxxx';
static const String razorpayKeySecret = 'xxxxxxxxxxxxxxxx';
```

### Step 3: Save the File
Press `Cmd + S` (Mac) or `Ctrl + S` (Windows/Linux)

### Step 4: Restart Your App
```bash
# Stop the running app (press 'q' in terminal or stop in IDE)
# Then run again:
flutter run
```

---

## 🧪 Testing Your Setup

### Test 1: Registration
1. Open the app
2. Click "Sign Up"
3. Fill in details and register
4. ✅ Should create account successfully

### Test 2: Profile Photo Upload
1. Go to Profile
2. Tap the camera icon
3. Select/take a photo
4. ✅ Should upload and display photo

### Test 3: Test Donation (Optional)
1. Create a sample campaign in Supabase:
   ```sql
   INSERT INTO campaigns (title, description, target_amount, end_date)
   VALUES ('Test Campaign', 'Test Description', 10000, '2026-12-31');
   ```
2. In app, go to Donations tab
3. Click "Donate Now"
4. Enter amount and proceed
5. Use test card: `4111 1111 1111 1111`
6. ✅ Payment should succeed

---

## 🔒 Security Best Practices

### ✅ DO:
- Use **Test Mode** for Razorpay during development
- Keep your **Key Secret** private
- Use environment variables in production
- Add `lib/constants/app_constants.dart` to `.gitignore` if pushing to public repo

### ❌ DON'T:
- Commit API keys to public GitHub repositories
- Share your Razorpay Key Secret publicly
- Use Live Mode keys in development
- Hardcode production credentials

---

## 🐛 Troubleshooting

### "Invalid Supabase URL" Error
- ✅ Check URL format: must start with `https://` and end with `.supabase.co`
- ✅ Remove any trailing slashes

### "Razorpay Key Invalid" Error
- ✅ Make sure you're in **Test Mode** in Razorpay dashboard
- ✅ Use the correct Key ID (starts with `rzp_test_`)
- ✅ Key Secret should NOT have spaces

### "Storage Error" when uploading photos
- ✅ Make sure you created the storage buckets in Supabase
- ✅ Ensure buckets are set to **Public**

### "Database Error"
- ✅ Run the SQL script again in Supabase SQL Editor
- ✅ Check if all tables were created (go to Table Editor)

---

## 📞 Need Help?

- **Supabase Docs**: [https://supabase.com/docs](https://supabase.com/docs)
- **Razorpay Docs**: [https://razorpay.com/docs](https://razorpay.com/docs)
- **Supabase Discord**: [https://discord.supabase.com](https://discord.supabase.com)

---

## ✅ Checklist

Before running your app, make sure:

- [ ] Supabase project created
- [ ] Database tables created (SQL script executed)
- [ ] Storage buckets created (profile-photos, church-photos, campaign-images)
- [ ] Supabase URL and anon key copied
- [ ] Razorpay account created (Test Mode)
- [ ] Razorpay API keys generated
- [ ] All credentials added to `app_constants.dart`
- [ ] App restarted after adding credentials

Once all checked, you're ready to go! 🚀
