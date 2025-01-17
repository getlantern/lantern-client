import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/core/ads/ads_provider.dart';

import '../utils/common.dart';

class AppOpenAdsProvider implements AdsProvider {
  AppOpenAd? _appOpenAd;
  int _failedLoadAttempts = 0;
  bool isAdsShown = false;

  final int _maxFailAttempts = 5;

  @override
  Future<void> loadAd(VoidCallback adLoadedCallback) async {
    assert(appOpenAdUnitId.isNotEmpty,
        "appOpenAdUnitId should not be null or empty");

    if (isAdsShown) {
      adsLogger.i("[Ads Manager] App open ad is already shown");
      return;
    }
    if (_appOpenAd == null && _failedLoadAttempts < _maxFailAttempts) {
      adsLogger.i('[Ads Manager] Request: Making Google Ad request.');
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
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
              },
            );
            _appOpenAd = ad;
            adsLogger.i('[Ads Manager] Ad loaded $ad');
            adLoadedCallback();
          },
          onAdFailedToLoad: (error) {
            _failedLoadAttempts++;
            adsLogger.i('[Ads Manager] failed to load $error');
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
    _appOpenAd?.show();
  }

  @override
  Future<void> dispose() async {
    await _appOpenAd?.dispose();
  }

  String appOpenAdUnitId =
      Platform.isAndroid ? AppSecret.androidAppOpenAd : AppSecret.iOSAppOpenAd;

  @override
  bool isAdReady() {
    return _appOpenAd != null;
  }
}
