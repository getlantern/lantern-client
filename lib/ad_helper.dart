import 'dart:io';

import 'package:clever_ads_solutions/CAS.dart';
import 'package:clever_ads_solutions/public/AdCallback.dart';
import 'package:clever_ads_solutions/public/AdImpression.dart';
import 'package:clever_ads_solutions/public/AdTypes.dart';
import 'package:clever_ads_solutions/public/ConsentFlow.dart';
import 'package:clever_ads_solutions/public/InitializationListener.dart';
import 'package:clever_ads_solutions/public/LoadingMode.dart';
import 'package:clever_ads_solutions/public/MediationManager.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/replica/common.dart';

import 'common/session_model.dart';

class AdHelper {
  static final AdHelper _instance = AdHelper._internal();

  AdHelper._internal();

  factory AdHelper() {
    return _instance;
  }

  MediationManager? casMediationManager;
  InterstitialAd? _interstitialAd;
  int _failedLoadAttempts = 0;

  //If ads are getting failed to load we want to make lot of calls
  // Just try 5 times
  final int _maxFailAttempts = 5;

  //Google Test ID if needed to test
  // return 'ca-app-pub-3940256099942544/1033173712';
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
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

  ///CAS initialization and method and listeners
  ///
  Future<void> initializeCAS() async {
    await CAS.setDebugMode(kDebugMode);
    // CAS.setFlutterVersion("1.20.0");
    await CAS.setAnalyticsCollectionEnabled(true);
    await CAS.validateIntegration();


    var builder = CAS
        .buildManager()
        .withTestMode(true)
        .withCasId('demo')
        .withAdTypes(AdTypeFlags.Interstitial)
        .withInitializationListener(InitializationListenerWrapper())
        .withConsentFlow(
            ConsentFlow(privacyPolicy: 'https://lantern.io/privacy'))
        .withTestMode(true);
    casMediationManager = builder.initialize();
    // This can be useful when you need to improve application performance by turning off unused formats.
    casMediationManager!.setEnabled(AdTypeFlags.Interstitial, true);
    // await CAS.setTestDeviceIds(['D79728264130CE0918737B5A2178D362']);
  }
  Future<void> loadCASInterstitial() async {
    if (casMediationManager != null) {
      await casMediationManager!.loadInterstitial();
    }
  }

  Future<void> showCASInterstitial() async {
    if (casMediationManager != null &&
        (await casMediationManager!.isInterstitialReady())) {
      await casMediationManager!
          .showInterstitial(InterstitialListenerWrapper());
    }
  }

  //This method will use used when free user buy Pro version
  Future<void> turnOffCASInterstitial() async {
    await casMediationManager!.setEnabled(AdTypeFlags.Interstitial, false);
  }
}

class InitializationListenerWrapper extends InitializationListener {
  @override
  void onCASInitialized(bool success, String error) {
    logger.i('[CASIntegrationHelper] - onCASInitialized $success $error');
  }
}

class InterstitialListenerWrapper extends AdCallback {
  @override
  void onClicked() {
    logger.i('[CASIntegrationHelper] - InterstitialListenerWrapper onClicked');
  }

  @override
  void onClosed() {
    // Called when ad is clicked

    logger.i('[CASIntegrationHelper] - InterstitialListenerWrapper onClosed');
  }

  @override
  void onComplete() {
    // Called when ad is dismissed

    logger.i('[CASIntegrationHelper] - InterstitialListenerWrapper onComplete');
  }

  @override
  void onImpression(AdImpression? adImpression) {
    // Called when ad is paid.

    logger.i(
        '[CASIntegrationHelper] - InterstitialListenerWrapper onImpression-:$adImpression');
  }

  @override
  void onShowFailed(String? message) {
    // Called when ad fails to show.

    logger.i(
        '[CASIntegrationHelper] - InterstitialListenerWrapper onShowFailed-:$message');
  }

  @override
  void onShown() {
    // Called when ad is shown.
    logger.i('[CASIntegrationHelper] - InterstitialListenerWrapper onShown');
  }
}
