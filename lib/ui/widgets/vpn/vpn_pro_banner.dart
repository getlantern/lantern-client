import 'dart:ui';

import 'package:lantern/package_store.dart';

class ProBanner extends StatefulWidget {
  @override
  _ProBannerState createState() => _ProBannerState();
}

class _ProBannerState extends State<ProBanner> {
  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
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
}
