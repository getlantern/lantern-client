import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
            sessionModel.emailAddress(
                (BuildContext context, String emailAddress, Widget? child) {
              return ListItemFactory.isSettingsItem(
                header: 'Email'.i18n,
                leading: CAssetImage(path: ImagePaths.email, color: black),
                content: emailAddress,
              );
            }),
            sessionModel.expiryDate(
                (BuildContext context, String expirationDate, Widget? child) {
              return ListItemFactory.isSettingsItem(
                header: 'Pro Account Expiration'.i18n,
                leading: CAssetImage(path: ImagePaths.clock, color: black),
                content: expirationDate,
                onTap: () {
                  LanternNavigator.startScreen(LanternNavigator.SCREEN_PLANS);
                },
                trailingArray: [
                  CText('Renew'.i18n.toUpperCase(), style: tsButtonPink)
                ],
              );
            }),
          ];

          proItems.addAll(devices.devices.map((device) {
            var isMyDevice = device.id == myDeviceId;
            var allowRemoval = devices.devices.length > 1 || !isMyDevice;

            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: ListItemFactory.isSettingsItem(
                header: 'pro_devices_header'.i18n,
                content: device.name,
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
                trailingArray: !allowRemoval
                    ? []
                    : [
                        CText(
                            (isMyDevice ? 'Log Out' : 'Remove')
                                .i18n
                                .toUpperCase(),
                            style: tsButtonPink)
                      ],
              ),
            );
          }));

          if (devices.devices.length < 3) {
            proItems.add(ListItemFactory.isSettingsItem(
              content: '',
              onTap: () async => await context.pushRoute(ApproveDevice()),
              trailingArray: [
                CText('Add Device'.i18n.toUpperCase(), style: tsButtonPink)
              ],
            ));
          }

          return ListView(
              padding: const EdgeInsetsDirectional.only(
                bottom: 8,
              ),
              children: [
                messagingModel.me(
                    (BuildContext context, Contact me, Widget? child) =>
                        ListItemFactory.isSettingsItem(
                          header: 'secure_chat_number'.i18n,
                          leading: CAssetImage(
                              path: ImagePaths.chatNumber, color: black),
                          content: me.chatNumber.shortNumber,
                          trailingArray: [
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
                          onTap: () {}, // TODO: expand
                        )),
                messagingModel.getCopiedRecoveryStatus((BuildContext context,
                        bool hasCopiedRecoveryKey, Widget? child) =>
                    ListItemFactory.isSettingsItem(
                      header: 'backup_recovery_key'.i18n,
                      leading: CAssetImage(
                        path: ImagePaths.lock_outline,
                        color: black,
                      ),
                      content: 'recovery_key'.i18n,
                      showTrailing: true,
                      trailingArray: [
                        CBadge(
                          customPadding: const EdgeInsets.all(6.0),
                          fontSize: 14,
                          showBadge: !hasCopiedRecoveryKey,
                          count: 1,
                        )
                      ],
                      onTap: () => context.router.push(RecoveryKey()),
                    )),
                if (isPro) ...proItems
              ]);
        });
      }),
    );
  }
}
