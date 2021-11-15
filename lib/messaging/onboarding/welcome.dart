import '../messaging.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'lantern_secure_chat'.i18n,
      automaticallyImplyLeading: false,
      body: Column(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: 16.0),
              child: CAssetImage(path: ImagePaths.placeholder, size: 300),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: CText('welcome_title'.i18n, style: tsHeading1),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: CText('welcome_text'.i18n, style: tsBody1),
          ),
          Button(
              text: 'get_started'.i18n,
              width: 200.0,
              onPressed: () async {
                await model.start();
                await context.router.push(const SecureChatNumberMessaging());
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8.0),
                child:
                    CText('want_to_recover'.i18n.toUpperCase(), style: tsBody2),
              ),
              TextButton(
                  onPressed: () =>
                      context.router.push(const SecureNumberRecovery()),
                  child: CText('recover'.i18n.toUpperCase(),
                      style: tsBody2.copiedWith(
                          color: pink4, fontWeight: FontWeight.w500)))
            ],
          ),
        ],
      ),
    );
  }
}
