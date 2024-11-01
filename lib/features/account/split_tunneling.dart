// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/vpn/vpn.dart';

@RoutePage(name: 'SplitTunneling')
class SplitTunneling extends StatefulWidget {
  const SplitTunneling({super.key});

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
    // unawaited(sessionModel.refreshAppsList());
    var _vpnConnected = await vpnModel.isVpnConnected();
    setState(() {
      vpnConnected = _vpnConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'split_tunneling'.i18n,
      body: sessionModel.splitTunneling(
          (BuildContext context, bool splitTunnelingEnabled, Widget? child) {
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
                      sessionModel.setSplitTunneling(newValue);
                      showRestartVPNSnackBar(context);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 12),
              child: CText(
                splitTunnelingEnabled
                    ? 'apps_to_unblock'.i18n
                    : 'split_tunneling_info'.i18n,
                style: tsBody3,
              ),
            ),
            const SizedBox(height: 10),
            if (splitTunnelingEnabled) _splitTunnelEnable()
          ],
        );
      }),
    );
  }

  // buildAppsLists builds lists for apps allowed access to the VPN connection
  // and installed apps. It returns both along with their associated headers.

  // showRestartVPNSnackBar shows a snackbar with a message indicating that
  // settings will be applied when the VPN is restarted (and only if the
  // snackbar hasn't already been shown)
  void showRestartVPNSnackBar(BuildContext context) async {
    if (vpnConnected || snackbarShown) {
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

  Widget _splitTunnelEnable() {
    return sessionModel.appsData(
      builder: (
        context,
        Iterable<PathAndValue<AppData>> _appsData,
        Widget? child,
      ) {
        return SplitTunnelingAppsList(appsList: _appsData.toList());
      },
    );
  }
}

class SplitTunnelingAppsList extends StatefulWidget {
  final List<PathAndValue<AppData>> appsList;

  const SplitTunnelingAppsList({
    super.key,
    required this.appsList,
  });

  @override
  State<SplitTunnelingAppsList> createState() => _SplitTunnelingAppsListState();
}

class _SplitTunnelingAppsListState extends State<SplitTunnelingAppsList> {
  final formKey = GlobalKey<FormState>();
  late final _searchTextController = CustomTextEditingController(
    formKey: formKey,
  );
  List<PathAndValue<AppData>> list = [];
  bool snackbarShown = false;

  @override
  void didUpdateWidget(covariant SplitTunnelingAppsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    onChangeSearch(_searchTextController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          CTextField(
            controller: _searchTextController,
            contentPadding: const EdgeInsetsDirectional.symmetric(
              vertical: 15.0,
              horizontal: 5.0,
            ),
            prefixIcon: const CAssetImage(path: ImagePaths.searchApp),
            label: 'search_apps'.i18n,
            textInputAction: TextInputAction.done,
            onChanged: onChangeSearch,
          ),
          buildAppsList(
              _searchTextController.text.isEmpty ? widget.appsList : list),

        ],
      ),
    );
  }

  Widget buildAppsList(Iterable<PathAndValue<AppData>> appsData) {
    var sortedAppsData = appsData.toList()
      ..sort((a, b) => a.value.name.compareTo(b.value.name));

    var allowedApps =
        sortedAppsData.where((app) => app.value.allowedAccess).toList();
    var excludedApps =
        sortedAppsData.where((app) => !app.value.allowedAccess).toList();

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 30),
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
      ),
    );
  }

  void onChangeSearch(String search) {
    list.clear();
    if (search == "") {
      setState(() {
        list.clear();
      });
      return;
    }
    for (final apps in widget.appsList) {
      if (apps.value.name.toLowerCase().contains(search.toLowerCase())) {
        list.add(apps);
      }
    }
    setState(() {});
  }

  // buildAppsLists builds lists for apps allowed access to the VPN connection
  // and installed apps. It returns both along with their associated headers.

  // showRestartVPNSnackBar shows a snackbar with a message indicating that
  // settings will be applied when the VPN is restarted (and only if the
  // snackbar hasn't already been shown)
  void showRestartVPNSnackBar(BuildContext context) async {
    if (!await vpnModel.isVpnConnected() || snackbarShown) {
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
            child: appData.icon.isNotEmpty
                ? Image.memory(
                    Uint8List.fromList(appData.icon),
                    fit: BoxFit.cover,
                    width: 24,
                    height: 24,
                  )
                : CircleAvatar(
                    backgroundColor: onSwitchColor,
                    child: CText(
                      appData.name.isNotEmpty
                          ? appData.name[0].toUpperCase()
                          : '',
                      style: tsSubtitle3.copiedWith(color: Colors.white, fontSize: 14.0),
                    ),
                  ),
            ),
          onTap: () => allowOrDenyAppAccess(appData),
          trailing: SizedBox(
            height: 24.0,
            width: 24.0,
            child: Checkbox(
              checkColor: Colors.white,
              shape: const CircleBorder(),
              activeColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              onChanged: (bool? value) => allowOrDenyAppAccess(appData),
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

  void allowOrDenyAppAccess(AppData appData) {
    if (appData.allowedAccess) {
      sessionModel.denyAppAccess(appData.packageName);
    } else {
      sessionModel.allowAppAccess(appData.packageName);
    }
    showRestartVPNSnackBar(context);
  }
}

// SplitTunnelingWidget is the split tunneling widget that appears on the main VPN screen
class SplitTunnelingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return sessionModel.splitTunneling(
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
