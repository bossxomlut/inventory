import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

import 'admob_config.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();

  factory AdMobService() => _instance;

  AdMobService._internal();

  final Logger _logger = Logger();

  bool get showAds => !kReleaseMode;

  AdEnvironment get env => kReleaseMode ? AdEnvironment.production : AdEnvironment.test;

  // Sử dụng test IDs cho development
  AdEnvironment get environment => showAds ? env : AdEnvironment.test;

  late final AdUnitIds _adUnitIds = environment == AdEnvironment.test
      ? TestAdUnitIds()
      : Platform.isAndroid
          ? AndroidAdUnitIds()
          : IOSAdUnitIds();

  // Getters cho Ad Unit ID
  String get bannerAdUnitId => _adUnitIds.bannerAdUnitId;

  String get interstitialAdUnitId => _adUnitIds.interstitialAdUnitId;

  String get rewardedAdUnitId => _adUnitIds.rewardedAdUnitId;

  /// Khởi tạo Mobile Ads SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _logger.i('AdMob initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize AdMob: $e');
    }
  }

  /// Đăng ký thiết bị test
  Future<void> setTestDeviceIds({List<String>? deviceIds}) async {
    final RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: deviceIds ?? testDeviceIds,
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);
  }

  /// Tạo Banner Ad
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    required void Function() onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _logger.i('Banner ad loaded successfully');
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          _logger.e('Banner ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad(error);
        },
        onAdOpened: (_) => _logger.i('Banner ad opened'),
        onAdClosed: (_) => _logger.i('Banner ad closed'),
      ),
    );
  }

  /// Tạo và load Interstitial Ad
  Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _logger.i('Interstitial ad loaded successfully');
          interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) => _logger.i('Interstitial ad showed'),
            onAdDismissedFullScreenContent: (ad) {
              _logger.i('Interstitial ad dismissed');
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _logger.e('Interstitial ad failed to show: $error');
              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _logger.e('Interstitial ad failed to load: $error');
        },
      ),
    );

    return interstitialAd;
  }

  /// Tạo và load Rewarded Ad
  Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _logger.i('Rewarded ad loaded successfully');
          rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) => _logger.i('Rewarded ad showed'),
            onAdDismissedFullScreenContent: (ad) {
              _logger.i('Rewarded ad dismissed');
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _logger.e('Rewarded ad failed to show: $error');
              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _logger.e('Rewarded ad failed to load: $error');
        },
      ),
    );

    return rewardedAd;
  }

  /// Hiển thị Interstitial Ad
  Future<void> showInterstitialAd(InterstitialAd? ad) async {
    if (ad != null) {
      await ad.show();
    } else {
      _logger.w('Interstitial ad is not ready to show');
    }
  }

  /// Hiển thị Rewarded Ad
  Future<void> showRewardedAd(
    RewardedAd? ad, {
    required void Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward,
  }) async {
    if (ad != null) {
      await ad.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      _logger.w('Rewarded ad is not ready to show');
    }
  }
}
