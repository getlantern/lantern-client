import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

class AccountMenu extends StatelessWidget {
  AccountMenu({Key? key}) : super(key: key);

  void upgradeToLanternPro() => LanternNavigator.startScreen(
      LanternNavigator.SCREEN_UPGRADE_TO_LANTERN_PRO);

  Future<void> authorizeDeviceForPro(BuildContext context) async =>
      await context.pushRoute(AuthorizePro());

  void inviteFriends() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_INVITE_FRIEND);

  void openDesktopVersion() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_DESKTOP_VERSION);

  void openSettings(BuildContext context) async =>
      await context.pushRoute(Settings());

  List<Widget> freeItems(
      BuildContext context, SessionModel sessionModel, Contact me) {
    final messagingModel = context.watch<MessagingModel>();
    return [
      messagingModel.getOnBoardingStatus((context, hasBeenOnboarded, child) =>
          hasBeenOnboarded
              ? messagingModel.getCopiedRecoveryStatus((BuildContext context,
                      bool hasCopiedRecoveryKey, Widget? child) =>
                  ListItemFactory.settingsItem(
                      icon: ImagePaths.account,
                      content: 'Account Management'.i18n,
                      onTap: () async => await context
                          .pushRoute(AccountManagement(isPro: false)),
                      trailingArray: [
                        if (!hasCopiedRecoveryKey)
                          const CAssetImage(
                            path: ImagePaths.badge,
                          ),
                      ]))
              : const SizedBox()),
      ListItemFactory.settingsItem(
        icon: ImagePaths.pro_icon_black,
        content: 'Upgrade to Lantern Pro'.i18n,
        onTap: upgradeToLanternPro,
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

  List<Widget> proItems(BuildContext context, Contact me) {
    final messagingModel = context.watch<MessagingModel>();
    return [
      messagingModel.getOnBoardingStatus((context, hasBeenOnboarded, child) =>
          messagingModel.getCopiedRecoveryStatus((BuildContext context,
                  bool hasCopiedRecoveryKey, Widget? child) =>
              ListItemFactory.settingsItem(
                  icon: ImagePaths.account,
                  content: 'Account Management'.i18n,
                  onTap: () async =>
                      await context.pushRoute(AccountManagement(isPro: true)),
                  trailingArray: [
                    if (!hasCopiedRecoveryKey && hasBeenOnboarded)
                      const CAssetImage(
                        path: ImagePaths.badge,
                      ),
                  ]))),
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
    var sessionModel = context.watch<SessionModel>();
    var messagingModel = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'Account'.i18n,
      body: sessionModel
          .proUser((BuildContext context, bool proUser, Widget? child) {
        return messagingModel
            .me((BuildContext context, Contact me, Widget? child) {
          return ListView(
            children: proUser
                ? proItems(context, me)
                : freeItems(context, sessionModel, me),
          );
        });
      }),
    );
  }
}
