import 'package:lantern/features/vpn/vpn.dart';

class VPNBandwidth extends StatelessWidget {
  const VPNBandwidth({super.key});

  @override
  Widget build(BuildContext context) {
    return sessionModel
        .bandwidth((BuildContext context, Bandwidth bandwidth, Widget? child) {
      // User does not have bandwidth cap off
      if (bandwidth.remaining > 0) {
        if (bandwidth.percent.isZero) bandwidth.percent = bandwidth.remaining;
        return Column(
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(
                top: 4.0,
                bottom: 16.0,
              ),
              child: const CDivider(height: 10),
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
            const SizedBox(height: 8),
            Container(
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
              child: LinearProgressIndicator(
                value: (bandwidth.percent.toDouble() / 100).toDouble(),
                minHeight: 12,
                borderRadius:
                    const BorderRadius.all(Radius.circular(borderRadius)),
                backgroundColor: unselectedTabColor,
                valueColor: AlwaysStoppedAnimation(usedDataBarColor),
              ),
            ),
          ],
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
