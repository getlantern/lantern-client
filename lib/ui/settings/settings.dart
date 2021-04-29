import 'package:intl/intl.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/settings/settings_item.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  void openInfoProxyAll(BuildContext context) {
    showInfoDialog(
      context,
      title: 'title_proxy_all_dialog'.i18n,
      des: 'description_proxy_all_dialog'.i18n,
      icon: ImagePaths.key_icon,
    );
  }

  void onChangeLanguage() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_CHANGE_LANGUAGE);
  }

  void onReportIssue() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_SCREEN_REPORT_ISSUE);
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'Settings'.i18n,
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 8,
        ),
        children: [
          SettingsItem(
            icon: ImagePaths.key_icon,
            title: 'proxy_all'.i18n,
            inkVerticalPadding: 4,
            showArrow: false,
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
                activeColor: HexColor(greenDotColor),
                inactiveColor: HexColor(offSwitchColor),
                onToggle: (bool newValue) {
                  sessionModel.switchProxyAll(newValue);
                },
              );
            }),
          ),
          const CustomDivider(),
          SettingsItem(
            icon: ImagePaths.translate_icon,
            title: 'language'.i18n,
            onTap: onChangeLanguage,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: sessionModel
                  .language((BuildContext context, String lang, Widget? child) {
                return Text(
                  toBeginningOfSentenceCase(
                      lang.displayLanguage(context, lang))!,
                  style: tsTitleItem()?.copyWith(
                      color: HexColor(
                    primaryPink,
                  )),
                );
              }),
            ),
          ),
          const CustomDivider(),
          SettingsItem(
            icon: ImagePaths.alert_icon,
            title: 'report_issue'.i18n,
            onTap: onReportIssue,
          )
        ],
      ),
    );
  }
}
