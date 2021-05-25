import 'package:lantern/package_store.dart';

import 'settings_item.dart';

class DeveloperSettingsTab extends StatelessWidget {
  DeveloperSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'Developer Settings'.i18n,
      body: ListView(
        padding: const EdgeInsetsDirectional.only(
          top: 2,
          bottom: 8,
          start: 20,
          end: 20,
        ),
        children: [
          SettingsItem(
            title: 'Payment Test Mode'.i18n,
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
            title: 'Play Version'.i18n,
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
            title: 'Yinbi Enabled'.i18n,
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
        ],
      ),
    );
  }
}
