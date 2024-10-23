// SplitTunnelingWidget is the split tunneling widget that appears on the main VPN screen
import '../utils/common.dart';

class SplitTunnelingWidget extends StatelessWidget {
  const SplitTunnelingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return sessionModel.splitTunneling(
      (BuildContext context, bool value, Widget? child) => InkWell(
        onTap: () {
          appRouter.push(const SplitTunneling());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CText(
              'split_tunneling'.i18n,
              style: tsSubtitle3.copiedWith(
                color: unselectedTabIconColor,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: CText(
                value ? 'on'.i18n : 'off'.i18n,
                style: tsSubtitle4,
              ),
            ),
            const ContinueArrow(),
          ],
        ),
      ),
    );
  }
}
