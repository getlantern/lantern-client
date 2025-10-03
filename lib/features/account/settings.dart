import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:lantern/core/app/app_loading_dialog.dart';
import 'package:lantern/core/localization/localization_constants.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

@RoutePage(name: 'Settings')
class Settings extends StatelessWidget {
  Settings({super.key});

  final packageInfo = PackageInfo.fromPlatform();

  void openInfoProxyAll(BuildContext context) {
    CDialog.showInfo(
      context,
      title: 'proxy_all'.i18n,
      description: 'description_proxy_all_dialog'.i18n,
      iconPath: ImagePaths.key,
    );
  }

  void openInfoProxyless(BuildContext context) {
    CDialog.showInfo(
      context,
      title: 'proxyless'.i18n,
      description: 'description_proxyless_dialog'.i18n,
      iconPath: ImagePaths.key,
    );
  }

  void changeLanguage(BuildContext context) async =>
      await context.pushRoute(Language());

  void reportIssue(BuildContext context) async =>
      await context.pushRoute(ReportIssue());

  void openSplitTunneling(BuildContext context) =>
      context.pushRoute(SplitTunneling());

  Future<void> openWebView(
          String url, BuildContext context, String title) async =>
      await openWebview(context, url);

  void openProxySetting(BuildContext context) =>
      context.pushRoute(ProxiesSetting());

  Future<void> checkForUpdateTap(BuildContext context) async {
    try {
      AppLoadingDialog.showLoadingDialog(context);
      final result = await sessionModel.checkForUpdates();
      AppLoadingDialog.dismissLoadingDialog(context);
      if (result != null && result != "" && result == "no_new_update") {
        CDialog.showInfo(context,
            title: "app_name".i18n, description: "no_new_update".i18n);
      }
    } catch (e) {
      AppLoadingDialog.dismissLoadingDialog(context);
      CDialog.showError(context,
          description: 'we_are_experiencing_technical_difficulties'.i18n);
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
              mirrorLTR(context: context, child: const ContinueArrow()),
            ],
          ),
          ListItemFactory.settingsItem(
            icon: ImagePaths.update,
            content: 'check_for_updates'.i18n,
            trailingArray: [
              mirrorLTR(context: context, child: const ContinueArrow()),
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
                        ),
                      ],
                      onTap: () => context.pushRoute(BlockedUsers()),
                    )
                  : const SizedBox(),
            ),
          //* Split tunneling
          if (Platform.isAndroid)
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
                  ),
                ],
              ),
            ),
          if (Platform.isAndroid)
            sessionModel.proxyless(
              (BuildContext context, bool proxylessEnabled, Widget? child) =>
              ListItemFactory.settingsItem(
                icon: ImagePaths.proxyall,
                content: CInkWell(
                  onTap: () => openInfoProxyless(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CText(
                          'proxyless'.i18n,
                          softWrap: false,
                          style: tsSubtitle1.short,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.only(start: 4.0),
                        child: CAssetImage(
                          key: ValueKey('proxyless_icon'),
                          path: ImagePaths.info,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                trailingArray: [
                  SizedBox(
                    width: 44.0,
                    height: 24.0,
                    child: CupertinoSwitch(
                      value: proxylessEnabled,
                      activeTrackColor: CupertinoColors.activeGreen,
                      onChanged: (bool? value) {
                        var newValue = value ?? false;
                        sessionModel.setProxyless(newValue);
                      },
                    ),
                  ),
                ],
              ),
            ),
          //* Proxy all
          if (isDesktop())
            sessionModel.proxyAll(
              (BuildContext context, bool proxyAll, Widget? child) =>
                  ListItemFactory.settingsItem(
                header: 'VPN'.i18n,
                icon: ImagePaths.split_tunneling,
                content: CInkWell(
                  onTap: () => openInfoProxyAll(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CText(
                          'proxy_everything'.i18n,
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
                  AdvancedSwitch(
                    width: 44.0,
                    height: 24.0,
                    initialValue: proxyAll,
                    activeColor: indicatorGreen,
                    inactiveColor: offSwitchColor,
                    onChanged: (newValue) {
                      sessionModel.setProxyAll(newValue);
                    },
                  ),
                ],
              ),
            ),
          if (isDesktop())
            ListItemFactory.settingsItem(
              icon: ImagePaths.proxySetting,
              content: 'proxy_settings'.i18n,
              trailingArray: [
                mirrorLTR(context: context, child: const ContinueArrow())
              ],
              onTap: () => {openProxySetting(context)},
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
                    Expanded(
                      child: Container(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: 8.0,
                          end: 8.0,
                        ),
                        child: sessionModel.sdkVersion(
                          (context, sdkVersion, _) => CText(
                            'sdk_version'.i18n.fill([sdkVersion]),
                            style: tsOverline.copiedWith(color: pink4),
                            overflow: TextOverflow.ellipsis,
                          ),
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
