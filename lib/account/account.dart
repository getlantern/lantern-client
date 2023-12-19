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

  void onSignOut(BuildContext context) {
    try {
      sessionModel.signOut();
    } catch (e) {
      print(e);
    }
  }

  void showSingOutDialog(BuildContext context) {
    CDialog(
      title: 'sign_out'.i18n,
      description: "sign_out_message".i18n,
      icon: const CAssetImage(
        path: ImagePaths.signOut,
        height: 40,
      ),
      agreeText: "sign_out".i18n,
      dismissText: "not_now".i18n,
      includeCancel: true,
      agreeAction: () async {
        onSignOut(context);
        return true;
      },
      dismissAction: () async {},
    ).show(context);
  }

  void onAccountManagementTap(BuildContext context, bool isProUser) {
    //Todo make this dynamic once connect to API
    if (sessionModel.hasUserSignedInNotifier.value == true) {
      context.pushRoute(AccountManagement(isPro: isProUser));
    } else {
      showProUserDialog(context);
    }
  }

  void openSignIn(BuildContext context) => context.pushRoute(SignIn());

  void upgradeToLanternPro(BuildContext context) async =>
      await context.pushRoute(const PlansPage());

  List<Widget> freeItems(BuildContext context, SessionModel sessionModel) {
    return [
      if (Platform.isAndroid) messagingModel.getOnBoardingStatus(
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
                  onTap: () => onAccountManagementTap(context, false),
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
        icon: ImagePaths.signIn,
        content: 'sign_in'.i18n,
        onTap: () => openSignIn(context),
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
                  onTap: () => onAccountManagementTap(context, true),
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
      if (Platform.isAndroid)
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
      ListItemFactory.settingsItem(
        icon: ImagePaths.desktop,
        content: 'desktop_version'.i18n,
        onTap: () {
          openDesktopVersion(context);
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
      sessionModel.isUserSignedIn((context, hasSignedIn, child) {
        return hasSignedIn
            ? ListItemFactory.settingsItem(
                icon: ImagePaths.signOut,
                content: 'sign_out'.i18n,
                onTap: () => showSingOutDialog(context),
              )
            : const SizedBox.shrink();
      })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Account'.i18n,
      automaticallyImplyLeading: false,
      body: sessionModel
          .proUser((BuildContext sessionContext, bool proUser, Widget? child) {
        print("called pro user listener");
        return sessionModel.isUserSignedIn((context, hasUserLoggedIn, child) {
          print("called isUserSignedIn listener");
          return ListView(
            children: proUser && hasUserLoggedIn
                ? proItems(sessionContext)
                : freeItems(sessionContext, sessionModel),
          );
        });
      }),
    );
  }
}
