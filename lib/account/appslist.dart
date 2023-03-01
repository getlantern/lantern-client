import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';

class AppsList extends StatelessWidget {
  AppsList({Key? key}) : super(key: key);

  void upgradeToLanternPro() => LanternNavigator.startScreen(
        LanternNavigator.SCREEN_UPGRADE_TO_LANTERN_PRO,
      );

  Future<void> authorizeDeviceForPro(BuildContext context) async =>
      await context.pushRoute(AuthorizePro());

  void inviteFriends() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_INVITE_FRIEND);

  void openDesktopVersion() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_DESKTOP_VERSION);

  void openSettings(BuildContext context) async =>
      await context.pushRoute(Settings());

  List<Widget> appsList(BuildContext context, SessionModel sessionModel) {
    return [
      ListItemFactory.settingsItem(
        icon: ImagePaths.pro_icon_black,
        content: 'Snapchat'.i18n,
        onTap: upgradeToLanternPro,
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.star,
        content: 'Instagram'.i18n,
        onTap: inviteFriends,
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.desktop,
        content: 'WhatsApp'.i18n,
        onTap: openDesktopVersion,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'AppsList'.i18n,
      body: sessionModel
          .proUser((BuildContext sessionContext, bool proUser, Widget? child) {
        return ListView(
          children: appsList(sessionContext, sessionModel),
        );
      }),
    );
  }
}
