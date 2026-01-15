# 💳 Razorpay Integration Guide
## Ekklesia - Church Donations & Payments

This guide covers integrating Razorpay for church donations, tithes, and event payments.

---

## 📋 Prerequisites

- Razorpay account: https://razorpay.com
- KYC completed (for live mode)
- Test mode available immediately

---

## 🔐 SETUP RAZORPAY ACCOUNT

### Step 1: Create Account

1. Go to https://razorpay.com
2. Sign up with business email
3. Complete KYC verification (for production)
4. Access dashboard

### Step 2: Get API Keys

Go to **Settings** → **API Keys**

You'll get:
- **Key ID**: `rzp_test_...` or `rzp_live_...`
- **Key Secret**: Keep this private!

### Test Mode vs Live Mode:
- **Test**: Use for development (`rzp_test_`)
- **Live**: Use for production (`rzp_live_`)

---

## 📦 FLUTTER INTEGRATION

### Step 1: Add Dependency

Add to `pubspec.yaml`:

```yaml
dependencies:
  razorpay_flutter: ^1.3.5
```

Run:
```bash
flutter pub get
```

### Step 2: Platform-Specific Setup

#### Android (`android/app/build.gradle`)
```gradle
android {
    defaultConfig {
        minSdkVersion 19  // Razorpay requires minimum SDK 19
    }
}
```

#### iOS (`ios/Podfile`)
```ruby
platform :ios, '11.0'  # Razorpay requires minimum iOS 11
```

### Step 3: Create Razorpay Service

Create `lib/services/razorpay_service.dart`:

```dart
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
  }) {
    _razorpay = Razorpay();
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required double amount,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String description,
  }) {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY_ID',
      'amount': (amount * 100).toInt(),
      'name': 'Ekklesia',
      'description': description,
      'prefill': {'contact': userPhone, 'email': userEmail},
      'theme': {'color': '#2196F3'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }
}
```

---

## 🗄️ DATABASE SCHEMA FOR DONATIONS

Add this to Supabase SQL Editor:

```sql
CREATE TABLE IF NOT EXISTS donations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    user_name TEXT NOT NULL,
    church_id UUID NOT NULL REFERENCES churches(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('tithe', 'offering', 'mission', 'building', 'special')),
    payment_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'success',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_donations_church_id ON donations(church_id);
CREATE INDEX idx_donations_user_id ON donations(user_id);

ALTER TABLE donations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own donations"
    ON donations FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Church leaders can view church donations"
    ON donations FOR SELECT
    USING (
        church_id IN (
            SELECT cm.church_id FROM church_members cm
            WHERE cm.user_id = auth.uid()
            AND cm.role IN ('super_admin', 'admin')
        )
    );
```

---

## ✅ TEST CARDS

**Success**: `4111 1111 1111 1111`
**Failure**: `4012 0010 3714 1112`
CVV: Any 3 digits, Expiry: Any future date

---

## 📞 Support

- Docs: https://razorpay.com/docs
- Email: support@razorpay.com

---

**Ready to accept donations!** 💰
