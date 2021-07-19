import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';

import 'settings_item.dart';

class AccountMenu extends StatelessWidget {
  AccountMenu({Key? key}) : super(key: key);

  void upgradeToLanternPro() => LanternNavigator.startScreen(
      LanternNavigator.SCREEN_UPGRADE_TO_LANTERN_PRO);

  Future<void> authorizeDeviceForPro(BuildContext context) async =>
      await context.pushRoute(ProAccount());

  void inviteFriends() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_INVITE_FRIEND);

  void openDesktopVersion() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_DESKTOP_VERSION);

  void openFreeYinbiCrypto() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_FREE_YINBI);
  }

  void openYinbiRedemption() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_YINBI_REDEMPTION);

  void openSettings(BuildContext context) async =>
      await context.pushRoute(Settings());

  void openContacts(BuildContext context) async =>
      await context.pushRoute(const Contacts());

  List<Widget> freeItems(BuildContext context, SessionModel sessionModel) {
    return [
      SettingsItem(
        icon: ImagePaths.crown_icon_monochrome,
        title: 'upgrade_to_lantern_pro'.i18n,
        onTap: upgradeToLanternPro,
      ),
      SettingsItem(
        icon: ImagePaths.contacts_icon,
        title: 'Contacts'.i18n,
        onTap: () => openContacts(context),
      ),
      SettingsItem(
        icon: ImagePaths.devices_icon,
        title: 'authorize_device_for_pro'.i18n,
        onTap: () {
          authorizeDeviceForPro(context);
        },
      ),
      SettingsItem(
        icon: ImagePaths.star_icon,
        title: 'invite_friends'.i18n,
        onTap: inviteFriends,
      ),
      SettingsItem(
        icon: ImagePaths.desktop_icon,
        title: 'desktop_version'.i18n,
        onTap: openDesktopVersion,
      ),
      sessionModel.shouldShowYinbiBadge(
        (BuildContext context, bool shouldShowYinbiBadge, Widget? child) =>
            SettingsItem(
          icon: ImagePaths.yinbi_icon,
          title: 'free_yinbi_crypto'.i18n,
          onTap: openFreeYinbiCrypto,
          child: CustomBadge(
            count: 1,
            fontSize: 14,
            showBadge: shouldShowYinbiBadge,
          ),
        ),
      ),
      SettingsItem(
        icon: ImagePaths.settings_icon,
        title: 'settings'.i18n,
        onTap: () {
          openSettings(context);
        },
      ),
    ];
  }

  List<Widget> proItems(BuildContext context) => [
        SettingsItem(
          icon: ImagePaths.account_icon,
          iconColor: Colors.black,
          title: 'pro_account_management'.i18n,
          onTap: () async => await context.pushRoute(ProAccount()),
        ),
        SettingsItem(
          icon: ImagePaths.devices_icon,
          title: 'add_device'.i18n,
          onTap: () async => await context.pushRoute(ApproveDevice()),
        ),
        SettingsItem(
          icon: ImagePaths.star_icon,
          title: 'invite_friends'.i18n,
          onTap: inviteFriends,
        ),
        SettingsItem(
          icon: ImagePaths.desktop_icon,
          title: 'desktop_version'.i18n,
          onTap: openDesktopVersion,
        ),
        SettingsItem(
          icon: ImagePaths.yinbi_icon,
          title: 'yinbi_redemption'.i18n,
          onTap: openYinbiRedemption,
        ),
        SettingsItem(
          icon: ImagePaths.settings_icon,
          title: 'settings'.i18n,
          onTap: () {
            openSettings(context);
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'Account'.i18n,
      body: sessionModel
          .proUser((BuildContext context, bool proUser, Widget? child) {
        return ListView(
          padding: const EdgeInsetsDirectional.only(top: 2, start: 20, end: 20),
          children:
              proUser ? proItems(context) : freeItems(context, sessionModel),
        );
      }),
    );
  }
}
