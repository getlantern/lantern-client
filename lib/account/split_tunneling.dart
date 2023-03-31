import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:flutter/foundation.dart';

class SplitTunnelingSwitch extends StatefulWidget {
  // Whether split tunneling is enabled
  bool splitTunnelingEnabled;

  SplitTunnelingSwitch({required this.splitTunnelingEnabled});

  @override
  State<SplitTunnelingSwitch> createState() => _SplitTunnelingSwitch();
}

class _SplitTunnelingSwitch extends State<SplitTunnelingSwitch> {
  bool splitTunnelingEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: splitTunnelingEnabled,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          splitTunnelingEnabled = value;
          sessionModel.setSplitTunneling(value);
        });
      },
    );
  }
}

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
      Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.white;
      }
      return Colors.green;
    }
    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('split_tunneling'.i18n),
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
      trailing: AppCheckmark(packageName: appData.packageName, isExcluded: isExcluded),
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
    return sessionModel.splitTunnelingEnabled((BuildContext context, bool value, Widget? child) {
      if (!value) {
        return Row(children: <Widget>[
          CText('split_tunneling_info'.i18n,
           style: CTextStyle(
                fontSize: 14,
                lineHeight: 21,
                color: black,
              )),
          SplitTunnelingSwitch(splitTunnelingEnabled: value),
        ]);
      }
      return sessionModel.appsData((BuildContext context, AppsData appsData, Widget? child) {
        return ListView.builder(
          itemCount: appsData.appsList.length,
          itemBuilder: (BuildContext context, int index) {
            var appData = appsData.appsList[index];
            bool isExcluded = appsData.excludedApps.excludedApps[appData.packageName] ?? false;
            return buildAppListItem(appData, isExcluded);
          });
      });
    });
  }
}
