import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging_model.dart';

import 'plans/plan_utils.dart';

class AccountMenu extends StatelessWidget {
  final bool platinumAvailable;
  final bool isPlatinum;

  AccountMenu(
      {Key? key, required this.platinumAvailable, required this.isPlatinum})
      : super(key: key);

  Future<void> upgradeToLanternPro(
    BuildContext context,
    bool isPro,
  ) async {
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
  }

  Future<void> authorizeDeviceForPro(BuildContext context) async =>
      await context.pushRoute(AuthorizePro());

  // TODO: migrate to Flutter
  void inviteFriends() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_INVITE_FRIEND);

  // TODO: migrate to Flutter
  void openDesktopVersion() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_DESKTOP_VERSION);

  void openSettings(BuildContext context) async =>
      await context.pushRoute(Settings());

  List<Widget> freeItems(BuildContext context, SessionModel sessionModel) {
    return [
      messagingModel.getOnBoardingStatus(
        (context, hasBeenOnboarded, child) => hasBeenOnboarded == true
            ? messagingModel.getCopiedRecoveryStatus(
                (
                  BuildContext context,
                  bool hasCopiedRecoveryKey,
                  Widget? child,
                ) =>
                    sessionModel.getIsPro((context, isPro, child) {
                  return ListItemFactory.settingsItem(
                    icon: ImagePaths.account,
                    content: 'account_management'.i18n,
                    onTap: () async => await context.pushRoute(
                      AccountManagement(
                        isPro: isPro,
                        platinumAvailable: platinumAvailable,
                        isPlatinum: isPlatinum,
                      ),
                    ),
                    trailingArray: [
                      if (!hasCopiedRecoveryKey)
                        const CAssetImage(
                          path: ImagePaths.badge,
                        ),
                    ],
                  );
                }),
              )
            : const SizedBox(),
      ),
      if (!isPlatinum)
        sessionModel.getIsPro((context, isPro, child) {
          return ListItemFactory.settingsItem(
            icon: ImagePaths.pro_icon_black,
            content:
                '${platinumAvailable ? 'Upgrade ${isPro ? 'to Lantern Platinum' : ''}' : 'Upgrade to Lantern Pro'}'
                    .i18n,
            onTap: () => upgradeToLanternPro(context, isPro),
          );
        }),
      ListItemFactory.settingsItem(
        icon: ImagePaths.star,
        content: 'Invite Friends'.i18n,
        onTap: inviteFriends,
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.desktop,
        content: 'desktop_version'.i18n,
        onTap: openDesktopVersion,
      ),
      sessionModel
          .getIsPro((context, isPro, child) => ListItemFactory.settingsItem(
                icon: ImagePaths.devices,
                content: isPlatinum || isPro
                    ? 'Link Device'.i18n
                    : 'Authorize Device for Pro'.i18n,
                onTap: () {
                  authorizeDeviceForPro(context);
                },
              )),
      ListItemFactory.settingsItem(
        icon: ImagePaths.settings,
        content: 'settings'.i18n,
        onTap: () {
          openSettings(context);
        },
      ),
    ];
  }

  List<Widget> proItems(BuildContext context) {
    return [
      messagingModel.getOnBoardingStatus(
        (context, hasBeenOnboarded, child) =>
            messagingModel.getCopiedRecoveryStatus(
          (BuildContext context, bool hasCopiedRecoveryKey, Widget? child) =>
              sessionModel.getIsPro(
            (context, isPro, child) => ListItemFactory.settingsItem(
              icon: ImagePaths.account,
              content: 'account_management'.i18n,
              onTap: () async => await context.pushRoute(
                AccountManagement(
                  isPro: isPro,
                  platinumAvailable: platinumAvailable,
                  isPlatinum: isPlatinum,
                ),
              ),
              trailingArray: [
                if (!hasCopiedRecoveryKey && hasBeenOnboarded == true)
                  const CAssetImage(
                    path: ImagePaths.badge,
                  ),
              ],
            ),
          ),
        ),
      ),
      sessionModel.getIsPro((context, isPro, child) {
        // Show Upgrade option if we are
        // - in China and not Platinum
        // - not in China and not Pro
        final showUpgradeOption = (platinumAvailable && !isPlatinum) ||
            (!platinumAvailable && !isPro);
        return showUpgradeOption
            ? ListItemFactory.settingsItem(
                icon: ImagePaths.pro_icon_black,
                content:
                    '${platinumAvailable ? 'Upgrade ${isPro ? 'to Lantern Platinum' : ''}' : 'Upgrade to Lantern Pro'}'
                        .i18n,
                onTap: () => upgradeToLanternPro(context, isPro),
              )
            : Container();
      }),
      ListItemFactory.settingsItem(
        icon: ImagePaths.devices,
        content: 'Link Device'.i18n,
        onTap: () async => await context.pushRoute(ApproveDevice()),
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.star,
        content: 'Invite Friends'.i18n,
        onTap: inviteFriends,
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.desktop,
        content: 'desktop_version'.i18n,
        onTap: openDesktopVersion,
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.settings,
        content: 'settings'.i18n,
        onTap: () {
          openSettings(context);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Account'.i18n,
      body: sessionModel
          .getIsPro((BuildContext sessionContext, bool isPro, Widget? child) {
        return ListView(
          children: isPro
              ? proItems(sessionContext)
              : freeItems(sessionContext, sessionModel),
        );
      }),
    );
  }
}
