# ⚡ Quick Start Guide

Get your Ekklesia app running in 10 minutes!

## 🎯 What You Need

1. **Supabase Account** (Free) - For backend & database
2. **Razorpay Account** (Free Test Mode) - For payment processing

---

## 📝 Step-by-Step Setup

### 1️⃣ Supabase Setup (5 minutes)

```
1. Go to: https://supabase.com
2. Sign up → Create new project
3. Settings → API → Copy these:
   • Project URL
   • anon/public key
4. SQL Editor → New Query → Paste database_setup.sql → Run
5. Storage → Create buckets:
   • profile-photos (public)
   • church-photos (public)
   • campaign-images (public)
```

### 2️⃣ Razorpay Setup (3 minutes)

```
1. Go to: https://razorpay.com
2. Sign up → Login to dashboard
3. Switch to TEST MODE (top toggle)
4. Settings → API Keys → Generate Test Key
5. Copy:
   • Key ID (rzp_test_xxxxx)
   • Key Secret (click eye to reveal)
```

### 3️⃣ Add to Your App (2 minutes)

Open `lib/constants/app_constants.dart` and replace:

```dart
static const String supabaseUrl = 'YOUR_URL_HERE';
static const String supabaseAnonKey = 'YOUR_KEY_HERE';
static const String razorpayKeyId = 'YOUR_KEY_ID_HERE';
static const String razorpayKeySecret = 'YOUR_SECRET_HERE';
```

### 4️⃣ Run the App

```bash
flutter pub get
flutter run
```

---

## 🧪 Testing

### Test Registration
- Email: `test@example.com`
- Password: `Test1234!`

### Test Payments (Use these test cards)
- Card: `4111 1111 1111 1111`
- CVV: `123`
- Expiry: `12/25`
- UPI: `success@razorpay`

---

## 📚 Full Documentation

- Detailed setup: [CREDENTIALS_SETUP.md](CREDENTIALS_SETUP.md)
- Database schema: [database_setup.sql](database_setup.sql)
- Troubleshooting: See CREDENTIALS_SETUP.md

---

## ✅ Quick Checklist

- [ ] Supabase project created
- [ ] Database tables created
- [ ] Storage buckets created
- [ ] Razorpay test keys generated
- [ ] Credentials added to app_constants.dart
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`

Done! 🎉
