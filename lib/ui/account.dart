import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';

class AccountTab extends StatefulWidget {
  AccountTab({Key key}) : super(key: key);

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  renderYinbiItem({String icon, String title, Function onTap}) {
    var sessionModel = context.watch<SessionModel>();
    return Container(
      margin: EdgeInsets.only(
        top: 8,
      ),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Ink(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomAssetImage(
                    path: icon,
                    size: 24,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    title,
                    style: tsTitleItem(),
                  ),
                ],
              ),
              sessionModel.shouldShowYinbiBadge((BuildContext context,
                  bool shouldShowYinbiBadge, Widget child) {
                return CustomBadge(
                  count: 1,
                  fontSize: 16,
                  showBadge: shouldShowYinbiBadge,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  renderAccountItem({String icon, String title, Function onTap}) {
    return Container(
        margin: EdgeInsets.only(
          top: 8,
        ),
        child: InkWell(
          onTap: onTap ?? () {},
          child: Ink(
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            child: Row(
              children: [
                CustomAssetImage(
                  path: icon,
                  size: 24,
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  title,
                  style: tsTitleItem(),
                ),
              ],
            ),
          ),
        ));
  }

  renderProAccountManagementItem() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
            top: 8,
          ),
          child: InkWell(
            onTap: onOpenProAccountManagement,
            child: Ink(
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomAssetImage(
                        path: ImagePaths.account_icon,
                        size: 32,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        "pro_account_management".i18n,
                        style: tsTitleItem(),
                      ),
                    ],
                  ),
                  CustomAssetImage(
                    path: ImagePaths.keyboard_arrow_right_icon,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        CustomDivider(),
      ],
    );
  }

  renderFreeItem({FREE_ACCOUNT_ITEM accountItemEnum}) {
    switch (accountItemEnum) {
      case FREE_ACCOUNT_ITEM.AUTHORIZE_DEVICE_FOR_PRO:
        return renderAccountItem(
          icon: ImagePaths.devices_icon,
          title: "authorize_device_for_pro".i18n,
          onTap: onAuthorizeDeviceForPro,
        );
      case FREE_ACCOUNT_ITEM.INVITE_FRIENDS:
        return renderAccountItem(
          icon: ImagePaths.star_icon,
          title: "invite_friends".i18n,
          onTap: onInviteFriends,
        );
      case FREE_ACCOUNT_ITEM.DESKTOP_VERSION:
        return renderAccountItem(
          icon: ImagePaths.desktop_icon,
          title: "desktop_version".i18n,
          onTap: onOpenDesktopVersion,
        );
      case FREE_ACCOUNT_ITEM.FREE_YINBI_CRYPTO:
        return renderYinbiItem(
          icon: ImagePaths.yinbi_icon,
          title: "free_yinbi_crypto".i18n,
          onTap: onOpenFreeYinbiCrypto,
        );
      case FREE_ACCOUNT_ITEM.SETTINGS:
        return Column(
          children: [
            //divider
            CustomDivider(),
            renderAccountItem(
              icon: ImagePaths.settings_icon,
              title: "settings".i18n,
              onTap: onOpenSettings,
            ),
          ],
        );
      default:
        return null;
    }
  }

  renderProItem({PRO_ACCOUNT_ITEM accountItemEnum}) {
    switch (accountItemEnum) {
      case PRO_ACCOUNT_ITEM.PRO_ACCOUNT_MANAGEMENT:
        return renderProAccountManagementItem();
      case PRO_ACCOUNT_ITEM.ADD_DEVICE:
        return renderAccountItem(
          icon: ImagePaths.devices_icon,
          title: "add_device".i18n,
          onTap: onAddDevice,
        );
      case PRO_ACCOUNT_ITEM.INVITE_FRIENDS:
        return renderAccountItem(
          icon: ImagePaths.star_icon,
          title: "invite_friends".i18n,
          onTap: onInviteFriends,
        );
      case PRO_ACCOUNT_ITEM.DESKTOP_VERSION:
        return renderAccountItem(
          icon: ImagePaths.desktop_icon,
          title: "desktop_version".i18n,
          onTap: onOpenDesktopVersion,
        );
      case PRO_ACCOUNT_ITEM.YINBI_REDEMPTION:
        return renderYinbiItem(
          icon: ImagePaths.yinbi_icon,
          title: "yinbi_redemption".i18n,
          onTap: onOpenYinbiRedemption,
        );
      case PRO_ACCOUNT_ITEM.SETTINGS:
        return Column(
          children: [
            //divider
            CustomDivider(),
            renderAccountItem(
              icon: ImagePaths.settings_icon,
              title: "settings".i18n,
              onTap: onOpenSettings,
            ),
          ],
        );
      default:
        return null;
    }
  }

  //FUNCTION

  onOpenProAccountManagement() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_ACCOUNT_MANAGEMENT);
  }

  onAuthorizeDeviceForPro() {
    LanternNavigator.startScreen(
        LanternNavigator.SCREEN_AUTHORIZE_DEVICE_FOR_PRO);
  }

  onAddDevice() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_ADD_DEVICE);
  }

  onInviteFriends() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_INVITE_FRIEND);
  }

  onOpenDesktopVersion() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_DESKTOP_VERSION);
  }

  onOpenFreeYinbiCrypto() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_FREE_YINBI);
  }

  onOpenYinbiRedemption() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_YINBI_REDEMPTION);
  }

  onOpenSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
    return sessionModel
        .proUser((BuildContext context, bool proUser, Widget child) {
      return BaseScreen(
          title: 'Account'.i18n,
          body: ListView.builder(
            padding: EdgeInsets.only(
              bottom: 8,
            ),
            itemCount: proUser
                ? PRO_ACCOUNT_ITEM.values.length
                : FREE_ACCOUNT_ITEM.values.length,
            itemBuilder: (context, index) {
              return proUser
                  ? renderProItem(
                      accountItemEnum: PRO_ACCOUNT_ITEM.values[index],
                    )
                  : renderFreeItem(
                      accountItemEnum: FREE_ACCOUNT_ITEM.values[index],
                    );
            },
          ));
    });
  }
}
