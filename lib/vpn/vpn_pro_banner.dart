import 'package:lantern/vpn/vpn.dart';

class ProBanner extends StatefulWidget {
  final bool isCN;
  final bool isPlatinum;

  ProBanner({Key? key, required this.isCN, required this.isPlatinum})
      : super(key: key);

  @override
  _ProBannerState createState() => _ProBannerState();
}

class _ProBannerState extends State<ProBanner> {
  @override
  Widget build(BuildContext context) {
    return sessionModel.getCachedUserStatus(
      (context, userStatus, child) => CInkWell(
        onTap: () async {
          context.loaderOverlay.show();
          await sessionModel.updateAndCachePlans().then((value) async {
            context.loaderOverlay.hide();
            await context.pushRoute(
              Upgrade(
                isCN: widget.isCN,
                isPlatinum: widget.isPlatinum,
                isPro: userStatus == 'pro',
              ),
            );
          }).onError(
            (error, stackTrace) {
              context.loaderOverlay.hide();
              CDialog.showError(
                context,
                error: e,
                stackTrace: stackTrace,
                // TODO: Display this as dev, localize for production
                description: (error as PlatformException).message.toString(),
              );
            },
          );
        }, // Handle your callback
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
                      sessionModel
                          .getCachedUserStatus((context, userStatus, child) {
                        final isPro = userStatus == 'pro';
                        return CText(
                          'Upgrade ${widget.isCN ? isPro ? 'to Platinum' : '' : 'to Pro'}'
                              .i18n, // TODO: translations
                          style: tsSubtitle2,
                        );
                      }),
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
      ),
    );
  }
}
