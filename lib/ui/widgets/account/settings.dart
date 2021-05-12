import 'package:intl/intl.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';

import 'settings_item.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  void openInfoProxyAll(BuildContext context) {
    showInfoDialog(
      context,
      title: 'proxy_all'.i18n,
      des: 'description_proxy_all_dialog'.i18n,
      icon: ImagePaths.key_icon,
    );
  }

  void changeLanguage(BuildContext context) {
    Navigator.pushNamed(context, routeLanguage);
  }

  void reportIssue() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_SCREEN_REPORT_ISSUE);
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'settings'.i18n,
      body: ListView(
        padding: const EdgeInsetsDirectional.only(
          bottom: 8,
        ),
        children: [
          SettingsItem(
            icon: ImagePaths.key_icon,
            title: 'proxy_all'.i18n,
            inkVerticalPadding: 4,
            openInfoDialog: openInfoProxyAll,
            child: sessionModel
                .proxyAll((BuildContext context, bool proxyAll, Widget? child) {
              return FlutterSwitch(
                width: 44.0,
                height: 24.0,
                valueFontSize: 12.0,
                padding: 2,
                toggleSize: 18.0,
                value: proxyAll,
                activeColor: HexColor(indicatorGreen),
                inactiveColor: HexColor(offSwitchColor),
                onToggle: (bool newValue) {
                  sessionModel.switchProxyAll(newValue);
                },
              );
            }),
          ),
          SettingsItem(
            icon: ImagePaths.translate_icon,
            title: 'language'.i18n,
            showTopDivider: true,
            showArrow: true,
            onTap: () {
              changeLanguage(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: sessionModel
                  .language((BuildContext context, String lang, Widget? child) {
                return Text(
                  toBeginningOfSentenceCase(
                      lang.displayLanguage(context, lang))!,
                  style: tsSelectedTitleItem(),
                );
              }),
            ),
          ),
          SettingsItem(
            icon: ImagePaths.alert_icon,
            title: 'report_issue'.i18n,
            showTopDivider: true,
            showArrow: true,
            onTap: reportIssue,
          )
        ],
      ),
    );
  }
}
