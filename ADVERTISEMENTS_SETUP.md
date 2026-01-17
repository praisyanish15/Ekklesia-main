# Advertisement Setup Guide

This guide explains how advertisements are integrated into the Ekklesia app using Google Mobile Ads.

## Overview

The app uses Google Mobile Ads SDK to display advertisements. Currently configured with test ad units for development purposes.

## Features Implemented

### 1. Banner Ads
- Displayed at the bottom of Home screen
- Displayed at the top of Songs List screen
- Non-intrusive 320x50 standard banner size

### 2. Ad Types Available
- **Banner Ads**: Static ads displayed within the app layout
- **Interstitial Ads**: Full-screen ads (service ready, not yet used in UI)
- **Rewarded Ads**: Video ads that reward users (service ready, not yet used in UI)

## Files Created

### Services
- `lib/services/ad_service.dart` - Core ad service managing all ad types
- Singleton pattern for efficient ad management
- Platform-specific ad unit IDs for iOS and Android

### Widgets
- `lib/widgets/banner_ad_widget.dart` - Reusable banner ad component
- Automatic loading and error handling
- Graceful fallback when ads fail to load

## Configuration

### Android Setup
File: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

### iOS Setup
File: `ios/Runner/Info.plist`
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
</array>
```

## Current Ad Unit IDs (TEST ONLY)

⚠️ **Important**: These are Google's test ad unit IDs. Replace with your production IDs before releasing.

### Android Test IDs
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`
- App ID: `ca-app-pub-3940256099942544~3347511713`

### iOS Test IDs
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`
- App ID: `ca-app-pub-3940256099942544~1458002511`

## Screens with Ads

1. **Home Screen** (`lib/screens/home/home_screen.dart`)
   - Banner ad at bottom of scroll view
   - Non-intrusive placement after Quick Actions

2. **Songs List Screen** (`lib/screens/church/songs_list_screen.dart`)
   - Banner ad at top below app bar
   - Visible while browsing worship songs

## How to Add Ads to More Screens

To add banner ads to other screens:

```dart
// 1. Import the widget
import '../../widgets/banner_ad_widget.dart';

// 2. Add to your widget tree
Column(
  children: [
    // Your content...

    const SizedBox(height: 16),

    // Banner ad
    const BannerAdWidget(),

    // More content...
  ],
)
```

## Interstitial Ad Usage Example

```dart
import '../services/ad_service.dart';

// Load the ad
final interstitialAd = await AdService().loadInterstitialAd();

// Show when needed (e.g., after completing an action)
AdService().showInterstitialAd(
  interstitialAd,
  onAdDismissed: () {
    // Navigate or perform action after ad closes
    print('Ad dismissed, continuing...');
  },
);
```

## Rewarded Ad Usage Example

```dart
import '../services/ad_service.dart';

// Load the ad
final rewardedAd = await AdService().loadRewardedAd();

// Show and reward user
AdService().showRewardedAd(
  rewardedAd,
  onUserEarnedReward: (amount, type) {
    // Grant reward to user
    print('User earned $amount $type');
    // Example: Give user premium features, coins, etc.
  },
  onAdDismissed: () {
    print('Rewarded ad dismissed');
  },
);
```

## Getting Production Ad Units

### Step 1: Create AdMob Account
1. Go to https://admob.google.com
2. Sign in with your Google account
3. Create a new app in AdMob

### Step 2: Generate Ad Units
1. In AdMob dashboard, select "Apps"
2. Click on your app
3. Go to "Ad units"
4. Create ad units for each type:
   - Banner
   - Interstitial
   - Rewarded

### Step 3: Update Ad Unit IDs
Replace the test IDs in `lib/services/ad_service.dart`:

```dart
// Production Ad Unit IDs
static const String _bannerAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String _bannerAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
```

### Step 4: Update App IDs
Update Android and iOS configuration files with your production app IDs.

## Best Practices

### 1. Ad Placement
- Don't overload screens with too many ads
- Place ads naturally in content flow
- Avoid placing ads too close to interactive elements

### 2. User Experience
- Ensure ads don't interfere with core functionality
- Use interstitial ads sparingly (natural breaks)
- Offer value through rewarded ads

### 3. Performance
- Ads are loaded asynchronously
- Failed ads don't crash the app
- Graceful fallback when ads unavailable

### 4. Compliance
- Ensure ads comply with Google AdMob policies
- Don't encourage users to click ads
- Don't place ads on prohibited content

## Testing

The app currently uses test ad units which:
- Show "Test Ad" label
- Don't generate revenue
- Help verify ad implementation

Always test with test ad units during development to avoid policy violations.

## Revenue Tracking

Once using production ad units:
1. Monitor earnings in AdMob dashboard
2. Check impression and click rates
3. Optimize ad placement based on performance
4. A/B test different ad positions

## Troubleshooting

### Ads not showing
1. Check internet connection
2. Verify ad unit IDs are correct
3. Check AdMob dashboard for app status
4. Review device logs for error messages

### Build errors
1. Ensure `flutter pub get` was run
2. Clean and rebuild: `flutter clean && flutter pub get`
3. For iOS: `cd ios && pod install && cd ..`

## Dependencies

```yaml
dependencies:
  google_mobile_ads: ^5.2.0
```

## Additional Resources

- [Google Mobile Ads Flutter Plugin](https://pub.dev/packages/google_mobile_ads)
- [AdMob Documentation](https://developers.google.com/admob)
- [AdMob Policy Center](https://support.google.com/admob/answer/6128543)
