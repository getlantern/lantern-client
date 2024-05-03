import 'package:catcher_2/core/catcher_2.dart';
import 'package:intl/intl.dart';
import 'package:lantern/common/app_methods.dart';
import 'package:lantern/common/app_secret.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/common/ui/app_loading_dialog.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

@RoutePage(name: 'Settings')
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

  void changeLanguage(BuildContext context) async =>
      await context.pushRoute(Language());

  void reportIssue(BuildContext context) async =>
      await context.pushRoute(ReportIssue());

  void openSplitTunneling(BuildContext context) =>
      context.pushRoute(SplitTunneling());

  void openWebView(String url, BuildContext context, String title) async {
    if (isDesktop()) {
      await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
    } else if (isMobile()) {
      context.pushRoute(AppWebview(url: url, title: title));
    }
  }

  Future<void> checkForUpdateTap(BuildContext context) async {
    if (Platform.isAndroid) {
      AppLoadingDialog.showLoadingDialog(context);
      await sessionModel.checkForUpdates();
      AppLoadingDialog.dismissLoadingDialog(context);
    } else if (Platform.isIOS) {
      AppMethods.openAppstore();
    } else {
      ffiCheckUpdates();
    }
  }

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
          ListItemFactory.settingsItem(
            icon: ImagePaths.update,
            content: 'check_for_updates'.i18n,
            trailingArray: [
              mirrorLTR(context: context, child: const ContinueArrow())
            ],
            onTap: () => checkForUpdateTap(context),
          ),
          //* Blocked
          if (!isDesktop())
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
          if (!isDesktop())
            sessionModel.splitTunneling(
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
                    padding:
                        const EdgeInsetsDirectional.only(start: 16, end: 16),
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
          //* Proxy all
          if (isDesktop())
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
                          key: ValueKey('proxy_all_icon'),
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
          ListItemFactory.settingsItem(
            header: 'about'.i18n,
            content: 'privacy_policy'.i18n,
            onTap: () => openWebView(
                AppSecret.privacyPolicyV2, context, "privacy_policy".i18n),
            trailingArray: [
              mirrorLTR(
                context: context,
                child: const Padding(
                  padding: EdgeInsetsDirectional.only(start: 4.0),
                  child: CAssetImage(
                    path: ImagePaths.open,
                  ),
                ),
              )
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'terms_of_service'.i18n,
            trailingArray: [
              mirrorLTR(
                context: context,
                child: const Padding(
                  padding: EdgeInsetsDirectional.only(start: 4.0),
                  child: CAssetImage(
                    path: ImagePaths.open,
                  ),
                ),
              )
            ],
            onTap: () =>
                openWebView(AppSecret.tosV2, context, "terms_of_service".i18n),
          ),
          //* Build version
          FutureBuilder<PackageInfo>(
            future: packageInfo,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              final packageInfo = snapshot.data;
              return Padding(
                padding: const EdgeInsetsDirectional.only(top: 12),
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
                            .fill([packageInfo?.version ?? '']),
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
                            .fill([packageInfo?.buildNumber ?? '']),
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
