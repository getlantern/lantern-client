import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:lantern/account/account.dart';
import 'package:lantern/core/router/router.gr.dart';

import 'settings_item.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);

  void openInfoProxyAll(BuildContext context) {
    showInfoDialog(context,
        title: 'proxy_all'.i18n,
        des: 'description_proxy_all_dialog'.i18n,
        assetPath: ImagePaths.key,
        buttonText: 'OK'.i18n);
  }

  void changeLanguage(BuildContext context) => context.pushRoute(Language());

  void reportIssue() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_SCREEN_REPORT_ISSUE);

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'settings'.i18n,
      body: ListView(
        children: [
          SettingsItem(
            icon: ImagePaths.key,
            title: 'proxy_all'.i18n,
            openInfoDialog: openInfoProxyAll,
            child: sessionModel.proxyAll(
              (BuildContext context, bool proxyAll, Widget? child) =>
                  FlutterSwitch(
                width: 44.0,
                height: 24.0,
                valueFontSize: 12.0,
                padding: 2,
                toggleSize: 18.0,
                value: proxyAll,
                activeColor: indicatorGreen,
                inactiveColor: offSwitchColor,
                onToggle: (bool newValue) {
                  sessionModel.setProxyAll(newValue);
                },
              ),
            ),
          ),
          SettingsItem(
            icon: ImagePaths.translate,
            title: 'language'.i18n,
            showArrow: true,
            onTap: () {
              changeLanguage(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: sessionModel.language(
                (BuildContext context, String lang, Widget? child) => CText(
                  toBeginningOfSentenceCase(
                      lang.displayLanguage(context, lang).toUpperCase())!,
                  style: tsSubtitle2.copiedWith(color: pink4),
                ),
              ),
            ),
          ),
          SettingsItem(
            icon: ImagePaths.alert,
            title: 'report_issue'.i18n,
            showArrow: true,
            onTap: reportIssue,
          )
        ],
      ),
    );
  }
}
