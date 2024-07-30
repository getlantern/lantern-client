import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/plans/utils.dart';

@RoutePage<void>(name: 'AccountManagement')
class AccountManagement extends StatefulWidget {
  const AccountManagement({Key? key, required this.isPro}) : super(key: key);
  final bool isPro;

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  bool textCopied = false;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  void openChangeEmail(String emailAddress) {
    context.router.push(ChangeEmail(email: emailAddress));
  }

  void openEmailVerification(String emailAddress) {
    sessionModel.signUpEmailResendCode(emailAddress);
    context
        .pushRoute(
            Verification(email: emailAddress, authFlow: AuthFlow.verifyEmail))
        .then((value) => setState(() {}));
  }

  void showDeleteAccountDialog() {
    final passwordFormKey = GlobalKey<FormState>();
    late final passwordController = CustomTextEditingController(
      formKey: passwordFormKey,
      validator: (value) {
        if (value!.isEmpty) {
          return 'password_cannot_be_empty'.i18n;
        }
        if (value.length < 8) {
          return 'password_must_be_at_least_8_characters'.i18n;
        }
        return null;
      },
    );
    CDialog(
      icon: CAssetImage(
        path: ImagePaths.alert,
        size: 24,
        color: red,
      ),
      title: 'delete_your_account'.i18n,
      description: Column(
        children: [
          CText(
            "delete_account_message".i18n,
            style: tsBody1.copiedWith(
              color: grey5,
            ),
          ),
          const SizedBox(height: 16.0),
          CPasswordTextFiled(
            label: "enter_password".i18n,
            passwordFormKey: passwordFormKey,
            passwordCustomTextEditingController: passwordController,
          ),
          const SizedBox(height: 16.0),
        ],
      ),
      agreeText: 'cancel'.i18n,
      dismissText: "confirm_deletion".i18n,
      barrierDismissible: false,
      autoCloseOnDismiss: false,
      agreeAction: () async {
        return true;
      },
      dismissAction: () async {
        if (passwordController.text.length < 8) {
          return;
        }
        Future.delayed(const Duration(milliseconds: 200),
            () => deleteAccount(passwordController.text));
      },
    ).show(context);
  }

