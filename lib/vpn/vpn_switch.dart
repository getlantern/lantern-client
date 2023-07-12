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
  String countryCode = '';
  final isProUser = false;



  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _loadInterstitialAd() async {
    final countryCode = await sessionModel.getCountryCode();
    final hasAllPermissionGiven = await sessionModel.hasAllPermissionGiven();
    logger.i('[Ads Request] making request with country $countryCode');
    //To avoid calling multiple ads request repeatedly
    if (_interstitialAd == null&&countryCode=='IR'&&hasAllPermissionGiven) {
      logger.i('[Ads Request] making request');
      await InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdClicked: (ad) {
                logger.i('[Ads Request]  onAdClicked callback');
              },
              onAdShowedFullScreenContent: (ad) {
                logger.i('Showing Ads');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                logger.i('[Ads Request]  onAdFailedToShowFullScreenContent callback');
                //if ads fail to load let user turn on VPN
                postShowingAds();
              },
              onAdDismissedFullScreenContent: (ad) {
                logger.i('[Ads Request]  fullScreenContentCallback callback');
                postShowingAds();
              },
              
            );
            _interstitialAd = ad;
            logger.i('[Ads Request] to loaded $ad');
          },
          onAdFailedToLoad: (err) {
            logger.i('[Ads Request] failed to load $err');
          },
          
        ),
      );
    }
  }

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> onSwitchTap(
      bool newValue, String vpnStatus, bool proUser) async {
    unawaited(HapticFeedback.lightImpact());
    if (isIdle(vpnStatus)) {
      await vpnModel.switchVPN(newValue);
    }
    //add delayed to avoid flickering
    if (vpnStatus != 'connected') {
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          //Show add only on iran region
          if (_interstitialAd != null) {
            await _interstitialAd?.show();
          }
        },
      );
    }
  }

  void postShowingAds() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return sessionModel.proUser((context, proUser, child) => Transform.scale(
        scale: 2,
        child: vpnModel
            .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
          if (!proUser) {
            _loadInterstitialAd(); //preload ads
          }
          return FlutterSwitch(
            value: vpnStatus == 'connected' || vpnStatus == 'disconnecting',
            activeColor: onSwitchColor,
            inactiveColor: offSwitchColor,
            onToggle: (bool newValue) =>
                onSwitchTap(newValue, vpnStatus, proUser),
          );
        })));
  }
}
