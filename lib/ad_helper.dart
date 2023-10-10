import 'dart:io';

import 'package:clever_ads_solutions/CAS.dart';
import 'package:clever_ads_solutions/public/AdCallback.dart';
import 'package:clever_ads_solutions/public/AdImpression.dart';
import 'package:clever_ads_solutions/public/AdTypes.dart';
import 'package:clever_ads_solutions/public/Audience.dart';
import 'package:clever_ads_solutions/public/InitConfig.dart';
import 'package:clever_ads_solutions/public/InitializationListener.dart';
import 'package:clever_ads_solutions/public/MediationManager.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

enum AdType { Google, CAS }

const privacyPolicy = 'https://lantern.io/privacy';

const googleAttributes = {
  'provider': "Google",
};

const casAttributes = {
  'provider': "CAS",
};

var logger = Logger(
  printer: PrettyPrinter(),
);

class AdHelper {
  static final AdHelper _instance = AdHelper._internal();

  AdHelper._internal();

  factory AdHelper() {
    return _instance;
  }

  AdType? _currentAdType;
  MediationManager? casMediationManager;
  InterstitialAd? _interstitialAd;
  int _failedLoadAttempts = 0;
  int _failedCASLoadAttempts = 0;

  //If ads are getting failed to load we want to make lot of calls
  // Just try 5 times
  final int _maxFailAttempts = 5;

  //Google Test ID if needed to test
  // return 'ca-app-pub-3940256099942544/1033173712';
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2685698271254859/9922829329';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Private methods to decide whether to load or show Google Ads or CAS ads based on conditions
  Future<void> _decideAndLoadAds(
      {required bool shouldShowGoogleAds,
      required bool shouldShowCASAds}) async {
    logger.d(
        '[Ads Manager] Google Ads enable $shouldShowGoogleAds: CAS Ads $shouldShowCASAds');
    if (shouldShowGoogleAds) {
      _currentAdType = AdType.Google;
      logger.i('[Ads Manager] Decision: Loading Google Ads.');
      await _loadInterstitialAd();
    } else if (shouldShowCASAds) {
      _currentAdType = AdType.CAS;
      logger.i('[Ads Manager] Decision: Loading CAS Ads.');
      if (casMediationManager == null) {
        await _initializeCAS();
      }
      await _loadCASInterstitial();
    }
  }

  Future<void> _decideAndShowAds() async {
    if (_currentAdType == AdType.Google && _interstitialAd != null) {
      await _showInterstitialAd();
    } else if (_currentAdType == AdType.CAS) {
      final isCASReady = (await casMediationManager!.isInterstitialReady());
      if (isCASReady) {
        await _showCASInterstitial();
        logger.i('[Ads Manager] Request: Showing CAS Ad .');
      } else {
        logger.i('[Ads Manager] CAS: Ad is not yet ready to show.');
      }
    }
  }

