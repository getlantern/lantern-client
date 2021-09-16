import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/account.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'settings_item.dart';
import 'settings_section_header.dart';

class ProAccount extends StatelessWidget {
  ProAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'pro_account_management'.i18n,
      body: sessionModel
          .deviceId((BuildContext context, String myDeviceId, Widget? child) {
        return sessionModel
            .devices((BuildContext context, Devices devices, Widget? child) {
          var items = [
            SettingsSectionHeader(
              label: 'Email'.i18n,
            ),
            sessionModel.emailAddress(
                (BuildContext context, String emailAddress, Widget? child) {
              return SettingsItem(
                icon: ImagePaths.email_icon,
                iconColor: Colors.black,
                title: emailAddress,
              );
            }),
            SettingsSectionHeader(
              label: 'Pro Account Expiration'.i18n,
            ),
            sessionModel.expiryDate(
                (BuildContext context, String expirationDate, Widget? child) {
              return SettingsItem(
                icon: ImagePaths.clock_icon,
                title: expirationDate,
                onTap: () {
                  LanternNavigator.startScreen(LanternNavigator.SCREEN_PLANS);
                },
                child: CText('Renew'.i18n.toUpperCase(),
                    style: tsButtonPinkSecondary),
              );
            }),
            SettingsSectionHeader(
              label: 'pro_devices_header'.i18n,
            )
          ];

          items.addAll(devices.devices.map((device) {
            var isMyDevice = device.id == myDeviceId;
            var allowRemoval = devices.devices.length > 1 || !isMyDevice;

            return SettingsItem(
              title: device.name,
              onTap: !allowRemoval
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: CText('confirm_remove_device'.i18n,
                                style: tsDialogBody),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: CText(
                                  'No'.i18n,
                                  style: tsButtonGrey,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.loaderOverlay.show();
                                  sessionModel
                                      .removeDevice(device.id)
                                      .then((value) {
                                    context.loaderOverlay.hide();
                                    Navigator.pop(context);
                                  }).onError((error, stackTrace) {
                                    context.loaderOverlay.hide();
                                  });
                                },
                                child: CText(
                                  'Yes'.i18n,
                                  style: tsButtonPink,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
              child: !allowRemoval
                  ? null
                  : CText(
                      (isMyDevice ? 'Log Out' : 'Remove').i18n.toUpperCase(),
                      style: tsButtonPink),
            );
          }));

          if (devices.devices.length < 3) {
            items.add(SettingsItem(
              title: '',
              onTap: () async => await context.pushRoute(ApproveDevice()),
              child:
                  CText('Add Device'.i18n.toUpperCase(), style: tsButtonPink),
            ));
          }

          return ListView(
            padding: const EdgeInsetsDirectional.only(
              bottom: 8,
              start: 20,
              end: 20,
            ),
            children: items,
          );
        });
      }),
    );
  }
}
