enum AdEnvironment { test, production }

// Danh sách devices test
const List<String> testDeviceIds = [
  '5BD91FB828CC09DF8924E4C90544DEB7',
];

abstract class AdUnitIds {
  String get bannerAdUnitId;

  String get interstitialAdUnitId;

  String get rewardedAdUnitId;
}

class TestAdUnitIds implements AdUnitIds {
  @override
  String get bannerAdUnitId => 'ca-app-pub-3940256099942544/6300978111';

  @override
  String get interstitialAdUnitId => 'ca-app-pub-3940256099942544/1033173712';

  @override
  String get rewardedAdUnitId => 'ca-app-pub-3940256099942544/5224354917';
}

class AndroidAdUnitIds implements AdUnitIds {
  @override
  String get bannerAdUnitId => 'YOUR_ANDROID_BANNER_AD_UNIT_ID';

  @override
  String get interstitialAdUnitId => 'YOUR_INTERSTITIAL_AD_UNIT_ID';

  @override
  String get rewardedAdUnitId => 'YOUR_REWARDED_AD_UNIT_ID';
}

class IOSAdUnitIds implements AdUnitIds {
  @override
  String get bannerAdUnitId => 'YOUR_IOS_BANNER_AD_UNIT_ID';

  @override
  String get interstitialAdUnitId => 'YOUR_INTERSTITIAL_AD_UNIT_ID';

  @override
  String get rewardedAdUnitId => 'YOUR_REWARDED_AD_UNIT_ID';
}
