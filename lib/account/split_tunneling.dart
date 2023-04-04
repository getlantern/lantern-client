import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:flutter/foundation.dart';

class AppCheckmark extends StatefulWidget {
  // The package name of the application the AppCheckmark corresponds with
  final String packageName;
  // Whether the app should be excluded from the VPN connection
  bool isExcluded;

  AppCheckmark({required this.packageName, required this.isExcluded});

  @override
  State<AppCheckmark> createState() => _AppCheckmarkState();
}

class _AppCheckmarkState extends State<AppCheckmark> {
  // Whether the app is excluded from the VPN connection
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      checkColor: Colors.white,
      shape: CircleBorder(),
      activeColor: Colors.black,
      side: BorderSide(color: Colors.black),
      // If an app has previously been excluded from the VPN connection by a user,
      // the switch is turned on by default
      value: isChecked || widget.isExcluded,
      onChanged: (bool? value) {
        // This is called when the user toggles the switch.
        setState(() {
          isChecked = value!;
          if (isChecked) {
            sessionModel.addExcludedApp(widget.packageName);
          } else {
            sessionModel.removeExcludedApp(widget.packageName);
          }
        });
      },
    );
  }
}

class SplitTunneling extends StatelessWidget {
  SplitTunneling({Key? key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: 'split_tunneling'.i18n,
        body: sessionModel.splitTunneling((BuildContext context, bool value,
                Widget? child) =>
            Column(children: <Widget>[
              Container(
                height: 72.0,
                child: Row(children: <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 16.0,
                    ),
                    child: CAssetImage(path: ImagePaths.split_tunneling),
                  ),
                  CText(
                    'split_tunneling'.i18n,
                    softWrap: false,
                    style: tsSubtitle1.short,
                  ),
                  Spacer(),
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
                ]),
              ),
              CText(value ? 'apps_selected'.i18n : 'split_tunneling_info'.i18n,
                  style: tsBody3),
              // if split tunneling is enabled, include the installed apps
              // in the column
              if (value) ...buildAppsLists(),
            ])));
  }

  // buildAppsLists builds lists for excluded and allowed installed apps and
  // returns both along with their associated headers
  List<Widget> buildAppsLists() {
    return [
      ListSectionHeader('excluded_apps'.i18n.toUpperCase()),
      sessionModel.appsData(
          (BuildContext context, AppsData appsData, Widget? child) =>
              buildAppList(appsData, false)),
      ListSectionHeader('allowed_apps'.i18n.toUpperCase()),
      sessionModel.appsData(
          (BuildContext context, AppsData appsData, Widget? child) =>
              buildAppList(appsData, true)),
    ];
  }

  bool isAppExcluded(AppsData appsData, String packageName) {
    return appsData.excludedApps.excludedApps[packageName] ?? false;
  }

  Widget buildAppList(AppsData appsData, bool excludedApps) {
    List<AppData> filtered;
    if (excludedApps) {
      // filter apps that are excluded for the excluded apps list
      filtered = appsData.appsList
          .where((appData) => isAppExcluded(appsData, appData.packageName))
          .toList();
    } else {
      // filter apps that are not excluded for the allowed apps list
      filtered = appsData.appsList
          .where((appData) => !isAppExcluded(appsData, appData.packageName))
          .toList();
    }
    if (filtered.length == 0) {
      return SizedBox.shrink();
    }

    return Expanded(
        child: ListView.separated(
            itemCount: filtered.length,
            itemBuilder: (BuildContext context, int index) {
              var appData = filtered[index];
              Uint8List bytes = base64.decode(appData.icon);
              return buildAppItem(
                  appData, isAppExcluded(appsData, appData.packageName));
            },
            separatorBuilder: (context, index) {
              return Divider(height: 1.0);
            }));
  }

  Widget buildAppItem(AppData appData, bool isAppExcluded) {
    Uint8List iconBytes = base64.decode(appData.icon);
    return ListTile(
      leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 24,
                minHeight: 24,
                maxWidth: 24,
                maxHeight: 24,
              ),
              child: new Image.memory(iconBytes, fit: BoxFit.cover),
            )
          ]),
      trailing: AppCheckmark(
          packageName: appData.packageName, isExcluded: isAppExcluded),
      title: CText(
        toBeginningOfSentenceCase(appData.name)!,
        style: tsBody1,
      ),
    );
  }
}
