import 'package:flag/flag.dart';
import 'package:lantern/lantern_navigator.dart';
import 'package:lantern/model/session.dart';
import 'package:lantern/model/vpn_model.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/hex_color.dart';
import 'package:provider/provider.dart';

import '../model/protos/vpn.pb.dart';

class VPNTab extends StatelessWidget {
  VPNTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var vpnModel = context.watch<VpnModel>();
    var sessionModel = context.watch<SessionModel>();

    void openInfoServerLocation() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.mapMarkerAlt,
                      size: 20,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Server Location".i18n,
                      style: tsSubHead(context)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 16,
                          bottom: 24,
                        ),
                        child: Text(
                          "Server Location Info".i18n,
                          style: tsSubTitle(context).copyWith(
                            color: HexColor(unselectedTabLabelColor),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Ink(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "OK".i18n,
                            style: tsSubHead(context).copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.pink,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }

    Widget customDivider({marginTop: 16.0, marginBottom: 16.0}) {
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
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HexColor(unselectedTabColor),
            border: Border.all(
              color: HexColor(borderColor),
              width: 1,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                FontAwesomeIcons.crown,
                color: Colors.orange[300],
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Go Pro Title".i18n,
                        style: tsSubHead(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      sessionModel.yinbiEnabled((BuildContext context,
                          bool yinbiEnabled, Widget child) {
                        return Text(
                          yinbiEnabled
                              ? "Go Pro Description With Yinbi".i18n
                              : "Go Pro Description".i18n,
                          style: tsCaption(context),
                        );
                      })
                    ],
                  ),
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                size: 16,
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
            .vpnStatus((BuildContext context, String vpnStatus, Widget child) {
          return FlutterSwitch(
            value: vpnStatus == "connected" || vpnStatus == "disconnecting",
            activeColor: HexColor(onSwitchColor),
            inactiveColor: HexColor(offSwitchColor),
            onToggle: (bool newValue) {
              if (vpnStatus != "connecting" || vpnStatus != "disconnecting") {
                vpnModel.switchVPN(newValue);
              }
            },
          );
        }),
      );
    }

    Widget vpnStatus() {
      return vpnModel
          .vpnStatus((BuildContext context, String vpnStatus, Widget child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "VPN Status".i18n + ": ",
              style: tsSubTitle(context).copyWith(
                color: HexColor(unselectedTabLabelColor),
              ),
            ),
            (vpnStatus == "connecting" || vpnStatus == "disconnecting")
                ? Row(
                    children: [
                      Text(
                        (vpnStatus == "connecting")
                            ? "Connecting".i18n
                            : "Disconnecting".i18n,
                        style: tsSubTitle(context)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Padding(
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
                    (vpnStatus == "connected") ? "on".i18n : "off".i18n,
                    style: tsSubTitle(context)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
          ],
        );
      });
    }

    Widget bandwidth() {
      return vpnModel
          .bandwidth((BuildContext context, Bandwidth bandwidth, Widget child) {
        return bandwidth.allowed > 0
            ? Column(
                children: [
                  customDivider(marginTop: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Daily Data Usage".i18n + ": ",
                        style: tsSubTitle(context).copyWith(
                          color: HexColor(unselectedTabLabelColor),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${bandwidth.allowed - bandwidth.remaining}/${bandwidth.allowed} MB",
                          textAlign: TextAlign.end,
                          style: tsSubTitle(context)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
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
                      borderRadius: BorderRadius.all(
                        Radius.circular(borderRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: (bandwidth.allowed - bandwidth.remaining)
                                  .toInt() ??
                              0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: HexColor(usedDataBarColor),
                              borderRadius: BorderRadius.all(
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
                "Server Location".i18n + ": ",
                style: tsSubTitle(context).copyWith(
                  color: HexColor(unselectedTabLabelColor),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(-16.0, 0.0, 0.0),
                child: InkWell(
                  child: Container(
                    height: 48,
                    width: 48,
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: HexColor(unselectedTabLabelColor),
                      size: 16,
                    ),
                  ),
                  onTap: openInfoServerLocation,
                ),
              ),
            ],
          ),
          vpnModel.vpnStatus(
              (BuildContext context, String vpnStatus, Widget child) {
            return vpnModel.serverInfo(
                (BuildContext context, ServerInfo serverInfo, Widget child) {
              if (vpnStatus == "connected" || vpnStatus == "disconnecting") {
                return Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        child: Flag(serverInfo.countryCode,
                            height: 24, width: 36)),
                    SizedBox(width: 12),
                    Text(serverInfo.city,
                        style: tsSubTitle(context)
                            .copyWith(fontWeight: FontWeight.bold))
                  ],
                );
              } else {
                return Text('N/A',
                    style: tsSubTitle(context)
                        .copyWith(fontWeight: FontWeight.bold));
              }
            });
          }),
        ],
      );
    }

    return sessionModel
        .proUser((BuildContext context, bool proUser, Widget child) {
      return BaseScreen(
        title: proUser ? 'LANTERN PRO' : 'LANTERN',
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              proUser ? Container() : proBanner(),
              vpnSwitch(),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: HexColor(borderColor),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(borderRadius),
                  ),
                ),
                child: Column(
                  children: [
                    vpnStatus(),
                    customDivider(marginBottom: 4.0),
                    serverLocation(),
                    bandwidth(),
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
