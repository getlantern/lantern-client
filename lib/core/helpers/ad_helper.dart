import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:logger/logger.dart';

enum _AdsProvider { google }

var logger = Logger(
  printer: PrettyPrinter(
    printEmojis: true,
    methodCount: 0,
    colors: true,
  ),
  level: Level.debug,
);

abstract class AdsProvider {
  Future<void> loadInterstitialAd(VoidCallback adLoadedCallback);

  Future<void> showInterstitialAd();

  Future<void> dispose();

  bool isAdReady();
}

class GoogleAdsProvider implements AdsProvider {
  InterstitialAd? _interstitialAd;
  int _failedLoadAttempts = 0;
  bool isAdsShown = false;

  final int _maxFailAttempts = 5;

  @override
  Future<void> loadInterstitialAd(VoidCallback adLoadedCallback) async {
    assert(interstitialAdUnitId.isNotEmpty,
        "interstitialAdUnitId should not be null or empty");

    if (isAdsShown) {
      logger.i("[Ads Manager] Google ad is already shown");
      return;
    }
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
                isAdsShown = true;
                logger.i('[Ads Manager] onAdClicked callback');
              },
              onAdShowedFullScreenContent: (ad) {
                isAdsShown = true;
                logger.i('[Ads Manager] Showing Ads');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                logger.i(
                    '[Ads Manager] onAdFailedToShowFullScreenContent callback');
              },
              onAdDismissedFullScreenContent: (ad) {
                isAdsShown = true;
                logger.i('[Ads Manager] fullScreenContentCallback callback');
              },
            );
            _interstitialAd = ad;
            logger.i('[Ads Manager] Ad loaded $ad');
            adLoadedCallback();
          },
          onAdFailedToLoad: (err) {
            _failedLoadAttempts++;
            logger.i('[Ads Manager] failed to load $err');
            Future.delayed(
              const Duration(milliseconds: 500),
              () {
                loadInterstitialAd(adLoadedCallback);
              },
            );
          },
        ),
      );
    }
  }

  @override
  Future<void> showInterstitialAd() async {
    if (isAdsShown) {
      logger.i("[Ads Manager] Google ad is already shown");
      return;
    }
    _interstitialAd?.show();
  }

  @override
  Future<void> dispose() async {
    await _interstitialAd?.dispose();
  }

  String get interstitialAdUnitId {
    return Platform.isAndroid
        ? AppSecret.androidAdsAppId
        : AppSecret.iOSAdsAppId;
  }

  @override
  bool isAdReady() {
    return _interstitialAd != null;
  }
}

class AdHelper {
  final googleAdsService = GoogleAdsProvider();
  static final AdHelper _instance = AdHelper._internal();

  AdHelper._internal();

  factory AdHelper() => _instance;

  Future<bool> isAdsReadyToShow() async {
    return googleAdsService.isAdReady();
  }

  Future<void> loadAds({required String provider}) async {
    if (provider.isEmpty) {
      logger.i("[Ads Manager] Provider is empty do not show ads");
      return;
    }
    if (provider == _AdsProvider.google.name) {
      logger.i("[Ads Manager] Loading Google Ads");
      await googleAdsService.loadInterstitialAd(showAds);
    }
  }

  Future<void> showAds() async {
    if (googleAdsService.isAdReady()) {
      await googleAdsService.showInterstitialAd();
    }
  }
}
