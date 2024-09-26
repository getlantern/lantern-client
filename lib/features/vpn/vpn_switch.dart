import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/helpers/ad_helper.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/features/vpn/vpn.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';



class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

//implement this switch with loading implementation
//https://pub.dev/packages/animated_toggle_switch
class _VPNSwitchState extends State<VPNSwitch> {
  final adHelper = AdHelper();

  @override
  Widget build(BuildContext context) {
    final internetStatusProvider = context.watch<InternetStatusProvider>();
    final vpnNotifier = context.watch<VPNChangeNotifier>();

    if (isMobile()) {
      return sessionModel
          .shouldShowGoogleAds((context, isGoogleAdsEnable, child) {
        //Since we don't have feature flag on ios at the moment
        // disable ads'
        if (Platform.isAndroid) {
          adHelper.loadAds(shouldShowGoogleAds: isGoogleAdsEnable);
        }
        return vpnModel.vpnStatus(context,
            (BuildContext context, String vpnStatus, Widget? child) {
          // Changes scale on mobile due to hit target
          return AdvancedSwitch(
            width: 150,
            height: 70,
            borderRadius: BorderRadius.circular(40),
            disabledOpacity: 1,
            enabled: (internetStatusProvider.isConnected &&
                !vpnNotifier.isFlashlightInitializedFailed),
            initialValue: vpnStatus == 'connected' ||
                vpnStatus == 'disconnecting' ||
                vpnStatus == 'connecting',
            activeColor: onSwitchColor,
            inactiveColor: (internetStatusProvider.isConnected &&
                    !vpnNotifier.isFlashlightInitializedFailed)
                ? offSwitchColor
                : grey3,
            onChanged: (newValue) =>
                vpnProcessForMobile(newValue, vpnStatus, isGoogleAdsEnable),
          );
        });
      });
    } else {
      // This ui for desktop
      return AdvancedSwitch(
        width: 160,
        height: 70,
        borderRadius: BorderRadius.circular(40),
        disabledOpacity: 1,
        enabled: (internetStatusProvider.isConnected &&
            !vpnNotifier.isFlashlightInitializedFailed),
        initialValue: vpnNotifier.vpnStatus.value == 'connected' ||
            vpnNotifier.vpnStatus.value == 'disconnecting',
        activeColor: onSwitchColor,
        inactiveColor: (internetStatusProvider.isConnected &&
                !vpnNotifier.isFlashlightInitializedFailed)
            ? offSwitchColor
            : grey3,
        onChanged: (newValue) {
          final newStatus = newValue ? 'connected' : 'disconnected';
          context.read<VPNChangeNotifier>().vpnStatus.value = newStatus;
          vpnProcessForDesktop(newStatus);
        },
      );
    }
  }

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> vpnProcessForDesktop(String vpnStatus) async {
    bool isConnected = vpnStatus == 'connected';
    if (isConnected) {
      LanternFFI.sysProxyOn();
    } else {
      LanternFFI.sysProxyOff();
    }
  }

  Future<void> vpnProcessForMobile(
      bool newValue, String vpnStatus, bool userHasPermission) async {
    //Make sure user has permission all the permission
    //if ads is not ready then wait for at least 5 seconds and then show ads
    //if ads is ready then show ads immediately

    if (Platform.isAndroid) {
      if (vpnStatus != 'connected' && userHasPermission) {
        if (!await adHelper.isAdsReadyToShow()) {
          await vpnModel.connectingDelay(newValue);
          await Future.delayed(const Duration(seconds: 5));
        }
      }
    }
    await vpnModel.switchVPN(newValue);

    //add delayed to avoid flickering
    if (vpnStatus != 'connected') {
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          await adHelper.showAds();
        },
      );
    }
  }
}
