# AdMob Configuration

To keep real ad unit ids out of version control, the project reads AdMob values from local-only files. Follow these steps to configure your environment:

## 1. Android app id

Edit `android/local.properties` and add your Android AdMob app id:

```
admob.app.id=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
```

If you skip this step, the build will use Google's sample app id, so real ads will not load.

## 2. Banner ad unit id

1. Copy `lib/core/ads/ads_config_local.example.dart` to `lib/core/ads/ads_config_local.dart`.
2. Replace the placeholder strings with your real ad unit ids:

```dart
const String kAndroidAdmobAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY';
const String kAndroidBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
```

The new file is ignored by Git (`.gitignore` already contains the path).

## 3. Verify

- Re-run `flutter pub get` and build the app.
- On Android, check logcat for `Ads` logs to confirm the correct ids are being used.

That's it—your AdMob ids will stay local, and the repository keeps only safe defaults.
