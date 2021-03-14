import 'package:flutter/cupertino.dart';
import 'package:lantern/model/vpn_model.dart';
import 'package:lantern/model/vpnmodel.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/hex_color.dart';
import 'package:provider/provider.dart';

class VPNTab extends StatefulWidget {
  VPNTab({Key key}) : super(key: key);

  @override
  _VPNTabState createState() => _VPNTabState();
}

class _VPNTabState extends State<VPNTab> {
  openInfoServerLocation() {
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
            content: Column(
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
                  style:
                      tsSubHead(context).copyWith(fontWeight: FontWeight.w500),
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

  @override
  Widget build(BuildContext context) {
    var model = context.watch<VPNModel>();
    var observableModel = context.watch<VpnModel>();
    return BaseScreen(
      title: 'LANTERN'.i18n,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Opacity(
              opacity: model.dataCap > 0 ? 1 : 0,
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
                            Text(
                              "Go Pro Description".i18n,
                              style: tsCaption(context),
                            ),
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
            ),
            Transform.scale(
              scale: 2,
              child: observableModel.subscribedBuilder("/vpnOn",
                  defaultValue: false,
                  builder: (BuildContext context, bool vpnOn, Widget child) {
                return FlutterSwitch(
                  value: model.vpnOn,
                  activeColor: HexColor(onSwitchColor),
                  inactiveColor: HexColor(offSwitchColor),
                  onToggle: (bool newValue) {
                    if (!model.isLoading) {
                      //prevent to spam
                      model.toggle();
                      observableModel.put("/vpnOn", newValue);
                    }
                  },
                );
              }),
            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lantern".i18n + " " + "is".i18n + ": ",
                        style: tsSubTitle(context).copyWith(
                          color: HexColor(unselectedTabLabelColor),
                        ),
                      ),
                      model.isLoading
                          ? Row(
                              children: [
                                Text(
                                  model.vpnOn
                                      ? "Disconnecting".i18n
                                      : "Connecting".i18n,
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
                              model.vpnOn ? "on".i18n : "off".i18n,
                              style: tsSubTitle(context)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                    ],
                  ),
                  customDivider(marginBottom: 4.0),
                  Row(
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
                            transform:
                                Matrix4.translationValues(-16.0, 0.0, 0.0),
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
                      Text(model.vpnOn ? model.serverLocation : 'N/A',
                          style: tsSubTitle(context)
                              .copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  model.dataCap > 0
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
                                    "${model.bandwidthUsed}/${model.dataCap}MB",
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
                                    flex: model.bandwidthUsed ?? 0,
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
                                    flex: model.dataCap - model.bandwidthUsed,
                                    child: Container(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
