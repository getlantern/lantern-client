import 'package:lantern/features/messaging/messaging.dart';

@RoutePage(name: 'RecoveryKey')
class RecoveryKey extends StatelessWidget {
  RecoveryKey({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return messagingModel.me(
      (BuildContext context, Contact me, Widget? child) => BaseScreen(
        title: 'recovery_key'.i18n,
        body: FutureBuilder<String>(
          future: messagingModel.getRecoveryCode(),
          builder: (context, snapshot) {
            return PinnedButtonLayout(
              content: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 8.0,
                    end: 8.0,
                    top: 32.0,
                    bottom: 16.0,
                  ),
                  child: buildContent(context, snapshot),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 4.0,
                    end: 4.0,
                    top: 16.0,
                    bottom: 16.0,
                  ),
                  child: CText(
                    'recovery_key_account_explanation'.i18n,
                    style: tsBody1.copiedWith(color: grey5),
                  ),
                ),
              ],
              button: Button(
                text: 'copy_recovery_key'.i18n,
                disabled: snapshot.hasError,
                onPressed: () async {
                  await messagingModel.markCopiedRecoveryKey();
                  copyText(context, snapshot.data.toString());
                  await context.router.maybePop();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context, AsyncSnapshot<String> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return const Center(child: CircularProgressIndicator());
      default:
        if (snapshot.hasError) {
          return CText('recovery_retrieval_error'.i18n, style: tsCodeDisplay1);
        } else {
          return CText(snapshot.data.toString().spaced, style: tsCodeDisplay1);
        }
    }
  }
}
