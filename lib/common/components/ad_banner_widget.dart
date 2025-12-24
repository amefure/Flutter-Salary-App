import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:salary/models/secrets.dart';
import 'package:salary/viewmodels/reverpod/remove_ads_notifier.dart';

class AdMobBannerWidget extends ConsumerWidget {
  const AdMobBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removeAds = ref.watch(removeAdsProvider);
    if (removeAds) return const SizedBox.shrink();
    return const _AdMobBannerWidget();
  }
}


class _AdMobBannerWidget extends StatefulWidget {
  const _AdMobBannerWidget();

  @override
  State<_AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<_AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  /// 広告読み込み処理
  void _loadAd() {
    _bannerAd = BannerAd(
      // バナーID
      adUnitId:  StaticKey.admobBannerIdPrd,
      // バナーサイズ
      size: AdSize.fullBanner,
      request: const AdRequest(),
      // 読み込みイベントリスナー
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded && _bannerAd != null
        ? SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    ) : const SizedBox();
  }
}