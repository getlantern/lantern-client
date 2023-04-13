import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:flutter/foundation.dart';

class SplitTunneling extends StatefulWidget {
  SplitTunneling({Key? key});

  @override
  State<SplitTunneling> createState() => _SplitTunnelingState();
}

class _SplitTunnelingState extends State<SplitTunneling> {
  AppsData? appsData;

  late ValueNotifier<AppsData?> appsDataNotifier;
  late void Function() appsDataListener;
  final Map<String, bool> excludedApps = new Map();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSplitTunneling();
    });
  }

  initSplitTunneling() async {
    AppsData _appsData = await sessionModel.appsData();
    setState(() {
      appsData = _appsData;
      for (var packageName in _appsData.excludedApps.excludedApps.keys) {
        excludedApps[packageName] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: 'split_tunneling'.i18n,
        body: sessionModel.splitTunneling(
            (BuildContext context, bool value, Widget? child) =>
                SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(children: <Widget>[
                      ListItemFactory.settingsItem(
                        icon: ImagePaths.split_tunneling,
                        content: 'split_tunneling'.i18n,
                        trailingArray: [
                          FlutterSwitch(
                            width: 44.0,
                            height: 24.0,
                            valueFontSize: 12.0,
                            activeColor: Colors.green,
                            padding: 2,
                            toggleSize: 18.0,
                            value: value,
                            onToggle: (bool newValue) {
                              sessionModel.setSplitTunneling(newValue);
                            },
                          )
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
                      if (value) ...buildAppsLists(),
                    ]))));
  }

  // buildAppsLists builds lists for excluded and allowed installed apps and
  // returns both along with their associated headers
  List<Widget> buildAppsLists() {
    if (appsData == null) return [];
    List<AppData> appsList = appsData!.appsList.toSet().toList();
    return [
      ListSectionHeader('excluded_apps'.i18n.toUpperCase()),
      buildAppList(appsList
          .where((appData) => isAppExcluded(appData.packageName))
          .toList()),
      ListSectionHeader('allowed_apps'.i18n.toUpperCase()),
      buildAppList(appsList
          .where((appData) => !isAppExcluded(appData.packageName))
          .toList()),
    ];
  }

  bool isAppExcluded(String packageName) {
    return excludedApps[packageName] ?? false;
  }

  Widget buildAppList(List<AppData> apps) {
    if (apps.length == 0) {
      return SizedBox.shrink();
    }

    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: apps.length,
        itemBuilder: (BuildContext context, int index) {
          var appData = apps[index];
          Uint8List bytes = base64.decode(appData.icon);
          bool isExcluded = isAppExcluded(appData.packageName);
          Widget appItem = buildAppItem(appData, isExcluded);
          return appItem;
        });
  }

  Widget buildAppItem(AppData appData, bool isAppExcluded) {
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
                child: new Image.memory(iconBytes, fit: BoxFit.cover),
              ),
              trailing: SizedBox(
                  height: 24.0,
                  width: 24.0,
                  child: Checkbox(
                    checkColor: Colors.white,
                    shape: CircleBorder(),
                    activeColor: Colors.black,
                    side: BorderSide(color: Colors.black),
                    value: isAppExcluded,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value!) {
                          excludedApps[appData.packageName] = true;
                          sessionModel.addExcludedApp(appData.packageName);
                        } else {
                          excludedApps.remove(appData.packageName);
                          sessionModel.removeExcludedApp(appData.packageName);
                        }
                      });
                    },
                  )),
              title: CText(
                toBeginningOfSentenceCase(appData.name)!,
                softWrap: false,
                style: tsSubtitle1.short,
              ),
            )));
  }
}

// SplitTunnelingHome is the split tunneling widget that appears on the main VPN screen
class SplitTunnelingHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return sessionModel.splitTunneling(
        (BuildContext context, bool splitTunneling, Widget? child) {
      return InkWell(
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
                style: tsBody1.copiedWith(
                  color: unselectedTabIconColor,
                ),
              ),
              splitTunneling
                  ? CText(
                      'on'.i18n,
                      style: tsBody2.copiedWith(fontWeight: FontWeight.w500),
                    )
                  : CText(
                      'off'.i18n,
                      style: tsBody2.copiedWith(fontWeight: FontWeight.w500),
                    )
            ],
          ));
    });
  }
}
