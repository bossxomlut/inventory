import 'ads_config_default.dart' if (dart.library.io) 'ads_config_local.dart';

class AdsConfig {
  const AdsConfig({
    required this.androidAppId,
    required this.androidBannerAdUnitId,
  });

  final String androidAppId;
  final String androidBannerAdUnitId;
}

const AdsConfig adsConfig = AdsConfig(
  androidAppId: kAndroidAdmobAppId,
  androidBannerAdUnitId: kAndroidBannerAdUnitId,
);
