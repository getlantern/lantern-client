import 'package:lantern/vpn/vpn.dart';

class VPNBandwidth extends StatelessWidget {
  const VPNBandwidth({super.key});

  @override
  Widget build(BuildContext context) {
    return vpnModel
        .bandwidth((BuildContext context, Bandwidth? bandwidth, Widget? child) {
      return (bandwidth != null && bandwidth.allowed > 0)
          ? Column(
              children: [
                Container(
                  margin: const EdgeInsetsDirectional.only(
                    top: 4.0,
                    bottom: 16.0,
                  ),
                  child: const CDivider(height: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CText(
                      'Daily Data Usage'.i18n,
                      style: tsSubtitle3.copiedWith(
                        color: unselectedTabIconColor,
                      ),
                    ),
                    Expanded(
                      child: CText(
                        '${bandwidth.remaining}/${bandwidth.allowed} MB',
                        textAlign: TextAlign.end,
                        style: tsSubtitle4,
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
                    color: unselectedTabColor,
                    border: Border.all(
                      color: borderColor,
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
                            color: usedDataBarColor,
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
                const SizedBox(
                  height: 16,
                ),
              ],
            )
          : Container();
    });
  }
}
