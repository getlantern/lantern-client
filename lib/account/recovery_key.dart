import 'package:lantern/account/account.dart';

class RecoveryKey extends StatelessWidget {
  RecoveryKey({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var doBackup = true;
    var dummyKey =
        'jkrb-bfgy-m19y-z79s-axym-4mfq-xbhz-xtnd-f1r9-1m76-1gyr-upci-14x5-asgr-y4x6-czsc-wkak-gw47-6q7m-udzg-sug1-83t4-66n1-w4eL-kqr';
    return BaseScreen(
        title: 'recovery_key'.i18n,
        body: PinnedButtonLayout(
            content: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 16.0, end: 16.0, top: 32.0, bottom: 16.0),
                child: CText(
                    dummyKey // TODO: render actual recovery key
                        .toUpperCase(),
                    style: tsBody1.copiedWith(
                      // TODO: update to Mono font
                      fontSize: 20,
                      lineHeight: 32,
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
                child: CText('recovery_key_account_explanation'.i18n,
                    style: tsBody1.copiedWith(color: grey5)),
              ),
              const CDivider(),
              StatefulBuilder(
                  builder: (context, setState) => CListTile(
                        onTap: () => showInfoDialog(
                          context,
                          title: 'automated_backup'.i18n,
                          assetPath: ImagePaths.backup,
                          des: 'backup_explanation'.i18n,
                          popParentContext: false,
                        ),
                        leading: const CAssetImage(
                          path: ImagePaths.backup_icon,
                        ),
                        content: Row(
                          children: [
                            CText(
                              'backup_contacts'.i18n,
                              style: tsSubtitle1Short,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 4.0),
                              child: Icon(
                                Icons.info,
                                size: 14,
                                color: black,
                              ),
                            )
                          ],
                        ),
                        trailing: Checkbox(
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith(
                              getCheckboxColorGreen),
                          value: doBackup,
                          shape: const CircleBorder(side: BorderSide.none),
                          onChanged: (bool? value) =>
                              setState(() => doBackup = value!),
                        ),
                      )),
            ],
            button: Button(
              text: 'copy_recovery_key'.i18n,
              width: 200.0,
              onPressed: () {
                // TODO: mark backup as done
                copyText(context, dummyKey);
                context.router.pop();
              },
            )));
  }
}
