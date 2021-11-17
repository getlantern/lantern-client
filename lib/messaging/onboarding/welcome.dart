import '../messaging.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'lantern_secure_chat'.i18n,
      automaticallyImplyLeading: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: 16.0),
              child: CAssetImage(path: ImagePaths.placeholder, size: 300),
            ),
          ),
          Flex(
            direction: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    top: 16.0, bottom: 16.0, start: 24.0, end: 24.0),
                child: CText('welcome_title'.i18n, style: tsSubtitle1),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    top: 16.0, bottom: 16.0, start: 24.0, end: 24.0),
                child: CText('welcome_text'.i18n,
                    style: tsBody1.copiedWith(color: grey5)),
              ),
              Button(
                  text: 'get_started'.i18n,
                  width: 200.0,
                  onPressed: () async {
                    await model.start();
                    await context.router
                        .push(const SecureChatNumberMessaging());
                  }),
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: CText('want_to_recover'.i18n, style: tsBody2),
                    ),
                    TextButton(
                        onPressed: () =>
                            context.router.push(const SecureNumberRecovery()),
                        child: CText('recover'.i18n.toUpperCase(),
                            style: tsBody2.copiedWith(
                                fontSize: 14,
                                color: pink4,
                                fontWeight: FontWeight.w500)))
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
