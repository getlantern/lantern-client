import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/replica/common.dart';

import 'common/session_model.dart';

class AdHelper {
  InterstitialAd? _interstitialAd;

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
     return '***REMOVED***';
      // return const String.fromEnvironment('INTERSTITIAL_AD_UNIT_ID');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> loadInterstitialAd() async {
    //shouldShowAds hold logic for showing ads
    final adsEnable = await sessionModel.shouldShowAds();
    logger.i('[Ads Request] support checking  value is $adsEnable');
    //To avoid calling multiple ads request repeatedly
    if (_interstitialAd == null && adsEnable) {
      logger.i('[Ads Request] making request');
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdClicked: (ad) {
                logger.i('[Ads Request] onAdClicked callback');
              },
              onAdShowedFullScreenContent: (ad) {
                logger.i('Showing Ads');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                logger.i(
                    '[Ads Request] onAdFailedToShowFullScreenContent callback');
                //if ads fail to load let user turn on VPN
                postShowingAds();
              },
              onAdDismissedFullScreenContent: (ad) {
                logger.i('[Ads Request] fullScreenContentCallback callback');
                postShowingAds();
              },
            );
            _interstitialAd = ad;
            logger.i('[Ads Request] to loaded $ad');
          },
          onAdFailedToLoad: (err) {
            logger.i('[Ads Request] failed to load $err');
          },
        ),
      );
    }
  }

  void postShowingAds() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    loadInterstitialAd();
  }

  Future<void> showAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd?.show();
    }
  }
}
