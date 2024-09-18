import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:logger/logger.dart';
import 'package:tapsell_mediation/tapsell.dart';

enum _AdsProvider { tapsell, admob }

var logger = Logger(printer: PrettyPrinter(), level: Level.debug);

abstract class AdsProvider {
  // int _failedLoadAttempts = 0;

  //If ads are getting failed to load we want to make lot of calls
  // Just try 5 times
  final int _maxFailAttempts = 5;

  Future<void> initialize(); // Initialize the ad provider.

  Future<void> loadInterstitialAd();

  Future<void> showInterstitialAd();

  Future<void> dispose();

  bool isAdReady();
}

class GoogleAdsProvider implements AdsProvider {
  InterstitialAd? _interstitialAd;
  int _failedLoadAttempts = 0;

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<void> loadInterstitialAd() async {
    assert(interstitialAdUnitId != "",
        "interstitialAdUnitId should not be null or empty");
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
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                logger.i(
                    '[Ads Manager] onAdFailedToShowFullScreenContent callback');
              },
              onAdDismissedFullScreenContent: (ad) {
                logger.i('[Ads Manager] fullScreenContentCallback callback');
              },
            );
            _interstitialAd = ad;
            logger.i('[Ads Manager] to loaded $ad');
          },
          onAdFailedToLoad: (err) {
            _failedLoadAttempts++; // increment the count on failure
            logger.i('[Ads Manager] failed to load $err');
            loadInterstitialAd();
          },
        ),
      );
    }
  }

  @override
  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd?.show();
    }
  }

  @override
  Future<void> dispose() async {
    await _interstitialAd?.dispose();
  }

  //Google Test ID if needed to test
  // return 'ca-app-pub-3940256099942544/1033173712';
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppSecret.androidAdsAppId;
    } else {
      return AppSecret.iOSAdsAppId;
    }
  }

  @override
  bool isAdReady() {
    return _interstitialAd != null;
  }

  Future<void> checkForConsent() async {
    logger.d('[Ads Manager] Checking for consent');
    final consentStatus = await ConsentInformation.instance.getConsentStatus();
    if (consentStatus == ConsentStatus.required) {
      logger.d('[Ads Manager] Consent Required');
      _loadConsentForm();
      return;
    }
    logger.d('[Ads Manager] consent not needed');
  }

  void _loadConsentForm() {
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {
      // success
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        logger.d('[Ads Manager] Consent Form is available ');
        ConsentForm.loadConsentForm((consentForm) {
          logger.d('[Ads Manager] Consent Form Loaded ');
          //Form is loaded successfully
          // Ready to display the consent
          consentForm.show((formError) {
            logger.d('[Ads Manager] Consent form dismissed');
          });
        }, (formError) {
          logger.d('[Ads Manager] Failed to load consent form');
          //Error while loading form
        });
      }
    }, (error) {
      // failure
      logger.d('[Ads Manager] Failed to request consent form');
    });
  }

  @override
  int get _maxFailAttempts => 5;
}

class TapSellAdsProvider implements AdsProvider {
  String appId = '';
  int _failedLoadAttempts = 0;

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<void> loadInterstitialAd() async {
    if (appId == '' && _failedLoadAttempts < _maxFailAttempts) {
      try {
        appId = (await Tapsell.requestInterstitialAd(AppSecret.interstitialZoneId) ?? '');
      } catch (e) {
        logger.e("requesting tapsell ad failed $e", error: e);
        _failedLoadAttempts++;
        loadInterstitialAd();
      }
    }
  }

  @override
  Future<void> showInterstitialAd() async {
    if (appId.isEmpty) {
      logger.d("Tapsell ad is not ready");
      return;
    }
    await Tapsell.showInterstitialAd(
      appId,
      onAdClicked: () {
        logger.d("Tapsell ad clicked");
      },
      onAdFailed: (message) {
        logger.e("Tapsell ad failed to show $message");
      },
      onAdClosed: (completionState) {
        logger.d("Tapsell ad closed $completionState");
      },
      onAdImpression: () {
        logger.d("Tapsell ad impression");
      },
    );
  }

  @override
  Future<void> dispose() {
    appId = '';
    return Future.value();
  }

  @override
  bool isAdReady() {
    return appId.isNotEmpty;
  }

  @override
  int get _maxFailAttempts => 5;
}

class AdHelper {
  final googleAdsService = GoogleAdsProvider();
  final tapSellAdsService = TapSellAdsProvider();

  static final AdHelper _instance = AdHelper._internal();

  AdHelper._internal();

  factory AdHelper() {
    return _instance;
  }

  Future<bool> isAdsReadyToShow() async {
    if (googleAdsService.isAdReady()) {
      return true;
    }
    if (tapSellAdsService.isAdReady()) {
      return true;
    }
    return false;
  }

  /// This is only used for android and ios
  /// if string value is "" then it will not show ads
  /// if string value is "tapsell" then it will show tapsell ads
  /// if string value is "admob" then it will show admob ads
  // Public methods
  Future<void> loadAds({
    required String provider,
  }) async {
    if (provider == _AdsProvider.admob.name) {
      googleAdsService.loadInterstitialAd();
    } else if (provider == _AdsProvider.tapsell.name) {
      tapSellAdsService.loadInterstitialAd();
    }
  }

  Future<void> showAds() async {
    ///while showing ads only one of the service will have the ads
    ///we don't need to check service type here
    if (googleAdsService.isAdReady()) {
      await googleAdsService.showInterstitialAd();
      return;
    }
    if (tapSellAdsService.isAdReady()) {
      await tapSellAdsService.showInterstitialAd();
    }
  }
}
