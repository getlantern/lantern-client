import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:logger/logger.dart';
import 'package:tapsell_mediation/tapsell.dart';

enum _AdsProvider { tapsell, google }

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

class TapSellAdsProvider implements AdsProvider {
  String appId = '';
  int _failedLoadAttempts = 0;
  bool isAdLoading = false;
  bool isAdsShown = false;
  final int _maxFailAttempts = 5;

  @override
  Future<void> loadInterstitialAd(VoidCallback adLoadedCallback) async {
    if (isAdLoading || isAdsShown || appId.isNotEmpty) {
      logger.i(
          "[Ads Manager] Tapsell ad is already loading $isAdLoading or shown $isAdsShown");
      return;
    }
    if (_failedLoadAttempts < _maxFailAttempts) {
      try {
        isAdLoading = true;
        appId = (await Tapsell.requestInterstitialAd(
                AppSecret.videoInterstitialZoneId)) ??
            '';
        logger.i("[Ads Manager] Tapsell ad loaded $appId");
        isAdLoading = false;
        if (appId.isNotEmpty) {
          adLoadedCallback();
        } else {
          _failedLoadAttempts++;
          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              loadInterstitialAd(adLoadedCallback);
            },
          );
        }
      } catch (e) {
        logger.e("[Ads Manager] requesting tapsell ad failed $e", error: e);
        _failedLoadAttempts++;
        isAdLoading = false;
        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            loadInterstitialAd(adLoadedCallback);
          },
        );
      }
    }
  }

  @override
  Future<void> showInterstitialAd() async {
    if (appId.isEmpty || isAdsShown) {
      logger.i(
          "[Ads Manager] Tapsell ad is not ready or already shown $isAdsShown");
      return;
    }
    await Tapsell.showInterstitialAd(
      appId,
      onAdClicked: () {
        logger.i("[Ads Manager] Tapsell ad clicked");
        isAdsShown = true;
      },
      onAdFailed: (message) {
        logger.e("[Ads Manager] Tapsell ad failed to show $message");
      },
      onAdClosed: (completionState) {
        logger.i("[Ads Manager] Tapsell ad closed $completionState");
        isAdsShown = true;
      },
      onAdImpression: () {
        logger.i("[Ads Manager] Tapsell ad impression");
        isAdsShown = true;
      },
    );
  }

  @override
  Future<void> dispose() {
    appId = '';
    isAdsShown = true;
    return Future.value();
  }

  @override
  bool isAdReady() {
    return appId.isNotEmpty;
  }
}

class AdHelper {
  final googleAdsService = GoogleAdsProvider();
  final tapSellAdsService = TapSellAdsProvider();
  static final AdHelper _instance = AdHelper._internal();

  AdHelper._internal();

  factory AdHelper() => _instance;

  Future<bool> isAdsReadyToShow() async {
    return googleAdsService.isAdReady() || tapSellAdsService.isAdReady();
  }

  Future<void> loadAds({required String provider}) async {
    if (provider == _AdsProvider.google.name) {
      logger.i("[Ads Manager] Loading Google Ads");
      await googleAdsService.loadInterstitialAd(showAds);
    } else if (provider == _AdsProvider.tapsell.name) {
      logger.i("[Ads Manager] Loading Tapsell Ads");
      await tapSellAdsService.loadInterstitialAd(showAds);
    }
  }

  Future<void> showAds() async {
    if (googleAdsService.isAdReady()) {
      await googleAdsService.showInterstitialAd();
    } else if (tapSellAdsService.isAdReady()) {
      await tapSellAdsService.showInterstitialAd();
    }
  }
}
