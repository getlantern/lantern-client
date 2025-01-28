import 'package:lantern/core/ads/ads_provider.dart';
import 'package:lantern/core/ads/app_open_ads_provider.dart';
import 'package:lantern/core/ads/interstitial_ad_provider.dart';
import 'package:lantern/core/utils/common.dart';

enum _AdsFormat { interstitial, appOpen }

class AdsService {
  final interstitialAdsService = InterstitialAdProvider();
  final appOpenAdsService = AppOpenAdsProvider();

  bool isAdsReadyToShow()  {
    if (appOpenAdsService.isAdReady()) {
      return true;
    }
    return interstitialAdsService.isAdReady();
  }

  Future<void> loadAds({required String provider}) async {
    if (provider.isEmpty) {
      adsLogger.i("[Ads Manager] Provider is empty do not show ads");
      return;
    }

    if (provider == _AdsFormat.interstitial.name) {
      adsLogger.i("[Ads Manager] Loading interstitial Ads");
      await interstitialAdsService.loadAd(showAds);
    } else if (provider == _AdsFormat.appOpen.name) {
      adsLogger.i("[Ads Manager] Loading appOpen Ads");
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
