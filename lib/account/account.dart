import 'package:lantern/account/follow_us.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging_model.dart';

@RoutePage<void>(name: 'Account')
class AccountMenu extends StatefulWidget {
  const AccountMenu({Key? key}) : super(key: key);

  @override
  State<AccountMenu> createState() => _AccountMenuState();
}

class _AccountMenuState extends State<AccountMenu> {
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

  Future<void> onSignOut() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.signOut();
      context.loaderOverlay.hide();
    } catch (e) {
      mainLogger.e('Error signing out', error: e);
      context.loaderOverlay.hide();
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
        onSignOut();
        return true;
      },
      dismissAction: () async {},
    ).show(context);
  }

  void onAccountManagementTap(BuildContext context, bool isProUser, authEnabled, hasUserLoggedIn) {
    if (!authEnabled || Platform.isAndroid) {
      context.pushRoute(AccountManagement(isPro: isProUser));
      return;
    }
    if (hasUserLoggedIn) {
      // User has gone through onboarding
      context.pushRoute(AccountManagement(isPro: isProUser));
    } else {
      // Ask user to update their email and password
      showProUserDialog(context);
    }
  }

  void openSignIn(BuildContext context) => context.pushRoute(SignIn());

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

  List<Widget> freeItems(BuildContext context, bool authEnabled, hasUserLoggedIn) {
    return [
      if (authEnabled && !hasUserLoggedIn)
        ListItemFactory.settingsItem(
          icon: ImagePaths.signIn,
          content: 'sign_in'.i18n,
          onTap: () => openSignIn(context),
        ),
      if (Platform.isAndroid)
        messagingModel.getOnBoardingStatus(
              (context, hasBeenOnboarded, child) =>
          hasBeenOnboarded == true
              ? messagingModel.getCopiedRecoveryStatus(
                (BuildContext context,
                bool hasCopiedRecoveryKey,
                Widget? child,) =>
                ListItemFactory.settingsItem(
                  icon: ImagePaths.account,
                  content: 'account_management'.i18n,
                  onTap: () async =>
                  await context
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
        onTap: () => authorizeDeviceForPro(context),
      ),
      ...commonItems(context, authEnabled, hasUserLoggedIn)
    ];
  }

  List<Widget> proItems(BuildContext context, bool authEnabled, hasUserLoggedIn) {
    return [
      messagingModel.getOnBoardingStatus(
            (context, hasBeenOnboarded, child) =>
            messagingModel.getCopiedRecoveryStatus((BuildContext context,
                bool hasCopiedRecoveryKey, Widget? child) =>
                ListItemFactory.settingsItem(
                  key: AppKeys.account_management,
                  icon: ImagePaths.account,
                  content: 'account_management'.i18n,
                  onTap: () =>
                      onAccountManagementTap(context, true, authEnabled, hasUserLoggedIn),
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
      ...commonItems(context, authEnabled, hasUserLoggedIn)
    ];
  }

  List<Widget> commonItems(BuildContext context, bool authEnabled, hasUserLoggedIn) {
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
      if (authEnabled && hasUserLoggedIn)
        ListItemFactory.settingsItem(
          icon: ImagePaths.signOut,
          content: 'sign_out'.i18n,
          onTap: () => showSingOutDialog(context),
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Account'.i18n,
      automaticallyImplyLeading: false,
      body: sessionModel
          .proUser((BuildContext sessionContext, bool proUser, Widget? child) {
        return sessionModel.authEnabled((context, authEnabled, _) {
          return sessionModel.isUserSignedIn((context, hasUserLoggedIn, child) {
            return ListView(
              children: proUser
                  ? proItems(sessionContext, authEnabled, hasUserLoggedIn)
                  : freeItems(sessionContext, authEnabled, hasUserLoggedIn),
            );
          });
        });
      }),
    );
  }
}
