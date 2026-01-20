import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  // Test Ad Unit IDs (replace with your actual IDs in production)
  static const String _bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _bannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const String _interstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _interstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  static const String _rewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _rewardedAdUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  // Get Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _bannerAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _bannerAdUnitIdIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Get Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _interstitialAdUnitIdIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Get Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _rewardedAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _rewardedAdUnitIdIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Initialize Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('AdService: Mobile Ads initialized successfully');
    } catch (e) {
      print('AdService: Failed to initialize Mobile Ads: $e');
    }
  }

  /// Create and load a banner ad
  BannerAd createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) => print('BannerAd: Ad opened'),
        onAdClosed: (Ad ad) => print('BannerAd: Ad closed'),
      ),
    );
  }

  /// Load an interstitial ad
  Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          print('InterstitialAd: Ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd: Failed to load ad: $error');
        },
      ),
    );

    return interstitialAd;
  }

  /// Load a rewarded ad
  Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          print('RewardedAd: Ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd: Failed to load ad: $error');
        },
      ),
    );

    return rewardedAd;
  }

  /// Show interstitial ad
  void showInterstitialAd(InterstitialAd? ad, {VoidCallback? onAdDismissed}) {
    if (ad == null) {
      print('InterstitialAd: Ad is not ready');
      onAdDismissed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdDismissed?.call();
        print('InterstitialAd: Ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onAdDismissed?.call();
        print('InterstitialAd: Failed to show ad: $error');
      },
    );

    ad.show();
  }

  /// Show rewarded ad
  void showRewardedAd(
    RewardedAd? ad, {
    required Function(int amount, String type) onUserEarnedReward,
    VoidCallback? onAdDismissed,
  }) {
    if (ad == null) {
      print('RewardedAd: Ad is not ready');
      onAdDismissed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdDismissed?.call();
        print('RewardedAd: Ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onAdDismissed?.call();
        print('RewardedAd: Failed to show ad: $error');
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt(), reward.type);
        print('RewardedAd: User earned reward: ${reward.amount} ${reward.type}');
      },
    );
  }
}
