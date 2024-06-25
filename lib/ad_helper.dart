import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:logger/logger.dart';

enum AdType { Google }

const privacyPolicy = 'https://lantern.io/privacy';

const googleAttributes = {
  'provider': "Google",
};


var logger = Logger(printer: PrettyPrinter(), level: Level.debug);

class AdHelper {
  static final AdHelper _instance = AdHelper._internal();

  AdHelper._internal();

  factory AdHelper() {
    return _instance;
  }


  InterstitialAd? _interstitialAd;
  int _failedLoadAttempts = 0;

  //If ads are getting failed to load we want to make lot of calls
  // Just try 5 times
  final int _maxFailAttempts = 5;
  bool isAdsLoading = false;
  //Google Test ID if needed to test
  // return 'ca-app-pub-3940256099942544/1033173712';
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppSecret.androidAdsAppId;
    } else {
      return AppSecret.iOSAdsAppId;
    }
  }

  // Private methods to decide whether to load or show Google Ads or CAS ads based on conditions
  Future<void> _decideAndLoadAds({required bool shouldShowGoogleAds}) async {
    checkForConsent();
    logger.d('[Ads Manager] Google Ads enable $shouldShowGoogleAds:');
    if (shouldShowGoogleAds) {
      logger.i('[Ads Manager] Decision: Loading Google Ads.');
      await _loadInterstitialAd();
    }
  }

  Future<bool> isAdsReadyToShow() async {
    return _interstitialAd != null;
  }

  Future<void> _decideAndShowAds() async {
    if (_interstitialAd != null) {
      await _showInterstitialAd();
    }
  }

  Future<void> _loadInterstitialAd() async {
    //To avoid calling multiple ads request repeatedly
    isAdsLoading= true;
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
            isAdsLoading= false;
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
    _interstitialAd?.dispose();
    _interstitialAd = null;
    logger.i(
        '[Ads Manager] Post-show: Google Ad displayed. Resetting failed load attempts and requesting a new ad.');
    _loadInterstitialAd();
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd?.show();
    }
  }

  // Public methods
  Future<void> loadAds({
    required bool shouldShowGoogleAds,
  }) async {
    if(isAdsLoading) {
      logger.i('[Ads Manager] Request: Ads already loading. Ignoring request.');
      return;
    }

    await _decideAndLoadAds(
      shouldShowGoogleAds: shouldShowGoogleAds,
    );
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

  Future<void> showAds() async {
    await _decideAndShowAds();
  }
}
