import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:drawable/drawable.dart';

class AppSwitch extends StatefulWidget {
  final String packageName;
  bool isExcluded;

  AppSwitch ({ Key? key, this.packageName = '', this.isExcluded = false}): super(key: key);

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  bool light = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
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


class AppsProvider extends StatelessWidget {
  AppsProvider({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apps List'),
      ),
      body: getAppItems(context),
    );
  }


  Widget buildAppDataItem(AppData appData, bool isExcluded) {
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.all(4),
      trailing: AppSwitch(packageName: appData.packageName, isExcluded: isExcluded),
      title: CText(
        toBeginningOfSentenceCase(
        appData.name)!,
        style: tsBody1,
      ),
    );
  }


  Widget getAppItems(BuildContext context) {
    return sessionModel
          .appsData((BuildContext context, AppsData appsData, Widget? child) {
          debugPrint('Excluded apps ');
          appsData.excludedApps.excludedApps.forEach((k, v) => print('${k}: ${v}'));
          return ListView.builder(
            itemCount: appsData.appsList.length,
            itemBuilder: (BuildContext context, int index) {
              var appData = appsData.appsList[index];
              bool isExcluded = appsData.excludedApps.excludedApps[appData.packageName] ?? false;
              return buildAppDataItem(appData, isExcluded);
            },
          );
      });
  }
}
