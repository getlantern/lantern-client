import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/vpn/vpn.dart';

import '../ad_helper.dart';

class VPNSwitch extends StatefulWidget {
  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

class _VPNSwitchState extends State<VPNSwitch> {
  InterstitialAd? _interstitialAd;
  bool switchState = false;

  @override
  void initState() {
    _loadInterstitialAd(); //preload ads
    super.initState();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    //To avoid calling multiple ads request repeatedly
    if (_interstitialAd == null) {
      logger.i('Ads making request');
      InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdClicked: (ad) {
                logger.i('Ads  onAdClicked callback');
              },
              onAdShowedFullScreenContent: (ad) {
                logger.i('Showing Ads');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                logger.i('Ads  onAdFailedToShowFullScreenContent callback');
                //if ads fail to load let user turn on VPN
                postShowingAds();
              },
              onAdDismissedFullScreenContent: (ad) {
                logger.i('Ads  fullScreenContentCallback callback');
                postShowingAds();
              },
            );
            _interstitialAd = ad;
            logger.i('Ads to loaded $ad');
          },
          onAdFailedToLoad: (err) {
            logger.i('Ads failed to load $err');
          },
        ),
      );
    }
  }

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> onSwitchTap(bool newValue, String vpnStatus) async {
    switchState = newValue;
    unawaited(HapticFeedback.lightImpact());
    if (isIdle(vpnStatus) && _interstitialAd != null) {
      await _interstitialAd?.show();
    }
  }

  Future<void> toggleVPN() => vpnModel.switchVPN(switchState);
  
  void postShowingAds() {
    _interstitialAd?.dispose();
    toggleVPN();
    _interstitialAd = null;
    _loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 2,
      child: vpnModel
          .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
        return FlutterSwitch(
          value: isIdle(vpnStatus),
          activeColor: onSwitchColor,
          inactiveColor: offSwitchColor,
          onToggle: (bool newValue) => onSwitchTap(newValue, vpnStatus),
        );
      }),
    );
  }
}
