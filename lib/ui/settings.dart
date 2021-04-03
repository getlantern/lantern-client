import 'package:lantern/package_store.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isAutoConnect = false;
  bool isProxyAll = false;

  renderSettingItem({String icon, String title, Function onTap, bool hasDivider = true, SETTINGS_ENUM settingItemEnum}) {
    // var vpnModel = context.watch<VpnModel>();
    return Column(
      children: [
        //divider
        hasDivider ? CustomDivider() : Container(),
        Container(
          margin: EdgeInsets.only(
            top: 8,
          ),
          child: InkWell(
            onTap: onTap ?? () {},
            child: Ink(
              padding: EdgeInsets.symmetric(
                vertical: settingItemEnum == SETTINGS_ENUM.PROXY ? 4 : 16,
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
                      settingItemEnum == SETTINGS_ENUM.PROXY
                          ? Container(
                        transform: Matrix4.translationValues(-8.0, 0.0, 0.0),
                        child: InkWell(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CustomAssetImage(
                              path: ImagePaths.info_icon,
                              size: 16,
                            ),
                          ),
                          onTap: openInfoProxyAll,
                        ),
                      )
                          : Container(),
                    ],
                  ),
                  settingItemEnum == SETTINGS_ENUM.AUTO_CONNECT || settingItemEnum == SETTINGS_ENUM.PROXY
                      ? FlutterSwitch(
                    width: 44.0,
                    height: 24.0,
                    valueFontSize: 12.0,
                    padding: 2,
                    toggleSize: 18.0,
                    value: settingItemEnum == SETTINGS_ENUM.AUTO_CONNECT ? isAutoConnect : isProxyAll,
                    activeColor: HexColor(greenDotColor),
                    inactiveColor: HexColor(offSwitchColor),
                    onToggle: (bool newValue) {
                      if (settingItemEnum == SETTINGS_ENUM.AUTO_CONNECT) {
                        onToggleAutoConnect();
                      } else {
                        onToggleProxyAll();
                      }
                    },
                  )
                      : Row(
                    children: [
                      settingItemEnum == SETTINGS_ENUM.LANGUAGE
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "English",
                          style: tsTitleItem().copyWith(
                              color: HexColor(
                                okColor,
                              )),
                        ),
                      )
                          : Container(),
                      CustomAssetImage(
                        path: ImagePaths.keyboard_arrow_right_icon,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  renderItem({SETTINGS_ENUM settingItemEnum}) {
    switch (settingItemEnum) {
      case SETTINGS_ENUM.AUTO_CONNECT:
        return renderSettingItem(
          hasDivider: false,
          icon: ImagePaths.power_icon,
          title: "auto_connect".i18n,
          onTap: onToggleAutoConnect,
          settingItemEnum: settingItemEnum,
        );

      case SETTINGS_ENUM.PROXY:
        return renderSettingItem(
          icon: ImagePaths.key_icon,
          title: "proxy_all".i18n,
          onTap: onToggleProxyAll,
          settingItemEnum: settingItemEnum,
        );
      case SETTINGS_ENUM.LANGUAGE:
        return renderSettingItem(
          icon: ImagePaths.translate_icon,
          title: "language".i18n,
          onTap: onChangeLanguage,
          settingItemEnum: settingItemEnum,
        );
      case SETTINGS_ENUM.REPORT:
        return renderSettingItem(
          icon: ImagePaths.alert_icon,
          title: "report_issue".i18n,
          onTap: onReportIssue,
          settingItemEnum: settingItemEnum,
        );
      default:
        return null;
    }
  }

  // FUNCTION

  onToggleAutoConnect() {
    setState(() {
      isAutoConnect = !isAutoConnect;
    });
  }

  onToggleProxyAll() {
    setState(() {
      isProxyAll = !isProxyAll;
    });
  }

  openInfoProxyAll() {
    showInfoDialog(
      context,
      title: "title_proxy_all_dialog".i18n,
      des: "description_proxy_all_dialog".i18n,
      icon: ImagePaths.key_icon,
    );
  }

  onChangeLanguage() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_CHANGE_LANGUAGE);
  }

  onReportIssue() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_SCREEN_REPORT_ISSUE);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Settings'.i18n,
      body: ListView.builder(
        padding: EdgeInsets.only(
          bottom: 8,
        ),
        itemCount: SETTINGS_ENUM.values.length,
        itemBuilder: (context, index) {
          return renderItem(
            settingItemEnum: SETTINGS_ENUM.values[index],
          );
        },
      ),
    );
  }
}