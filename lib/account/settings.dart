import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/vpn/vpn_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);

  final packageInfo = PackageInfo.fromPlatform();

  void changeLanguage(BuildContext context) => context.pushRoute(Language());

  void reportIssue() async =>
      LanternNavigator.startScreen(LanternNavigator.SCREEN_SCREEN_REPORT_ISSUE);

  void checkForUpdates() async => await sessionModel.checkForUpdates();

  void openSplitTunneling(BuildContext context) =>
      context.pushRoute(SplitTunneling());

  void openWebview(String url) async => await sessionModel.openWebview(url);


  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'settings'.i18n,
      padVertical: true,
      body: ListView(
        shrinkWrap: true,
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
          ListItemFactory.settingsItem(
            icon: ImagePaths.update,
            content: 'check_for_updates'.i18n,
            trailingArray: [
              mirrorLTR(context: context, child: const ContinueArrow())
            ],
            onTap: checkForUpdates,
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
          //* Split tunneling
          vpnModel.splitTunneling(
            (BuildContext context, bool value, Widget? child) =>
                ListItemFactory.settingsItem(
              header: 'VPN'.i18n,
              icon: ImagePaths.split_tunneling,
              onTap: () {
                openSplitTunneling(context);
              },
              content: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: CText(
                      'split_tunneling'.i18n,
                      softWrap: false,
                      style: tsSubtitle1.short,
                    ),
                  ),
                ],
              ),
              trailingArray: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                  child: CText(
                    value ? 'ON'.i18n : 'OFF'.i18n,
                    style: tsSubtitle2.copiedWith(color: pink4),
                  ),
                ),
                mirrorLTR(
                  context: context,
                  child: const ContinueArrow(),
                )
              ],
            ),
          ),
          ListItemFactory.settingsItem(
            header: 'about'.i18n,
            content: 'privacy_policy'.i18n,
            onTap: () => openWebview("https://lantern.io/privacy"),
            trailingArray: [
              mirrorLTR(
                  context: context,
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(start: 4.0),
                    child: const CAssetImage(
                      path: ImagePaths.open,
                    ),
                  ))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'terms_of_service'.i18n,
            trailingArray: [
              mirrorLTR(
                context: context,
                child: const Padding(
                  padding: EdgeInsetsDirectional.only(start: 4.0),
                  child: const CAssetImage(
                    path: ImagePaths.open,
                  ),
                ),
              )
            ],
            onTap: () => openWebview("https://lantern.io/terms"),
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
                    Container(
                      padding: const EdgeInsetsDirectional.only(
                        bottom: 8.0,
                        end: 8.0,
                      ),
                      child: sessionModel.sdkVersion(
                        (context, sdkVersion, _) => CText(
                          'sdk_version'.i18n.fill([sdkVersion]),
                          style: tsOverline.copiedWith(color: pink4),
                        ),
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
