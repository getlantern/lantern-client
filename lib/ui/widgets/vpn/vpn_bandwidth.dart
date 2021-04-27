import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/vpn/vpn_custom_divider.dart';

class VPNBandwidth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var vpnModel = context.watch<VpnModel>();
    return vpnModel
        .bandwidth((BuildContext context, Bandwidth bandwidth, Widget? child) {
      return bandwidth.allowed > 0
          ? Column(
              children: [
                VPNCustomDivider(marginTop: 4.0),
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
}
