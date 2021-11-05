import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/account.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'settings_item.dart';
import 'settings_section_header.dart';

class AccountManagement extends StatelessWidget {
  AccountManagement({Key? key, required this.isPro}) : super(key: key);
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
    var messagingModel = context.watch<MessagingModel>();
    var title =
        isPro ? 'Pro Account Management'.i18n : 'Account Management'.i18n;

    return BaseScreen(
      title: title,
      body: sessionModel
          .deviceId((BuildContext context, String myDeviceId, Widget? child) {
        return sessionModel
            .devices((BuildContext context, Devices devices, Widget? child) {
          var proItems = [
            SettingsSectionHeader(
              label: 'Email'.i18n,
            ),
            sessionModel.emailAddress(
                (BuildContext context, String emailAddress, Widget? child) {
              return SettingsItem(
                icon: ImagePaths.email,
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
                icon: ImagePaths.clock,
                title: expirationDate,
                onTap: () {
                  LanternNavigator.startScreen(LanternNavigator.SCREEN_PLANS);
                },
                child: CText('Renew'.i18n.toUpperCase(), style: tsButtonPink),
              );
            }),
            SettingsSectionHeader(
              label: 'pro_devices_header'.i18n,
            )
          ];

          proItems.addAll(devices.devices.map((device) {
            var isMyDevice = device.id == myDeviceId;
            var allowRemoval = devices.devices.length > 1 || !isMyDevice;

            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: SettingsItem(
                title: device.name,
                onTap: !allowRemoval
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: CText('confirm_remove_device'.i18n,
                                  style: tsBody1),
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
                                    context.loaderOverlay.show(widget: spinner);
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
              ),
            );
          }));

          if (devices.devices.length < 3) {
            proItems.add(SettingsItem(
              title: '',
              onTap: () async => await context.pushRoute(ApproveDevice()),
              child:
                  CText('Add Device'.i18n.toUpperCase(), style: tsButtonPink),
            ));
          }

          return ListView(
              padding: const EdgeInsetsDirectional.only(
                bottom: 8,
              ),
              children: [
                SettingsSectionHeader(
                  label: 'secure_chat_number'.i18n,
                ),
                messagingModel.me(
                    (BuildContext context, Contact me, Widget? child) =>
                        SettingsItem(
                          icon: ImagePaths.chatNumber,
                          iconColor: Colors.black,
                          title: me.chatNumber.shortNumber,
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsetsDirectional.only(end: 16.0),
                                child: CAssetImage(
                                  path: ImagePaths.content_copy,
                                ),
                              ),
                              const CAssetImage(
                                path: ImagePaths.arrow_down,
                              ),
                            ],
                          ),
                          onTap: () {}, // TODO: expand
                        )),
                SettingsSectionHeader(
                  label: 'backup_recovery_key'.i18n,
                ),
                messagingModel.getCopiedRecoveryStatus((BuildContext context,
                        bool hasCopiedRecoveryKey, Widget? child) =>
                    SettingsItem(
                      icon: ImagePaths.lock_outline,
                      iconColor: Colors.black,
                      title: 'recovery_key'.i18n,
                      showArrow: true,
                      child: CBadge(
                        customPadding: const EdgeInsets.all(6.0),
                        fontSize: 14,
                        showBadge: !hasCopiedRecoveryKey,
                        count: 1,
                      ),
                      onTap: () => context.router.push(RecoveryKey()),
                    )),
                if (isPro) ...proItems
              ]);
        });
      }),
    );
  }
}
