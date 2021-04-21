import 'package:lantern/package_store.dart';
import 'package:flag/flag.dart';
import 'package:lantern/lantern_navigator.dart';
import 'package:lantern/model/session_model.dart';
import 'package:lantern/model/vpn_model.dart';
import 'package:lantern/utils/hex_color.dart';
import 'package:provider/provider.dart';

import '../model/protos_shared/vpn.pb.dart';

class VPNTab extends StatelessWidget {
  VPNTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var vpnModel = context.watch<VpnModel>();
    var sessionModel = context.watch<SessionModel>();

    openInfoServerLocation() {
      showInfoDialog(
        context,
        title: 'Server Location'.i18n,
        des: 'Server Location Info'.i18n,
        icon: ImagePaths.location_on_icon,
      );
    }

    Widget customDivider({marginTop = 16.0, marginBottom = 16.0}) {
      return Container(
        margin: EdgeInsets.only(top: marginTop, bottom: marginBottom),
        height: 1,
        width: double.infinity,
        color: HexColor(borderColor),
      );
    }

    Widget proBanner() {
      return InkWell(
        // TODO make InkWell ripple effect works with BoxDecoration
        onTap: () {
          LanternNavigator.startScreen(LanternNavigator.SCREEN_PLANS);
        }, // Handle your callback
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HexColor(unselectedTabColor),
            border: Border.all(
              color: HexColor(borderColor),
              width: 1,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(borderRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomAssetImage(
                path: ImagePaths.crown_icon,
                size: 32,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Go Pro Title'.i18n,
                        style: tsSubHead(context)?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      sessionModel.yinbiEnabled((BuildContext context,
                          bool yinbiEnabled, Widget? child) {
                        return Text(
                          yinbiEnabled
                              ? 'Go Pro Description With Yinbi'.i18n
                              : 'Go Pro Description'.i18n,
                          style: tsCaption(context),
                        );
                      })
                    ],
                  ),
                ),
              ),
              const CustomAssetImage(
                path: ImagePaths.keyboard_arrow_right_icon,
                size: 24,
              ),
            ],
          ),
        ),
      );
    }

    Widget vpnSwitch() {
      return Transform.scale(
        scale: 2,
        child: vpnModel
            .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
          return FlutterSwitch(
            value: vpnStatus == 'connected' || vpnStatus == 'disconnecting',
            activeColor: HexColor(onSwitchColor),
            inactiveColor: HexColor(offSwitchColor),
            onToggle: (bool newValue) {
              if (vpnStatus != 'connecting' || vpnStatus != 'disconnecting') {
                vpnModel.switchVPN(newValue);
              }
            },
          );
        }),
      );
    }

    Widget vpnStatus() {
      return vpnModel
          .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VPN Status'.i18n + ': ',
              style: tsSubTitle(context)?.copyWith(
                color: HexColor(unselectedTabLabelColor),
              ),
            ),
            (vpnStatus == 'connecting' || vpnStatus == 'disconnecting')
                ? Row(
              children: [
                Text(
                  (vpnStatus == 'connecting')
                      ? 'Connecting'.i18n
                      : 'Disconnecting'.i18n,
                  style: tsSubTitle(context)
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ],
            )
                : Text(
              (vpnStatus == 'connected') ? 'on'.i18n : 'off'.i18n,
              style: tsTitleTrailVPNItem(),
            ),
          ],
        );
      });
    }

    Widget bandwidthWidget() {
      return vpnModel.bandwidth((BuildContext context, Bandwidth bandwidth,
          Widget? child) {
        return bandwidth.allowed > 0
            ? Column(
          children: [
            customDivider(marginTop: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Data Usage'.i18n + ': ',
                  style: tsTitleHeadVPNItem()?.copyWith(
                    color: HexColor(unselectedTabLabelColor),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${bandwidth.allowed - bandwidth.remaining}/${bandwidth.allowed} MB',
                    textAlign: TextAlign.end,
                    style: tsTitleTrailVPNItem(),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: HexColor(unselectedTabColor),
                border: Border.all(
                  color: HexColor(borderColor),
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (bandwidth.allowed - bandwidth.remaining).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: HexColor(usedDataBarColor),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(borderRadius),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: bandwidth.remaining.toInt(),
                    child: Container(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        )
            : Container();
      });
    }

    Widget serverLocation() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Server Location'.i18n + ': ',
                style: tsTitleHeadVPNItem()?.copyWith(
                  color: HexColor(unselectedTabLabelColor),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(-16.0, 0.0, 0.0),
                child: InkWell(
                  onTap: openInfoServerLocation,
                  child: Container(
                    height: 48,
                    width: 48,
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: HexColor(unselectedTabLabelColor),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          vpnModel.vpnStatus((BuildContext context, String vpnStatus,
              Widget? child) {
            return vpnModel.serverInfo((BuildContext context,
                ServerInfo serverInfo, Widget? child) {
              if (vpnStatus == 'connected' || vpnStatus == 'disconnecting') {
                return Row(
                  children: [
                    ClipRRect(borderRadius: const BorderRadius.all(Radius
                        .circular(4)), child: Flag(serverInfo.countryCode,
                        height: 24, width: 36)),
                    const SizedBox(width: 12),
                    Text(
                      serverInfo.city,
                      style: tsTitleTrailVPNItem(),
                    )
                  ],
                );
              } else {
                return Text(
                  'N/A',
                  style: tsTitleTrailVPNItem(),
                );
              }
            });
          }),
        ],
      );
    }

    return sessionModel.proUser((BuildContext context, bool proUser,
        Widget? child) {
      return
        BaseScreen(
          logoTitle: proUser ? ImagePaths.pro_logo : ImagePaths.free_logo,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                proUser ? Container() : proBanner(),
                vpnSwitch(),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: HexColor(borderColor),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                  ),
                  child: Column(
                    children: [
                      vpnStatus(),
                      customDivider(marginBottom: 4.0),
                      serverLocation(),
                      bandwidthWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    });
  }
}