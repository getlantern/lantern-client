import 'package:lantern/account/split_tunneling.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/vpn/vpn_notifier.dart';
import 'package:shimmer/shimmer.dart';

import '../common/ui/custom/internet_checker.dart';
import 'vpn_bandwidth.dart';
import 'vpn_pro_banner.dart';
import 'vpn_server_location.dart';
import 'vpn_status.dart';
import 'vpn_switch.dart';

class VPNTab extends StatelessWidget {
  const VPNTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vpnNotifier = context.watch<VPNChangeNotifier>();
    return sessionModel
        .proUser((BuildContext context, bool proUser, Widget? child) {
      return BaseScreen(
        title: SvgPicture.asset(
          proUser ? ImagePaths.pro_logo : ImagePaths.free_logo,
          height: 16,
          fit: BoxFit.contain,
        ),
        // make sure to disable the back arrow button on the home screen
        automaticallyImplyLeading: false,
        padVertical: true,
        body: !vpnNotifier.isFlashlightInitialized
            ? VPNTapSkeleton(
                isProUser: proUser,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (!proUser && !Platform.isIOS)
                    const ProBanner()
                  else
                    const SizedBox(height: 50),
                  const SizedBox(height: 100),
                  const VPNSwitch(),
                  const SizedBox(height: 40),
                  if (vpnNotifier.isFlashlightInitializedFailed)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CText(vpnNotifier.flashlightState, style: tsSubtitle2),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: grey5,
                          ),
                        )
                      ],
                    ),
                  const SizedBox(height: 50),
                  Consumer<InternetStatusProvider>(
                    builder: (context, provider, _) {
                      return provider.isConnected
                          ? const SizedBox()
                          : const InternetChecker();
                    },
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsetsDirectional.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(borderRadius),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VPNStatus(),
                        const CDivider(height: 32.0),
                        ServerLocationWidget(),
                        if (Platform.isAndroid) ...{
                          const CDivider(height: 32.0),
                          SplitTunnelingWidget(),
                          if (!proUser) const VPNBandwidth(),
                        }
                      ],
                    ),
                  ),
                ],
              ),
      );
    });
  }
}

class VPNTapSkeleton extends StatelessWidget {
  final bool isProUser;

  const VPNTapSkeleton({
    super.key,
    required this.isProUser,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade100,
      highlightColor: Colors.grey.shade200,
      enabled: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (!isProUser) const ProBanner() else const SizedBox(height: 50),
          const VPNSwitch(),
          Container(
            padding: const EdgeInsetsDirectional.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(borderRadius),
              ),
            ),
            child: Column(
              children: <Widget>[
                buildRow(),
                const SizedBox(height: 20),
                buildRow(),
                const SizedBox(height: 20),
                buildRow(),
                if (Platform.isAndroid) ...{
                  const SizedBox(height: 20),
                  buildRow(),
                }
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
