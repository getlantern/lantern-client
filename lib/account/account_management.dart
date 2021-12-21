import 'package:lantern/messaging/messaging.dart';

class AccountManagement extends StatefulWidget {
  AccountManagement({Key? key, required this.isPro}) : super(key: key);
  final bool isPro;

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

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

  @override
  Widget build(BuildContext context) {
    var title = widget.isPro
        ? 'Pro Account Management'.i18n
        : 'Account Management'.i18n;
    var textCopied = false;

    return BaseScreen(
      title: title,
      padHorizontal: false,
      body: sessionModel
          .deviceId((BuildContext context, String myDeviceId, Widget? child) {
        var freeItems = [
          // * SECURE CHAT NUMBER
          messagingModel.me(
            (BuildContext context, Contact me, Widget? child) =>
                StatefulBuilder(
              builder: (context, setState) => ListItemFactory.settingsItem(
                header: 'your_secure_chat_number'.i18n,
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
                onTap: () =>
                    context.router.push(const SecureChatNumberAccount()),
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
                  onPressed: () =>
                      showDeleteDataDialog(context, messagingModel),
                  child: CText(
                    'Delete'.i18n.toUpperCase(),
                    style: tsButtonPink,
                  ),
                ),
              ),
            ],
          )
        ];

        return !widget.isPro
            ?
            // * FREE
            ListView(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  bottom: 8,
                ),
                children: freeItems,
              )
            :
            // * PRO - check onboarding status
            messagingModel
                .getOnBoardingStatus((context, hasBeenOnboarded, child) {
                return sessionModel.devices(
                    (BuildContext context, Devices devices, Widget? child) {
                  var proItems = [
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
                    sessionModel.expiryDate((
                      BuildContext context,
                      String expirationDate,
                      Widget? child,
                    ) {
                      return ListItemFactory.settingsItem(
                        header: 'Pro Account Expiration'.i18n,
                        icon: ImagePaths.clock,
                        content: expirationDate,
                        onTap: () {
                          LanternNavigator.startScreen(
                            LanternNavigator.SCREEN_PLANS,
                          );
                        },
                        trailingArray: [
                          CText('Renew'.i18n.toUpperCase(), style: tsButtonPink)
                        ],
                      );
                    }),
                  ];

                  proItems.addAll(
                    devices.devices.map((device) {
                      var isMyDevice = device.id == myDeviceId;
                      var allowRemoval =
                          devices.devices.length > 1 || !isMyDevice;
                      var index =
                          devices.devices.indexWhere((d) => d == device);

                      return Padding(
                        padding: const EdgeInsetsDirectional.only(start: 4),
                        child: ListItemFactory.settingsItem(
                          header: index == 0 ? 'pro_devices_header'.i18n : null,
                          content: device.name,
                          onTap: !allowRemoval
                              ? null
                              : () {
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
                                            onPressed: () {
                                              context.loaderOverlay
                                                  .show(widget: spinner);
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
                                    style: tsButtonPink,
                                  )
                                ],
                        ),
                      );
                    }),
                  );

                  if (devices.devices.length < 3) {
                    proItems.add(
                      ListItemFactory.settingsItem(
                        content: '',
                        onTap: () async =>
                            await context.pushRoute(ApproveDevice()),
                        trailingArray: [
                          CText(
                            'Link Device'.i18n.toUpperCase(),
                            style: tsButtonPink,
                          )
                        ],
                      ),
                    );
                  }
                  return hasBeenOnboarded == true
                      // * has been onboarded
                      ? Column(
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
                                  text: 'secure_chat'.i18n.toUpperCase(),
                                ),
                              ],
                            ),
                            const CDivider(),
                            Expanded(
                              child: TabBarView(
                                controller: tabController,
                                children: [
                                  // * PRO TAB
                                  ListView(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 16,
                                      end: 16,
                                      bottom: 8,
                                    ),
                                    children: proItems,
                                  ),
                                  // * SECURE CHAT TAB
                                  ListView(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 16,
                                      end: 16,
                                      bottom: 8,
                                    ),
                                    children: freeItems,
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      // * has not been onboarded
                      : Column(
                          children: [
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 16,
                                  end: 16,
                                  bottom: 8,
                                ),
                                children: proItems,
                              ),
                            ),
                          ],
                        );
                });
              });
      }),
    );
  }
}

void showDeleteDataDialog(
  BuildContext context,
  MessagingModel model,
) async {
  var confirmDelete = false;
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: const EdgeInsetsDirectional.all(0),
          // <--- this padding is different from what we use by default in our showInfoDialog since the checkbox inserts a padding by default, so its best to add individual paddings to the Column children as opposed to a global one
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding:
                      EdgeInsetsDirectional.only(start: 24, end: 24, top: 24.0),
                  child: CAssetImage(
                    path: ImagePaths.account_remove,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 16,
                    bottom: 8,
                    start: 24,
                    end: 24,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: CText('delete_chat_data'.i18n, style: tsSubtitle1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8,
                    bottom: 16,
                    start: 24,
                    end: 24,
                  ),
                  child: CText(
                    'delete_chat_data_description'.i18n,
                    style: tsBody1.copiedWith(color: grey5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        visualDensity: VisualDensity.compact,
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(2.0)),
                        ),
                        checkColor: Colors.white,
                        fillColor: MaterialStateProperty.resolveWith(
                          (states) => getCheckboxFillColor(black, states),
                        ),
                        value: confirmDelete,
                        onChanged: (bool? value) {
                          setState(() => confirmDelete = value!);
                        },
                      ),
                      Expanded(
                        child: CText(
                          'delete_chat_data_confirmation'.i18n,
                          style: tsBody1,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 24.0),
                  child: TextButton(
                    onPressed: () async => context.router.pop(),
                    child:
                        CText('cancel'.i18n.toUpperCase(), style: tsButtonGrey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 24.0),
                  child: CInkWell(
                    onTap: () async {
                      if (!confirmDelete) return;
                      await model.wipeData();
                      await context.router.pop();
                    },
                    child: CText(
                      'Delete'.i18n.toUpperCase(),
                      style: confirmDelete ? tsButtonPink : tsButtonGrey,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    },
  );
}
