import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobBannerWidget extends StatefulWidget {
  const AdMobBannerWidget({super.key});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
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
      adUnitId:  _StaticKey.admobBannerIdPrd,
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

class _StaticKey {
  static String get admobBannerIdPrd {
    if (Platform.isIOS) {
      // iOS本番用
      return "ca-app-pub-3940256099942544/2934735716";
    } else if (Platform.isAndroid) {
      // Android本番用
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    throw UnsupportedError("対象外のプラットフォームです");
  }

  static String get admobBannerIdTest {
    if (Platform.isIOS) {
      // iOSテスト用
      return "ca-app-pub-3940256099942544/2934735716";
    } else if (Platform.isAndroid) {
      // Androidテスト用
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    throw UnsupportedError("対象外のプラットフォームです");
  }
}