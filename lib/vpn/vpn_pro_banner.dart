import 'package:lantern/account/plans/plan_utils.dart';
import 'package:lantern/vpn/vpn.dart';

class ProBanner extends StatefulWidget {
  final bool isPlatinum;

  ProBanner({
    Key? key,
    required this.isPlatinum,
  }) : super(key: key);

  @override
  _ProBannerState createState() => _ProBannerState();
}

class _ProBannerState extends State<ProBanner> {
  @override
  Widget build(BuildContext context) {
    return sessionModel.getIsPro(
      (context, isPro, child) => CInkWell(
        onTap: () async {
          context.loaderOverlay.show();
          await sessionModel
              .updateAndCachePlans()
              .timeout(
                defaultTimeoutDuration,
                onTimeout: () => onAPIcallTimeout(
                  code: 'updateAndCachePlansTimeout',
                  message: 'update_cache_plans_timeout'.i18n,
                ),
              )
              .then((value) async {
            context.loaderOverlay.hide();
            await context.pushRoute(
              Upgrade(
                isPro: isPro,
              ),
            );
          }).onError((error, stackTrace) {
            context.loaderOverlay.hide();
            CDialog.showError(
              context,
              error: e,
              stackTrace: stackTrace,
              description: localizeCachingError(error),
            );
          });
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
                      sessionModel.getIsPro(
                        (context, isPro, child) => sessionModel
                            .getCachedPlans((context, cachedPlans, child) {
                          final platinumAvailable =
                              isPlatinumAvailable(cachedPlans);
                          return CText(
                            'Upgrade ${platinumAvailable ? isPro ? 'to Lantern Platinum' : '' : 'to Lantern Pro'}'
                                .i18n,
                            style: tsSubtitle2,
                          );
                        }),
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
      ),
    );
  }
}
