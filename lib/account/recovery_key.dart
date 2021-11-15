import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging.dart';

class RecoveryKey extends StatelessWidget {
  RecoveryKey({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var doBackup = true;
    var model = context.watch<MessagingModel>();
    return model
        .me((BuildContext context, Contact me, Widget? child) => BaseScreen(
            title: 'recovery_key'.i18n,
            body: PinnedButtonLayout(
                content: [
                  Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 16.0, end: 16.0, top: 32.0, bottom: 16.0),
                      child: FutureBuilder(
                          future: model.getRecoveryCode(),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const Center(
                                    child: CircularProgressIndicator());
                              default:
                                if (snapshot.hasError) {
                                  return CText('recovery_retrieval_error'.i18n,
                                      style: tsCodeDisplay1);
                                } else {
                                  return CText(
                                      humanizeLongString(
                                              snapshot.data.toString())
                                          .toString()
                                          .toUpperCase(),
                                      style: tsCodeDisplay1);
                                }
                            }
                          })),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 4.0, end: 4.0, top: 16.0, bottom: 16.0),
                    child: CText('recovery_key_account_explanation'.i18n,
                        style: tsBody1.copiedWith(color: grey5)),
                  ),
                  const CDivider(),
                  StatefulBuilder(
                      builder: (context, setState) =>
                          ListItemFactory.settingsItem(
                            onTap: () => showInfoDialog(
                              context,
                              title: 'automated_backup'.i18n,
                              assetPath: ImagePaths.backup,
                              des: 'backup_explanation'.i18n,
                              popParentContext: false,
                            ),
                            icon: ImagePaths.backup_icon,
                            content: Row(
                              children: [
                                CText(
                                  'backup_contacts'.i18n,
                                  style: tsSubtitle1Short,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 4.0),
                                  child: Icon(
                                    Icons.info,
                                    size: 14,
                                    color: black,
                                  ),
                                )
                              ],
                            ),
                            trailingArray: [
                              Checkbox(
                                side: BorderSide(color: black, width: 2.0),
                                checkColor: white,
                                fillColor: MaterialStateProperty.resolveWith(
                                    (states) => getCheckboxFillColor(
                                        indicatorGreen, states)),
                                value: doBackup,
                                shape:
                                    const CircleBorder(side: BorderSide.none),
                                onChanged: (bool? value) =>
                                    setState(() => doBackup = value!),
                              )
                            ],
                          )),
                ],
                button: Button(
                  text: 'copy_recovery_key'.i18n,
                  width: 200.0,
                  onPressed: () {
                    model.markCopiedRecoveryKey();
                    copyText(
                        context,
                        me.chatNumber
                            .number); // TODO: this should be recovery key
                    context.router.pop();
                  },
                ))));
  }
}
