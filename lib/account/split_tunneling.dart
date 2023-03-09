import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:flutter/foundation.dart';

class AppSwitch extends StatefulWidget {
  // The package name of the application the AppSwitch corresponds with
  final String packageName;
  // Whether the app should be excluded from the VPN connection
  bool isExcluded;

  AppSwitch({required this.packageName, required this.isExcluded});

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  // Whether this switch is on or off
  bool light = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // If an app has previously been excluded from the VPN connection by a user,
      // the switch is turned on by default
      value: light || widget.isExcluded,
      activeColor: Colors.lightBlue,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
          if (value) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Tunneling'),
      ),
      body: appsList(context),
    );
  }


  Widget buildAppListItem(AppData appData, bool isExcluded) {
    Uint8List bytes = base64.decode(appData.icon);
    
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.all(4),
      leading: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 44,
          minHeight: 44,
          maxWidth: 64,
          maxHeight: 64,
        ),
        child: new Image.memory(bytes, fit: BoxFit.cover),
      ),
      trailing: AppSwitch(packageName: appData.packageName, isExcluded: isExcluded),
      title: CText(
        toBeginningOfSentenceCase(
        appData.name)!,
        style: tsBody1,
      ),
    );
  }

  // appsList builds a ListView that contains all application packages installed for
  // the current user along with a set of apps to exclude from the VPN connection
  Widget appsList(BuildContext context) {
    return sessionModel
          .appsData((BuildContext context, AppsData appsData, Widget? child) {
          return ListView.builder(
            itemCount: appsData.appsList.length,
            itemBuilder: (BuildContext context, int index) {
              var appData = appsData.appsList[index];
              bool isExcluded = appsData.excludedApps.excludedApps[appData.packageName] ?? false;
              return buildAppListItem(appData, isExcluded);
            },
          );
      });
  }
}
