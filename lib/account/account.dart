import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging_model.dart';

import 'plans/constants.dart';

class AccountMenu extends StatelessWidget {
  final bool isCN;
  final bool isPlatinum;

  AccountMenu({Key? key, required this.isCN, required this.isPlatinum})
      : super(key: key);

  Future<void> upgradeToLanternPro(
      BuildContext context, bool isPro, List<Map<String, Object>> plans) async {
    await context.pushRoute(
      Upgrade(
        plans: plans,
        isCN: isCN,
        isPlatinum: isPlatinum,
        isPro: isPro,
      ),
    );
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
                    sessionModel.getUserStatus((context, userStatus, child) {
                  final isPro = userStatus == 'pro';
                  return ListItemFactory.settingsItem(
                    icon: ImagePaths.account,
                    content: 'account_management'.i18n,
                    onTap: () async => await context.pushRoute(
                      AccountManagement(
                        isPro: isPro,
                        isCN: isCN,
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
        sessionModel.getUserStatus((context, userStatus, child) {
          final isPro = userStatus == 'pro';
          return sessionModel.getCachedPlans((context, cachedPlans, child) {
            final plans = formatCachedPlans(cachedPlans);
            if (plans.isEmpty) {
              handlePlansFailure(context);
            }

            return ListItemFactory.settingsItem(
              icon: ImagePaths.pro_icon_black,
              content:
                  '${isCN ? 'Upgrade ${isPro ? 'to Platinum' : ''}' : 'Upgrade to Lantern Pro'}'
                      .i18n, // TODO: translations
              onTap: () => upgradeToLanternPro(context, isPro, plans),
            );
          });
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
      ListItemFactory.settingsItem(
        icon: ImagePaths.devices,
        content: 'Authorize Device for Pro'.i18n,
        onTap: () {
          authorizeDeviceForPro(context);
        },
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

  List<Widget> proItems(BuildContext context) {
    return [
      messagingModel.getOnBoardingStatus(
        (context, hasBeenOnboarded, child) =>
            messagingModel.getCopiedRecoveryStatus(
          (BuildContext context, bool hasCopiedRecoveryKey, Widget? child) =>
              ListItemFactory.settingsItem(
            icon: ImagePaths.account,
            content: 'account_management'.i18n,
            onTap: () async => await context.pushRoute(AccountManagement(
                isPro: true, isCN: isCN, isPlatinum: isPlatinum)),
            trailingArray: [
              if (!hasCopiedRecoveryKey && hasBeenOnboarded == true)
                const CAssetImage(
                  path: ImagePaths.badge,
                ),
            ],
          ),
        ),
      ),
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
          .proUser((BuildContext sessionContext, bool proUser, Widget? child) {
        return ListView(
          children: proUser
              ? proItems(sessionContext)
              : freeItems(sessionContext, sessionModel),
        );
      }),
    );
  }
}
