import 'package:flutter/material.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  Future<void> init() async {
    print('AdMob Service Initialized');
  }

  void showInterstitialAd() {
    print('Showing Interstitial Ad');
  }

  Widget getBannerWidget() {
    return const SizedBox.shrink();
  }
}