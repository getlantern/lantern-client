import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging.dart';

class RecoveryKey extends StatelessWidget {
  RecoveryKey({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var doBackup = true;
    var model = context.watch<MessagingModel>();
    return model.me(
      (BuildContext context, Contact me, Widget? child) => BaseScreen(
        title: 'recovery_key'.i18n,
        body: PinnedButtonLayout(
          content: [
            Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 8.0, end: 8.0, top: 32.0, bottom: 16.0),
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
                            return CText(snapshot.data.toString().spaced,
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
          ],
          button: Button(
            text: 'copy_recovery_key'.i18n,
            width: 200.0,
            onPressed: () {
              model.markCopiedRecoveryKey();
              copyText(context,
                  me.chatNumber.number); // TODO: this should be recovery key
              context.router.pop();
            },
          ),
        ),
      ),
    );
  }
}
