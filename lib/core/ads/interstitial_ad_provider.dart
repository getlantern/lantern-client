import 'dart:io';
import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app/app_secret.dart';
import 'ads_provider.dart';

class InterstitialAdProvider implements AdsProvider {
  InterstitialAd? _interstitialAd;
  int _failedLoadAttempts = 0;
  bool isAdsShown = false;

  final int _maxFailAttempts = 5;

  @override
  Future<void> loadAd(VoidCallback adLoadedCallback) async {
    assert(interstitialAdUnitId.isNotEmpty,
        "interstitialAdUnitId should not be null or empty");

    if (isAdsShown) {
      adsLogger.i("[Ads Manager] Interstitial ad is already shown");
      return;
    }
    if (_interstitialAd == null && _failedLoadAttempts < _maxFailAttempts) {
      adsLogger.i('[Ads Manager] Request: Making Google Ad request.');
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _failedLoadAttempts = 0;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdClicked: (ad) {
                isAdsShown = true;
                adsLogger.i('[Ads Manager] onAdClicked callback');
              },
              onAdShowedFullScreenContent: (ad) {
                isAdsShown = true;
                adsLogger.i('[Ads Manager] Showing Ads');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                adsLogger.i(
                    '[Ads Manager] onAdFailedToShowFullScreenContent callback');
              },
              onAdDismissedFullScreenContent: (ad) {
                isAdsShown = true;
                adsLogger.i('[Ads Manager] fullScreenContentCallback callback');
                dispose();
              },
            );
            _interstitialAd = ad;
            adsLogger.i('[Ads Manager] Ad loaded $ad');
            adLoadedCallback();
          },
          onAdFailedToLoad: (err) {
            _failedLoadAttempts++;
            adsLogger.i('[Ads Manager] failed to load $err');
            Future.delayed(
              const Duration(seconds: 2),
              () async {
                await loadAd(adLoadedCallback);
              },
            );
          },
        ),
      );
    }
  }

  @override
  Future<void> showAd() async {
    if (isAdsShown) {
      adsLogger.i("[Ads Manager] Google ad is already shown");
      return;
    }
    _interstitialAd?.show();
  }

  @override
  Future<void> dispose() async {
    adsLogger.i("[Ads Manager] Disposing app open ad");
    await _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  String get interstitialAdUnitId {
    return Platform.isAndroid
        ? AppSecret.androidInterstitialAd
        : AppSecret.iOSInterstitialAd;
  }

  @override
  bool isAdReady() {
    return _interstitialAd != null;
  }
}
