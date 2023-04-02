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
      activeColor: Colors.green,
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
        body: Column(children: <Widget>[
          splitTunnelingSwitch(context),
          CText('split_tunneling_info'.i18n, style: tsBody3),
          ListSectionHeader('apps'.i18n),
          sessionModel.appsData(
              (BuildContext context, AppsData appsData, Widget? child) =>
                  Expanded(
                      child: ListView.separated(
                          itemCount: 10 /*appsData.appsList.length*/,
                          itemBuilder: (BuildContext context, int index) {
                            var appData = appsData.appsList[index];
                            debugPrint('data: $appData');
                            bool isExcluded = appsData.excludedApps
                                    .excludedApps[appData.packageName] ??
                                false;
                            return buildAppListItem(appData, isExcluded);
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          })))
        ]));
  }

  Widget buildAppListItem(AppData appData, bool isExcluded) {
    Uint8List bytes = base64.decode(appData.icon);
    return ListTile(
      //contentPadding: const EdgeInsetsDirectional.only(top: 24, bottom: 24),
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
              child: new Image.memory(bytes, fit: BoxFit.cover),
            )
          ]),
      trailing: AppCheckmark(
          packageName: appData.packageName, isExcluded: isExcluded),
      title: CText(
        toBeginningOfSentenceCase(appData.name)!,
        style: tsBody1,
      ),
    );
  }

  Widget splitTunnelingSwitch(BuildContext context) {
    return sessionModel.splitTunneling(
      (BuildContext context, bool value, Widget? child) => Container(
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
    );
  }
}
