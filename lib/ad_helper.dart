import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/replica/common.dart';

import 'common/session_model.dart';

class AdHelper {
  InterstitialAd? _interstitialAd;
  int _failedLoadAttempts = 0;

  //If ads are getting failed to load we want to make lot of calls
  // Just try 5 times
  final int _maxFailAttempts = 5;

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // return '***REMOVED***';
      // return 'ca-app-pub-3940256099942544/1033173712';
      return const String.fromEnvironment('INTERSTITIAL_AD_UNIT_ID');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> loadInterstitialAd() async {
    //shouldShowAds hold logic for showing ads
    final adsEnable = await sessionModel.shouldShowAds();
    logger.i('[Ads Request] support checking  value is $adsEnable');
    print('INTERSTITIAL_AD_UNIT_ID is $interstitialAdUnitId');
    //To avoid calling multiple ads request repeatedly
    if (_interstitialAd == null &&
        adsEnable &&
        _failedLoadAttempts < _maxFailAttempts) {
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
            _failedLoadAttempts++; // increment the count on failure
            logger.i('[Ads Request] failed to load $err');
            postShowingAds();
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
