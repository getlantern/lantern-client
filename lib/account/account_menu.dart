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

  void openDisplayName(BuildContext context, Contact me) async {
    await context.pushRoute(DisplayName(me: me));
  }

  List<Widget> freeItems(
      BuildContext context, SessionModel sessionModel, Contact me) {
    return [
      SettingsItem(
        icon: ImagePaths.pro_icon_black,
        title: 'upgrade_to_lantern_pro'.i18n,
        onTap: upgradeToLanternPro,
      ),
      SettingsItem(
        icon: ImagePaths.devices,
        title: 'authorize_device_pro'.i18n,
        onTap: () {
          authorizeDeviceForPro(context);
        },
      ),
      SettingsItem(
        icon: ImagePaths.star,
        title: 'invite_friends'.i18n,
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
      SettingsItem(
        icon: ImagePaths.account,
        title: 'display_name'.i18n.fill([me.displayName]),
        onTap: () {
          openDisplayName(context, me);
        },
      ),
    ];
  }

  List<Widget> proItems(BuildContext context, Contact me) => [
        SettingsItem(
          icon: ImagePaths.account,
          iconColor: Colors.black,
          title: 'pro_account_management'.i18n,
          onTap: () async => await context.pushRoute(ProAccount()),
        ),
        SettingsItem(
          icon: ImagePaths.devices,
          title: 'add_device'.i18n,
          onTap: () async => await context.pushRoute(ApproveDevice()),
        ),
        SettingsItem(
          icon: ImagePaths.star,
          title: 'invite_friends'.i18n,
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
        SettingsItem(
          icon: ImagePaths.account,
          title: 'display_name'.i18n.fill([me.displayName]),
          onTap: () {
            openDisplayName(context, me);
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
    var messagingModel = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'account'.i18n,
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
