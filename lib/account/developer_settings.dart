import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging.dart';

class DeveloperSettingsTab extends StatelessWidget {
  DeveloperSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Developer Settings'.i18n,
      padVertical: true,
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 16.0),
            child: CText(
              'dev_settings'.i18n,
              style: tsBody3,
            ),
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 16.0),
            child: CText('dev_payment_mode'.i18n, style: tsBody3),
          ),
          ListItemFactory.settingsItem(
            content: 'Payment Test Mode'.i18n,
            trailingArray: [
              sessionModel.paymentTestMode(
                  (BuildContext context, bool value, Widget? child) {
                return FlutterSwitch(
                  width: 44.0,
                  height: 24.0,
                  valueFontSize: 12.0,
                  padding: 2,
                  toggleSize: 18.0,
                  value: value,
                  onToggle: (bool newValue) {
                    sessionModel.setPaymentTestMode(newValue);
                  },
                );
              })
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Play Version'.i18n,
            trailingArray: [
              sessionModel.playVersion(
                  (BuildContext context, bool value, Widget? child) {
                return FlutterSwitch(
                  width: 44.0,
                  height: 24.0,
                  valueFontSize: 12.0,
                  padding: 2,
                  toggleSize: 18.0,
                  value: value,
                  onToggle: (bool newValue) {
                    sessionModel.setPlayVersion(newValue);
                  },
                );
              })
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Force Country'.i18n,
            trailingArray: [
              sessionModel.forceCountry(
                  (BuildContext context, String value, Widget? child) {
                return DropdownButton<String>(
                  value: value,
                  icon: const CAssetImage(path: ImagePaths.arrow_down),
                  iconSize: iconSize,
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    sessionModel
                        .setForceCountry(newValue == '' ? null : newValue);
                  },
                  items: <String>['', 'CN', 'IR', 'US']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: CText(value, style: tsBody1),
                    );
                  }).toList(),
                );
              })
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Reset all timestamps',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.resetTimestamps();
                  },
                  child: CText('Reset'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Reset onboarding and recovery key flags',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.resetFlags();
                  },
                  child: CText('Reset'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Start messaging',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.start();
                  },
                  child: CText('start'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Kill messaging',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.kill();
                  },
                  child: CText('kill'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
          ListItemFactory.settingsItem(
            content: 'Wipe data and restart',
            trailingArray: [
              TextButton(
                  onPressed: () async {
                    await messagingModel.wipeData();
                  },
                  child: CText('Wipe'.toUpperCase(),
                      style:
                          tsButton.copiedWith(color: Colors.deepPurpleAccent)))
            ],
          ),
        ],
      ),
    );
  }
}
