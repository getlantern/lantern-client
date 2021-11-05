import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/account.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import 'settings_item.dart';

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
    return [
      // TODO: adding this here since I can't make myself Pro on LG
      SettingsItem(
          icon: ImagePaths.account,
          iconColor: Colors.black,
          title: 'Account Management'.i18n,
          onTap: () async => await context.pushRoute(ProAccount()),
          child: CBadge(
            // TODO: if has not copied key
            showBadge: true,
            count: 1,
          )),
      SettingsItem(
        icon: ImagePaths.pro_icon_black,
        title: 'Upgrade to Lantern Pro'.i18n,
        onTap: upgradeToLanternPro,
      ),
      SettingsItem(
        icon: ImagePaths.devices,
        title: 'Authorize Device for Pro'.i18n,
        onTap: () {
          authorizeDeviceForPro(context);
        },
      ),
      SettingsItem(
        icon: ImagePaths.star,
        title: 'Invite Friends'.i18n,
        onTap: inviteFriends,
      ),
      SettingsItem(
        icon: ImagePaths.desktop,
        title: 'desktop_version'.i18n,
        onTap: openDesktopVersion,
      ),
      SettingsItem(
        icon: ImagePaths.settings,
        title: 'settings'.i18n,
        onTap: () {
          openSettings(context);
        },
      ),
    ];
  }

  List<Widget> proItems(BuildContext context, Contact me) => [
        SettingsItem(
            icon: ImagePaths.account,
            iconColor: Colors.black,
            title: 'Pro Account Management'.i18n,
            onTap: () async => await context.pushRoute(ProAccount()),
            child: CBadge(
              // TODO: if has not copied key
              showBadge: true,
              count: 1,
            )),
        SettingsItem(
          icon: ImagePaths.devices,
          title: 'Add Device'.i18n,
          onTap: () async => await context.pushRoute(ApproveDevice()),
        ),
        SettingsItem(
          icon: ImagePaths.star,
          title: 'Invite Friends'.i18n,
          onTap: inviteFriends,
        ),
        SettingsItem(
          icon: ImagePaths.desktop,
          title: 'desktop_version'.i18n,
          onTap: openDesktopVersion,
        ),
        SettingsItem(
          icon: ImagePaths.settings,
          title: 'settings'.i18n,
          onTap: () {
            openSettings(context);
          },
        ),
      ];

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
