import 'package:lantern/account/plans/constants.dart';
import 'package:lantern/vpn/vpn.dart';

class ProBanner extends StatefulWidget {
  @override
  _ProBannerState createState() => _ProBannerState();
}

class _ProBannerState extends State<ProBanner> {
  @override
  Widget build(BuildContext context) {
    return CInkWell(
      onTap: () async =>
          await context.pushRoute(Upgrade()), // Handle your callback
      child: Container(
        padding: const EdgeInsetsDirectional.all(16),
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
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CText(
                      'Upgrade ${isCN ? isPro ? 'to Platinum' : '' : 'to Pro'}'
                          .i18n, // TODO: translations
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
            mirrorLTR(context: context, child: const ContinueArrow()),
          ],
        ),
      ),
    );
  }
}
