import 'dart:ui';

import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/continue_arrow.dart';

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
            const CustomAssetImage(
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
                    Text(
                      'Go Pro Description'.i18n,
                      style: tsCaption(context),
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
