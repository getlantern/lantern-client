import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lantern/i18n/localization_constants.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);

  final packageInfo = PackageInfo.fromPlatform();

  void openInfoProxyAll(BuildContext context) {
    CDialog.showInfo(
      context,
      title: 'proxy_all'.i18n,
      description: 'description_proxy_all_dialog'.i18n,
      iconPath: ImagePaths.key,
    );
  }

  void changeLanguage(BuildContext context) => context.pushRoute(Language());

  void reportIssue() =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_SCREEN_REPORT_ISSUE);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'settings'.i18n,
      body: Column(
        children: [
          //* Language
          ListItemFactory.settingsItem(
            header: 'general'.i18n,
            icon: ImagePaths.translate,
            content: 'language'.i18n,
            onTap: () {
              changeLanguage(context);
            },
            trailingArray: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                child: sessionModel.language(
                  (BuildContext context, String lang, Widget? child) => CText(
                    toBeginningOfSentenceCase(
                      displayLanguage(lang).toUpperCase(),
                    )!,
                    style: tsSubtitle2.copiedWith(color: pink4),
                  ),
                ),
              ),
              mirrorLTR(context: context, child: const ContinueArrow())
            ],
          ),
          //* Report
          ListItemFactory.settingsItem(
            icon: ImagePaths.alert,
            content: 'report_issue'.i18n,
            trailingArray: [
              mirrorLTR(context: context, child: const ContinueArrow())
            ],
            onTap: reportIssue,
          ),
          //* Blocked
          messagingModel.getOnBoardingStatus(
            (context, hasBeenOnboarded, child) => hasBeenOnboarded == true
                ? ListItemFactory.settingsItem(
                    header: 'chat'.i18n,
                    icon: ImagePaths.block,
                    content: 'blocked_users'.i18n,
                    trailingArray: [
                      mirrorLTR(
                        context: context,
                        child: const ContinueArrow(),
                      )
                    ],
                    onTap: () => context.pushRoute(BlockedUsers()),
                  )
                : const SizedBox(),
          ),
          //* Proxy
          sessionModel.proxyAll(
            (BuildContext context, bool proxyAll, Widget? child) =>
                ListItemFactory.settingsItem(
              header: 'VPN'.i18n,
              icon: ImagePaths.key,
              content: CInkWell(
                onTap: () => openInfoProxyAll(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: CText(
                        'proxy_everything_is'
                            .i18n
                            .fill([proxyAll ? 'ON'.i18n : 'OFF'.i18n]),
                        softWrap: false,
                        style: tsSubtitle1.short,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsetsDirectional.only(start: 4.0),
                      child: CAssetImage(
                        path: ImagePaths.info,
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ),
              trailingArray: [
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
              ],
            ),
          ),
          //* Build version
          FutureBuilder<PackageInfo>(
            future: packageInfo,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsetsDirectional.only(
                        bottom: 8.0,
                        end: 8.0,
                      ),
                      child: CText(
                        'version_number'
                            .i18n
                            .fill([snapshot.data?.version ?? '']),
                        style: tsOverline.copiedWith(color: pink4),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsetsDirectional.only(
                        bottom: 8.0,
                        end: 8.0,
                      ),
                      child: CText(
                        'build_number'
                            .i18n
                            .fill([snapshot.data?.buildNumber ?? '']),
                        style: tsOverline.copiedWith(color: pink4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