  Future<void> _loadInterstitialAd() async {
    //To avoid calling multiple ads request repeatedly
    assert(interstitialAdUnitId!="","interstitialAdUnitId should not be null or empty");
    if (_interstitialAd == null && _failedLoadAttempts < _maxFailAttempts) {
      logger.i('[Ads Manager] Request: Making Google Ad request.');
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _failedLoadAttempts = 0;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdClicked: (ad) {
                logger.i('[Ads Manager] onAdClicked callback');
              },
              onAdShowedFullScreenContent: (ad) {
                logger.i('[Ads Manager] Showing Ads');
                PlausibleUtils.trackUserAction(
                    'User shown interstitial ad', googleAttributes);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                logger.i(
                    '[Ads Manager] onAdFailedToShowFullScreenContent callback');
                //if ads fail to load let user turn on VPN
                _postShowingAds();
              },
              onAdDismissedFullScreenContent: (ad) {
                logger.i('[Ads Manager] fullScreenContentCallback callback');
                _postShowingAds();
              },
            );
            _interstitialAd = ad;
            logger.i('[Ads Manager] to loaded $ad');
            PlausibleUtils.trackUserAction('Interstitial ad loaded', googleAttributes);
          },
          onAdFailedToLoad: (err) {
            _failedLoadAttempts++; // increment the count on failure
            logger.i('[Ads Manager] failed to load $err');
            _postShowingAds();
          },
        ),
      );
    }
  }

  void _postShowingAds() {
    if (_currentAdType == AdType.Google) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      logger.i(
          '[Ads Manager] Post-show: Google Ad displayed. Resetting failed load attempts and requesting a new ad.');
      _loadInterstitialAd();
    } else if (_currentAdType == AdType.CAS) {
      logger.i(
          '[Ads Manager] Post-show: CAS Ad displayed. Resetting failed load attempts and requesting a new ad.');
      _loadCASInterstitial();
    }
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd?.show();
    }
  }

  // Public methods
  Future<void> loadAds(
      {required bool shouldShowGoogleAds,
      required bool shouldShowCASAds}) async {
    await _decideAndLoadAds(
      shouldShowCASAds: shouldShowCASAds,
      shouldShowGoogleAds: shouldShowGoogleAds,
    );
  }

  Future<void> showAds() async {
    await _decideAndShowAds();
  }

  ///CAS initialization and method and listeners
  ///
  Future<void> _initializeCAS() async {
    await CAS.setDebugMode(kDebugMode);
    await CAS.setAnalyticsCollectionEnabled(true);
    // CAS.setFlutterVersion("1.20.0");
    // await CAS.validateIntegration();

    var builder = CAS
        .buildManager()
        .withCasId('org.getlantern.lantern')
        .withAdTypes(AdTypeFlags.Interstitial)
        .withInitializationListener(InitializationListenerWrapper())
        .withTestMode(false);

    CAS.buildConsentFlow().withPrivacyPolicy(privacyPolicy);
    casMediationManager = builder.initialize();
    // This can be useful when you need to improve application performance by turning off unused formats.
    await casMediationManager!.setEnabled(AdTypeFlags.Interstitial, true);
    await CAS.setTaggedAudience(Audience.NOT_CHILDREN);
    // await CAS.setTestDeviceIds(['D79728264130CE0918737B5A2178D362']);
    logger.i('[Ads Manager] Initialization: CAS completed.');
  }

  Future<void> _loadCASInterstitial() async {
    if (casMediationManager != null) {
      await casMediationManager!.loadInterstitial();
      logger.i('[Ads Manager] Request: Initiating CAS Interstitial loading.');
    }
  }

  Future<void> _showCASInterstitial() async {
    logger.i('[Ads Manager] Show: Attempting to display CAS Interstitial.');
    await casMediationManager!.showInterstitial(InterstitialListenerWrapper(
        onFailed: _onCASAdShowFailed,
        onClosedOrComplete: _onCASAdClosedOrComplete));
  }

  void _onCASAdShowFailed() {
    logger.e('[Ads Manager] Error: CAS Interstitial failed to display.');
    _failedCASLoadAttempts++;
    _postShowingAds(); // Reload or decide the next action
  }

  void _onCASAdClosedOrComplete() {
    logger.i('[Ads Manager] Completion: CAS Interstitial closed or completed.');
    // Reset the counter when the ad successfully shows and closes/completes
    _failedCASLoadAttempts = 0;
    _postShowingAds();
  }

  //This method will use used when free user buy Pro version
  Future<void> turnOffCASInterstitial() async {
    await casMediationManager!.setEnabled(AdTypeFlags.Interstitial, false);
  }
}

class InitializationListenerWrapper extends InitializationListener {
  @override
  void onCASInitialized(InitConfig initialConfig) {
    logger.i('[CASIntegrationHelper] - onCASInitialized $initialConfig');
  }
}

class InterstitialListenerWrapper extends AdCallback {
  final VoidCallback onFailed;
  final VoidCallback onClosedOrComplete;

  InterstitialListenerWrapper({
    required this.onFailed,
    required this.onClosedOrComplete,
  });

  @override
  void onClicked() {
    logger.i('[CASIntegrationHelper] - InterstitialListenerWrapper onClicked');
  }

  @override
  void onClosed() {
    // Called when ad is clicked
    onClosedOrComplete();
    logger.i('[CASIntegrationHelper] - InterstitialListenerWrapper onClosed');
  }

  @override
  void onComplete() {
    // Called when ad is dismissed
    onClosedOrComplete();
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
    onFailed.call();
    logger.i(
        '[CASIntegrationHelper] - InterstitialListenerWrapper onShowFailed-:$message');
  }

  @override
  void onShown() {
    // Called when ad is shown.
    logger.i('[CASIntegrationHelper] - InterstitialListenerWrapper onShown');
  }
}
