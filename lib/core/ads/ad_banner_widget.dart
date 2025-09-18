import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sample_app/core/ads/admob_service.dart';

class _BannerContainer extends StatefulWidget {
  final AdSize size;
  const _BannerContainer({super.key, required this.size});

  @override
  State<_BannerContainer> createState() => AdMobService().showAds ? _BannerContainerState() : _EmptyState();
}

class _EmptyState extends State<_BannerContainer> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _BannerContainerState extends State<_BannerContainer> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdMobService().createBannerAd(
      size: widget.size,
      onAdLoaded: () {
        if (mounted) setState(() => _isLoaded = true);
      },
      onAdFailedToLoad: (err) {
        if (mounted) setState(() => _isLoaded = false);
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Builder(
        builder: (BuildContext context) {
          final height = widget.size.height.toDouble();
          if (!_isLoaded || _bannerAd == null) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: height,
            child: AdWidget(ad: _bannerAd!),
          );
        },
      ),
    );
  }
}

class AdBannerSmallWidget extends StatelessWidget {
  const AdBannerSmallWidget({super.key});

  @override
  Widget build(BuildContext context) => const _BannerContainer(size: AdSize.banner);
}

class AdBannerLargeWidget extends StatelessWidget {
  const AdBannerLargeWidget({super.key});

  @override
  Widget build(BuildContext context) => const _BannerContainer(size: AdSize.largeBanner);
}

class AdBannerMediumRectangleWidget extends StatelessWidget {
  const AdBannerMediumRectangleWidget({super.key});

  @override
  Widget build(BuildContext context) => const _BannerContainer(size: AdSize.mediumRectangle);
}
