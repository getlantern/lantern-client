import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router.gr.dart';

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
          ListItemFactory.isSettingsItem(
            leading: ImagePaths.key,
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CText('proxy_all'.i18n, style: tsSubtitle1),
                GestureDetector(
                  onTap: () => openInfoProxyAll(context),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(start: 4.0),
                    child: CAssetImage(
                      path: ImagePaths.info,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            trailingArray: [
              sessionModel.proxyAll(
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
              )
            ],
          ),
          ListItemFactory.isSettingsItem(
            leading: ImagePaths.translate,
            content: 'language'.i18n,
            onTap: () {
              changeLanguage(context);
            },
            trailingArray: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: sessionModel.language(
                  (BuildContext context, String lang, Widget? child) => CText(
                    toBeginningOfSentenceCase(
                        lang.displayLanguage(context, lang).toUpperCase())!,
                    style: tsSubtitle2.copiedWith(color: pink4),
                  ),
                ),
              ),
              const ContinueArrow()
            ],
          ),
          ListItemFactory.isSettingsItem(
            leading: ImagePaths.alert,
            content: 'report_issue'.i18n,
            trailingArray: [const ContinueArrow()],
            onTap: reportIssue,
          )
        ],
      ),
    );
  }
}
