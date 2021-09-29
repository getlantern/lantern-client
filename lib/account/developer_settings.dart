import 'package:lantern/account/account.dart';

import 'settings_item.dart';

class DeveloperSettingsTab extends StatelessWidget {
  DeveloperSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'dev_settings'.i18n,
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
          SettingsItem(
            title: 'payment_test_mode',
            child: sessionModel.paymentTestMode(
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
            }),
          ),
          SettingsItem(
            title: 'play_version'.i18n,
            child: sessionModel
                .playVersion((BuildContext context, bool value, Widget? child) {
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
            }),
          ),
          SettingsItem(
            title: 'force_country'.i18n,
            child: sessionModel.forceCountry(
                (BuildContext context, String value, Widget? child) {
              return DropdownButton<String>(
                value: value,
                icon: const Icon(Icons.arrow_downward),
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
            }),
          ),
        ],
      ),
    );
  }
}
