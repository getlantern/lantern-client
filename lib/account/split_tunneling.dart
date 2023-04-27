import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as dev;

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

  init() async {
    bool _vpnConnected = await vpnModel.isVpnConnected();
    setState(() {
      vpnConnected = _vpnConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: 'split_tunneling'.i18n,
        body: sessionModel.splitTunneling((BuildContext context, bool value,
                Widget? child) =>
            sessionModel.appsData(
                builder: (
              context,
              Iterable<PathAndValue<AppData>> _appsData,
              Widget? child,
            ) =>
                    SingleChildScrollView(
                        child: Column(children: <Widget>[
                      ListItemFactory.settingsItem(
                        icon: ImagePaths.split_tunneling,
                        content: 'split_tunneling'.i18n,
                        trailingArray: [
                          SizedBox(
                              width: 44.0,
                              height: 24.0,
                              child: CupertinoSwitch(
                                value: value,
                                activeColor: CupertinoColors.activeGreen,
                                onChanged: (bool? value) {
                                  bool newValue = value ?? false;
                                  setState(() {
                                    sessionModel.setSplitTunneling(newValue);
                                  });
                                },
                              )),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsetsDirectional.only(top: 16),
                          child: CText(
                              value
                                  ? 'apps_selected'.i18n
                                  : 'split_tunneling_info'.i18n,
                              style: tsBody3)),
                      // if split tunneling is enabled, include the installed apps
                      // in the column
                      if (value) ...buildAppsLists(_appsData),
                    ])))));
  }

  // buildAppsLists builds lists for excluded and allowed installed apps and
  // returns both along with their associated headers
  List<Widget> buildAppsLists(Iterable<PathAndValue<AppData>> appsList) {
    if (appsList.length == 0) return [];
    return [
      ListSectionHeader('excluded_apps'.i18n.toUpperCase()),
      buildAppList(appsList.where((appData) => appData.value.isExcluded).toList()),
      ListSectionHeader('allowed_apps'.i18n.toUpperCase()),
      buildAppList(appsList.where((appData) => !appData.value.isExcluded).toList()),
    ];
  }

  Widget buildAppList(List<PathAndValue<AppData>> apps) {
    if (apps.length == 0) {
      return SizedBox.shrink();
    }

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: apps.length,
        itemBuilder: (BuildContext context, int index) {
          var appData = apps[index].value;
          Uint8List bytes = base64.decode(appData.icon);
          Widget appItem = buildAppItem(appData);
          return appItem;
        });
  }

  // showSnackBar shows a snackbar with a message indicating that settings will be applied
  // next time, if the user is connected to the VPN, and it hasn't already been shown
  void showSnackBar(BuildContext context) async {
    if (!vpnConnected || snackbarShown) {
      return;
    }
    final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 7),
        backgroundColor: Colors.black,
        content: CText(
          'applied_next_time'.i18n,
          style: tsSubtitle3.copiedWith(color: Colors.white),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    snackbarShown = true;
  }

  // saveAppIconTempDirectory decodes the app icon bytes part of appData and saves
  // the corresponding image to the application temporary directory
  Future<Image> saveAppIconTempDirectory(AppData appData) async {
    Uint8List iconBytes = base64.decode(appData.icon);
    final Directory temp = await getTemporaryDirectory();
    final File imageFile =
        File('${temp.path}/images/' + appData.packageName + '.png');

    if (!await imageFile.exists()) {
      await imageFile.create(recursive: true);
      await imageFile.writeAsBytes(iconBytes);
    }
    return Image(image: FileImage(imageFile), fit: BoxFit.cover);
  }

  Widget buildAppItem(AppData appData) {
    Uint8List iconBytes = base64.decode(appData.icon);
    return Container(
        height: 72,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Color(0xFFEBEBEB), width: 1.0)),
        ),
        child: Align(
            alignment: Alignment.center,
            child: ListTile(
              key: Key(appData.packageName),
              minLeadingWidth: 20,
              leading: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                  maxWidth: 24,
                  maxHeight: 24,
                ),
                child: Image.memory(iconBytes, fit: BoxFit.cover),
              ),
              trailing: SizedBox(
                  height: 24.0,
                  width: 24.0,
                  child: Checkbox(
                    checkColor: Colors.white,
                    shape: CircleBorder(),
                    activeColor: Colors.black,
                    side: BorderSide(color: Colors.black),
                    value: appData.isExcluded,
                    onChanged: (bool? value) async {
                      setState(() {
                        if (value != null && value!) {
                          sessionModel.addExcludedApp(appData.packageName);
                        } else {
                          sessionModel.removeExcludedApp(appData.packageName);
                        }

                        showSnackBar(context);
                      });
                    },
                  )),
              title: CText(
                toBeginningOfSentenceCase(appData.name)!,
                softWrap: false,
                style: tsSubtitle3.short,
              ),
            )));
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
                  ));
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
                new Spacer(),
                Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: CText(value ? 'on'.i18n : 'off'.i18n,
                        style: tsSubtitle4)),
                mirrorLTR(context: context, child: const ContinueArrow())
              ],
            )));
  }
}
