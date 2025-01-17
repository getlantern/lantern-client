import 'package:lantern/core/ads/app_open_ads_provider.dart';
import 'package:lantern/core/ads/interstitial_ad_provider.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';

enum _AdsFormat { interstitial, appOpen }

class AdsService {

  final interstitialAdsService = InterstitialAdProvider();
  final appOpenAdsService = AppOpenAdsProvider();

  Future<bool> isAdsReadyToShow() async {
    return interstitialAdsService.isAdReady();
  }

  Future<void> loadAds({required String provider}) async {
    if (provider.isEmpty) {
      logger.i("[Ads Manager] Provider is empty do not show ads");
      return;
    }

    if (provider == _AdsFormat.interstitial.name) {
      logger.i("[Ads Manager] Loading interstitial Ads");
      await interstitialAdsService.loadAd(showAds);
    } else if (provider == _AdsFormat.appOpen.name) {
      logger.i("[Ads Manager] Loading appOpen Ads");
      await appOpenAdsService.loadAd(showAds);
    }
  }

  Future<void> showAds() async {
    if (interstitialAdsService.isAdReady()) {
      await interstitialAdsService.showAd();
    } else if (appOpenAdsService.isAdReady()) {
      await appOpenAdsService.showAd();
    }
  }
}