  Future<void> deleteAccount(String password) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.deleteAccount(password);
      context.loaderOverlay.hide();
      showAccountDeletedDialog();
    } catch (e) {
      context.loaderOverlay.hide();
      mainLogger.e("Error while deleting account", error: e);
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  void showAccountDeletedDialog() {
    CDialog(
      iconPath: ImagePaths.check_green_large,
      title: "account_deleted".i18n,
      description: "account_deleted_message".i18n,
      barrierDismissible: false,
      includeCancel: false,
      agreeAction: () async {
        Future.delayed(const Duration(milliseconds: 300), () {
          context.router.popUntilRoot();
        });
        return true;
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.isPro
        ? 'Pro Account Management'.i18n
        : 'account_management'.i18n;

    return BaseScreen(
        title: title,
        padHorizontal: false,
        body: !widget.isPro
            ? freeItemsWidget()
            : sessionModel.chatEnabled(
                (context, chatEnabled, child) {
                  return messagingModel
                      .getOnBoardingStatus((context, hasBeenOnboarded, child) {
                    return (hasBeenOnboarded == true) && chatEnabled
                        ? _buildTapBar()
                        : _buildProItem();
                  });
                },
              ));
  }

  Widget _buildTapBar() {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            border: Border(
              top: BorderSide.none,
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide(width: 3.0, color: pink4),
            ),
          ),
          labelStyle: tsSubtitle2,
          labelColor: pink4,
          unselectedLabelStyle: tsBody1,
          unselectedLabelColor: grey5,
          tabs: [
            Tab(
              text: 'Lantern Pro'.i18n.toUpperCase(),
            ),
            Tab(
              text: 'chat'.i18n.toUpperCase(),
            ),
          ],
        ),
        const CDivider(),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              // * PRO TAB
              _buildProItem(),
              // * SECURE CHAT TAB
              freeItemsWidget(),
            ],
          ),
        )
      ],
    );
  }

  Widget freeItemsWidget() {
    return ListView(
      key: const ValueKey('account_management_free_list'),
      padding: const EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        bottom: 8,
      ),
      children: [
        messagingModel.me(
          (BuildContext context, Contact me, Widget? child) => StatefulBuilder(
            builder: (context, setState) => ListItemFactory.settingsItem(
              header: 'your_chat_number'.i18n,
              icon: ImagePaths.chatNumber,
              content: me.chatNumber.shortNumber.formattedChatNumber,
              trailingArray: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 16.0,
                    end: 16.0,
                  ),
                  child: CInkWell(
                    onTap: () async {
                      copyText(
                        context,
                        me.chatNumber.shortNumber.formattedChatNumber,
                      );
                      setState(() => textCopied = true);
                      await Future.delayed(
                        defaultAnimationDuration,
                        () => setState(() => textCopied = false),
                      );
                    },
                    child: CAssetImage(
                      path: textCopied
                          ? ImagePaths.check_green
                          : ImagePaths.content_copy,
                    ),
                  ),
                ),
                mirrorLTR(
                  context: context,
                  child: const ContinueArrow(),
                ),
              ],
              onTap: () => context.router.push(const ChatNumberAccount()),
            ),
          ),
        ),
        // * RECOVERY KEY
        messagingModel.getCopiedRecoveryStatus(
          (
            BuildContext context,
            bool hasCopiedRecoveryKey,
            Widget? child,
          ) =>
              ListItemFactory.settingsItem(
            icon: ImagePaths.lock_outline,
            content: 'backup_recovery_key'.i18n,
            trailingArray: [
              if (!hasCopiedRecoveryKey)
                const Padding(
                  padding: EdgeInsetsDirectional.only(start: 16.0, end: 16.0),
                  child: CAssetImage(
                    path: ImagePaths.badge,
                  ),
                ),
              mirrorLTR(context: context, child: const ContinueArrow())
            ],
            onTap: () => context.router.push(RecoveryKey()),
          ),
        ),
        // * Delete all Chat data
        ListItemFactory.settingsItem(
          icon: ImagePaths.account_remove,
          content: 'delete_chat_data'.i18n,
          trailingArray: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16.0),
              child: TextButton(
                onPressed: () => CDialog(
                  iconPath: ImagePaths.account_remove,
                  title: 'delete_chat_data'.i18n,
                  description: 'delete_chat_data_description'.i18n,
                  checkboxLabel: 'delete_chat_data_confirmation'.i18n,
                  agreeText: 'delete'.i18n,
                  agreeAction: () async {
                    await messagingModel.wipeData();
                    await context.router.pop();
                    return true;
                  },
                ).show(context),
                child: CText(
                  'delete'.i18n.toUpperCase(),
                  style: tsButtonPink,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildProItem() {
    return ListView(
      padding: const EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        bottom: 8,
      ),
      children: [
        sessionModel.emailAddress((
          BuildContext context,
          String emailAddress,
          Widget? child,
        ) {
          return ListItemFactory.settingsItem(
            header: 'lantern_pro_email'.i18n,
            icon: ImagePaths.email,
            content: emailAddress,
            trailingArray: [],
          );
        }),

        if( sessionModel.isAuthEnabled.value! && !Platform.isAndroid)
        ListItemFactory.settingsItem(
          header: 'password'.i18n,
          icon: ImagePaths.lockFiled,
          content: "********",
        ),
        sessionModel.expiryDate((
          BuildContext context,
          String expirationDate,
          Widget? child,
        ) {
          return ListItemFactory.settingsItem(
            key: AppKeys.account_renew,
            header: 'Pro Account Expiration'.i18n,
            icon: ImagePaths.clock,
            content: expirationDate,
            onTap: () async {
              await context.pushRoute(const PlansPage());
            },
            trailingArray: [
              CText('Renew'.i18n.toUpperCase(), style: tsButtonPink)
            ],
          );
        }),
        //Disable device linking in IOS
        const UserDevices(),
        if(sessionModel.isAuthEnabled.value! && !Platform.isAndroid)
        ListItemFactory.settingsItem(
          header: 'danger_zone'.i18n,
          icon: ImagePaths.alert,
          content: "delete_account".i18n,
          trailingArray: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16.0),
              child: TextButton(
                onPressed: showDeleteAccountDialog,
                child: CText(
                  'delete'.i18n.toUpperCase(),
                  style: tsButtonPink,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<void> onUnlink(BuildContext context, String deviceId) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.removeDevice(deviceId);
      context.loaderOverlay.hide();
      context.popRoute();
    } catch (e) {
      context.loaderOverlay.hide();
      showError(context, error: e);
    }
  }
}

class UserDevices extends StatelessWidget {
  const UserDevices({super.key});

  void onRemoveTap(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: CText(
            'confirm_remove_device'.i18n,
            style: tsBody1,
          ),
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
              onPressed: () => onUnlink(context, device.id),
              child: CText(
                'Yes'.i18n,
                style: tsButtonPink,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onUnlink(BuildContext context, String deviceId) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.removeDevice(deviceId);
      context.loaderOverlay.hide();
      context.popRoute();
    } catch (e) {
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return sessionModel.deviceId((context, myDeviceId, child) => sessionModel
            .devices((BuildContext context, Devices devices, Widget? child) {
          return Column(children: [
            ...devices.devices.map<Widget>((device) {
              var isMyDevice = device.id == myDeviceId;
              print('Device: ${device.id} isMyDevice: $myDeviceId');
              var allowRemoval = devices.devices.length > 1 || !isMyDevice;
              var index = devices.devices.indexWhere((d) => d == device);
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 4),
                child: ListItemFactory.settingsItem(
                  header: index == 0 ? 'pro_devices_header'.i18n : null,
                  content: device.name,
                  onTap:
                      !allowRemoval ? null : () => onRemoveTap(context, device),
                  trailingArray: !allowRemoval
                      ? []
                      : [
                          CText(
                            (isMyDevice ? '' : 'Remove').i18n.toUpperCase(),
                            style: tsButtonPink,
                          )
                        ],
                ),
              );
            }).toList(),
            // IOS does not need device linking
            // User should use Username and Password flow
            if (devices.devices.length < 3)
              ListItemFactory.settingsItem(
                content: '',
                onTap: () async => await context.pushRoute(ApproveDevice()),
                trailingArray: [
                  CText(
                    'link_device'.i18n.toUpperCase(),
                    style: tsButtonPink,
                  )
                ],
              )
          ]);
        }));
  }
}
