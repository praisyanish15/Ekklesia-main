# Ekklesia Church Management App - Setup Guide

## Overview
Ekklesia is a comprehensive church management Flutter application with features for user authentication, church search, Bible reading, notifications, and donation campaigns.

## Prerequisites

1. Flutter SDK (3.10.1 or higher)
2. Dart SDK
3. Android Studio / Xcode (for mobile development)
4. Supabase Account
5. Razorpay Account (for payment integration)

## Installation Steps

### 1. Install Dependencies

Run the following command to install all required packages:

```bash
flutter pub get
```

### 2. Supabase Setup

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your Supabase URL and Anon Key from Settings > API
3. Update [lib/constants/app_constants.dart](lib/constants/app_constants.dart):

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Create Supabase Database Tables

Execute these SQL commands in your Supabase SQL editor:

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  photo_url TEXT,
  age INTEGER,
  address TEXT,
  gender TEXT,
  phone_number TEXT,
  role TEXT DEFAULT 'member',
  church_id UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);

-- Churches table
CREATE TABLE churches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  area TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  phone_number TEXT,
  email TEXT,
  description TEXT,
  photo_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);

-- Prayer requests table
CREATE TABLE prayer_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  church_id UUID REFERENCES churches(id),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  is_urgent BOOLEAN DEFAULT false,
  is_anonymous BOOLEAN DEFAULT false,
  prayer_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);

-- Campaigns table
CREATE TABLE campaigns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  church_id UUID REFERENCES churches(id),
  creator_id UUID REFERENCES users(id),
  prayer_request_id UUID REFERENCES prayer_requests(id),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  target_amount DECIMAL NOT NULL,
  current_amount DECIMAL DEFAULT 0,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  image_url TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);

-- Donations table
CREATE TABLE donations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  campaign_id UUID REFERENCES campaigns(id),
  user_id UUID REFERENCES users(id),
  amount DECIMAL NOT NULL,
  payment_id TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Bible bookmarks table
CREATE TABLE bible_bookmarks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  book TEXT NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Notifications table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL,
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 4. Set up Supabase Storage Buckets

1. Go to Storage in Supabase Dashboard
2. Create a bucket named `avatars` (for profile photos)
3. Set the bucket to Public
4. Add this policy:

```sql
CREATE POLICY "Allow authenticated users to upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Allow public to read avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

### 5. Razorpay Setup

1. Create a Razorpay account at [razorpay.com](https://razorpay.com)
2. Get your Key ID and Key Secret from Dashboard > Settings > API Keys
3. Update [lib/constants/app_constants.dart](lib/constants/app_constants.dart):

```dart
static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
static const String razorpayKeySecret = 'YOUR_RAZORPAY_KEY_SECRET';
```

### 6. Android Setup (for Razorpay)

Add this to [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 7. iOS Setup (for Razorpay)

Add this to [ios/Podfile](ios/Podfile):

```ruby
platform :ios, '11.0'
```

## Running the App

### Debug Mode

```bash
flutter run
```

### Release Mode

```bash
flutter run --release
```

### Build APK (Android)

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

## Features Implemented

### 1. Authentication & Registration
- Email/password authentication with Supabase
- Enhanced form validation with asterisks for required fields
- Custom error messages for empty/invalid fields
- User cannot submit until all required fields are filled
- Automatic navigation back to incomplete fields

### 2. Profile Management
- Upload profile photo (JPEG/PNG only, max 5MB)
- Edit profile with fields: name*, email (read-only), age, gender, phone, address
- Photo displayed in app bar (top right)
- Profile menu dropdown with logout option

### 3. Church Search
- Search churches by name and/or area
- View church details in popup dialog
- Join church functionality
- Display church information (address, phone, email, etc.)

### 4. Bible Module
- Search Bible verses by reference (e.g., "John 3:16")
- Multiple Bible versions (KJV, NIV, ESV, NKJV, NLT)
- Font size adjustment (12-30px)
- Dark/Light mode toggle
- Bookmark verses
- Share verses to Instagram, WhatsApp, Facebook
- Settings panel for Bible customization

### 5. Notifications System
- Real-time notifications for prayer requests and events
- Popup dialog when notification is clicked
- Mark as read functionality
- Swipe to dismiss
- Different notification types with icons
- Stream-based updates

### 6. Donations & Campaigns
- View active donation campaigns
- Progress bar showing current vs target amount
- Razorpay payment integration (UPI, cards, wallets)
- Campaign details with images
- Quick amount selection

### 7. UI/UX Features
- Profile photo in app bar
- Material Design 3
- Responsive layouts
- Loading states
- Error handling
- Form validation

## Not Implemented (Future Enhancements)

1. **Ads System** - Placeholder created, needs integration with AdMob
2. **Prayer Request Creation** - Backend ready, UI needs to be added
3. **Event Management** - Database table ready, screens to be created
4. **Offline Bible** - Currently using API, needs local database
5. **Push Notifications** - Firebase messaging setup needed

## Configuration Notes

### Image Upload
- Only JPEG and PNG formats allowed
- Maximum file size: 5MB
- Images automatically resized to 1920x1920px

### Validation
- Email: Must be valid format
- Password: Minimum 8 characters
- Phone: Indian format (10 digits starting with 6-9)
- Age: 1-150

## Troubleshooting

### Supabase Connection Issues
1. Verify your Supabase URL and Anon Key
2. Check internet connection
3. Ensure tables are created correctly

### Razorpay Payment Failures
1. Use test mode credentials during development
2. Verify Key ID and Secret are correct
3. Check internet permissions in AndroidManifest.xml

### Build Errors
1. Run `flutter clean`
2. Run `flutter pub get`
3. Restart IDE
4. Check Flutter doctor: `flutter doctor -v`

## Support

For issues or questions, please contact the development team or create an issue in the repository.
