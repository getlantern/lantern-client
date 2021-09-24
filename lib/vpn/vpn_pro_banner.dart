import 'package:lantern/vpn/vpn.dart';

class ProBanner extends StatefulWidget {
  @override
  _ProBannerState createState() => _ProBannerState();
}

class _ProBannerState extends State<ProBanner> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // TODO make InkWell ripple effect works with BoxDecoration
      onTap: () {
        LanternNavigator.startScreen(LanternNavigator.SCREEN_PLANS);
      }, // Handle your callback
      child: Container(
        padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CAssetImage(
              path: ImagePaths.pro_icon_yellow,
              size: 32,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CText(
                      'Go Pro Title'.i18n,
                      style: tsSubtitle2,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    CText(
                      'Go Pro Description'.i18n,
                      style: tsBody2,
                    ),
                  ],
                ),
              ),
            ),
            const ContinueArrow(),
          ],
        ),
      ),
    );
  }
}
