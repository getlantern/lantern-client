import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/vpn/vpn.dart';

class SplitTunneling extends StatefulWidget {
  SplitTunneling({Key? key});

  @override
  State<SplitTunneling> createState() => _SplitTunnelingState();
}

class _SplitTunnelingState extends State<SplitTunneling> {
  bool vpnConnected = false;
  bool snackbarShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() async {
    unawaited(vpnModel.refreshAppsList());
    var _vpnConnected = await vpnModel.isVpnConnected();
    setState(() {
      vpnConnected = _vpnConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'split_tunneling'.i18n,
      body: vpnModel.splitTunneling(
          (BuildContext context, bool splitTunnelingEnabled, Widget? child) {
        return vpnModel.appsData(
          builder: (
            context,
            Iterable<PathAndValue<AppData>> _appsData,
            Widget? child,
          ) {
            return Column(
              children: <Widget>[
                ListItemFactory.settingsItem(
                  icon: ImagePaths.split_tunneling,
                  content: 'split_tunneling'.i18n,
                  trailingArray: [
                    SizedBox(
                      width: 44.0,
                      height: 24.0,
                      child: CupertinoSwitch(
                        value: splitTunnelingEnabled,
                        activeColor: CupertinoColors.activeGreen,
                        onChanged: (bool? value) {
                          var newValue = value ?? false;
                          vpnModel.setSplitTunneling(newValue);
                          showRestartVPNSnackBar(context);
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 16),
                  child: CText(
                    splitTunnelingEnabled
                        ? 'apps_to_unblock'.i18n
                        : 'split_tunneling_info'.i18n,
                    style: tsBody3,
                  ),
                ),
                // if split tunneling is enabled, include the installed apps
                // in the column
                if (splitTunnelingEnabled)
                  Expanded(child: buildAppsList(_appsData)),
              ],
            );
          },
        );
      }),
    );
  }

  // buildAppsLists builds lists for apps allowed access to the VPN connection
  // and installed apps. It returns both along with their associated headers.
  ListView buildAppsList(Iterable<PathAndValue<AppData>> appsData) {
    var allowedApps = appsData.where((app) => app.value.allowedAccess).toList();
    var excludedApps =
        appsData.where((app) => !app.value.allowedAccess).toList();

    allowedApps.sort((a, b) => a.value.name.compareTo(b.value.name));
    excludedApps.sort((a, b) => a.value.name.compareTo(b.value.name));

    return ListView.builder(
      itemCount: appsData.isEmpty ? 0 : appsData.length + 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return ListSectionHeader(
            'apps_routed_through_lantern'.i18n.toUpperCase(),
          );
        }
        if (index == allowedApps.length + 1) {
          return ListSectionHeader('your_installed_apps'.i18n.toUpperCase());
        }
        late PathAndValue<AppData> appData;
        if (index <= allowedApps.length) {
          appData = allowedApps[index - 1];
        } else {
          appData = excludedApps[index - allowedApps.length - 2];
        }
        return buildAppItem(appData.value);
      },
    );
  }

  // showRestartVPNSnackBar shows a snackbar with a message indicating that
  // settings will be applied when the VPN is restarted (and only if the
  // snackbar hasn't already been shown)
  void showRestartVPNSnackBar(BuildContext context) async {
    if (!vpnConnected || snackbarShown) {
      return;
    }
    showSnackbar(
      context: context,
      content: CText(
        'applied_next_time'.i18n,
        style: tsSubtitle3.copiedWith(color: Colors.white),
      ),
      duration: const Duration(seconds: 7),
    );
    setState(() {
      snackbarShown = true;
    });
  }

  Widget buildAppItem(AppData appData) {
    var iconBytes = appData.icon;
    var packageName = appData.packageName;

    var allowOrDenyAppAccess = () {
      if (appData.allowedAccess) {
        vpnModel.denyAppAccess(packageName);
      } else {
        vpnModel.allowAppAccess(packageName);
      }
      showRestartVPNSnackBar(context);
    };
    return Container(
      height: 72,
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Color(0xFFEBEBEB), width: 1.0)),
      ),
      child: Align(
        alignment: Alignment.center,
        child: ListTile(
          key: Key(appData.packageName),
          minLeadingWidth: 20,
          leading: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
              maxWidth: 24,
              maxHeight: 24,
            ),
            child: iconBytes.isNotEmpty
                ? Image.memory(Uint8List.fromList(iconBytes), fit: BoxFit.cover)
                : null,
          ),
          onTap: () => allowOrDenyAppAccess(),
          trailing: SizedBox(
            height: 24.0,
            width: 24.0,
            child: Checkbox(
              checkColor: Colors.white,
              shape: const CircleBorder(),
              activeColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              onChanged: (bool? value) => allowOrDenyAppAccess(),
              value: appData.allowedAccess,
            ),
          ),
          title: CText(
            toBeginningOfSentenceCase(appData.name)!,
            softWrap: false,
            style: tsSubtitle3.short,
          ),
        ),
      ),
    );
  }
}

// SplitTunnelingWidget is the split tunneling widget that appears on the main VPN screen
class SplitTunnelingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return vpnModel.splitTunneling(
      (BuildContext context, bool value, Widget? child) => InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SplitTunneling(),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CText(
              'split_tunneling'.i18n,
              style: tsSubtitle3.copiedWith(
                color: unselectedTabIconColor,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: CText(
                value ? 'on'.i18n : 'off'.i18n,
                style: tsSubtitle4,
              ),
            ),
            mirrorLTR(context: context, child: const ContinueArrow())
          ],
        ),
      ),
    );
  }
}
