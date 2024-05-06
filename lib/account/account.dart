import 'package:lantern/account/follow_us.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging_model.dart';

@RoutePage<void>(name: 'Account')
class AccountMenu extends StatelessWidget {
  const AccountMenu({Key? key}) : super(key: key);

  Future<void> authorizeDeviceForPro(BuildContext context) async =>
      await context.pushRoute(AuthorizePro());

  void inviteFriends(BuildContext context) async =>
      await context.pushRoute(const InviteFriends());

  void openDesktopVersion(BuildContext context) async =>
      await context.pushRoute(const LanternDesktop());

  void openSettings(BuildContext context) => context.pushRoute(Settings());

  void openSupport(BuildContext context) {
    context.pushRoute(const Support());
  }

  void upgradeToLanternPro(BuildContext context) async =>
      await context.pushRoute(const PlansPage());

  void showSocialBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      builder: (context) {
        return const FollowUs();
      },
    );
  }

  List<Widget> freeItems(BuildContext context, SessionModel sessionModel) {
    return [
      if (Platform.isAndroid)
        messagingModel.getOnBoardingStatus(
          (context, hasBeenOnboarded, child) => hasBeenOnboarded == true
              ? messagingModel.getCopiedRecoveryStatus(
                  (
                    BuildContext context,
                    bool hasCopiedRecoveryKey,
                    Widget? child,
                  ) =>
                      ListItemFactory.settingsItem(
                    icon: ImagePaths.account,
                    content: 'account_management'.i18n,
                    onTap: () async => await context
                        .pushRoute(AccountManagement(isPro: false)),
                    trailingArray: [
                      if (!hasCopiedRecoveryKey)
                        const CAssetImage(
                          path: ImagePaths.badge,
                        ),
                    ],
                  ),
                )
              : const SizedBox(),
        ),
      ListItemFactory.settingsItem(
        key: AppKeys.upgrade_lantern_pro,
        icon: ImagePaths.pro_icon_black,
        content: 'Upgrade to Lantern Pro'.i18n,
        onTap: () {
          upgradeToLanternPro(context);
        },
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.star,
        content: 'Invite Friends'.i18n,
        onTap: () {
          inviteFriends(context);
        },
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.devices,
        content: 'Authorize Device for Pro'.i18n,
        onTap: () {
          authorizeDeviceForPro(context);
        },
      ),
      ...commonItems(context)
    ];
  }

  List<Widget> proItems(BuildContext context) {
    return [
      messagingModel.getOnBoardingStatus(
        (context, hasBeenOnboarded, child) =>
            messagingModel.getCopiedRecoveryStatus((BuildContext context,
                    bool hasCopiedRecoveryKey, Widget? child) =>
                ListItemFactory.settingsItem(
                  key: AppKeys.account_management,
                  icon: ImagePaths.account,
                  content: 'account_management'.i18n,
                  onTap: () async =>
                      await context.pushRoute(AccountManagement(isPro: true)),
                  trailingArray: [
                    if (!hasCopiedRecoveryKey && hasBeenOnboarded == true)
                      const CAssetImage(
                        path: ImagePaths.badge,
                      ),
                  ],
                )),
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.star,
        content: 'Invite Friends'.i18n,
        onTap: () {
          inviteFriends(context);
        },
      ),

      ListItemFactory.settingsItem(
          icon: ImagePaths.devices,
          content: 'add_device'.i18n,
          onTap: () async => await context.pushRoute(ApproveDevice()),
        ),
      ...commonItems(context)
    ];
  }

  List<Widget> commonItems(BuildContext context) {
    return [
      if (isMobile())
        ListItemFactory.settingsItem(
          icon: ImagePaths.desktop,
          content: 'desktop_version'.i18n,
          onTap: () {
            openDesktopVersion(context);
          },
        ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.thumbUp,
        content: 'follow_us'.i18n,
        onTap: () {
          showSocialBottomSheet(context);
        },
      ),
      ListItemFactory.settingsItem(
        key: AppKeys.support,
        icon: ImagePaths.support,
        content: 'support'.i18n,
        onTap: () {
          openSupport(context);
        },
      ),
      ListItemFactory.settingsItem(
        icon: ImagePaths.settings,
        content: 'settings'.i18n,
        onTap: () {
          openSettings(context);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Account'.i18n,
      automaticallyImplyLeading: false,
      body: sessionModel
          .proUser((BuildContext sessionContext, bool proUser, Widget? child) {
        return ListView(
          children: proUser
              ? proItems(sessionContext)
              : freeItems(sessionContext, sessionModel),
        );
      }),
    );
  }
}
