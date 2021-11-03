import '../messaging.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
      title: 'lantern_secure_chat'.i18n,
      body: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          const CAssetImage(path: ImagePaths.image_inactive, size: 250),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: CText('Welcome to Lantern Secure Chat!'.i18n,
                style: tsHeading1),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: CText(
                'Lantern Secure Chat pairs the strongest encryption and security practices with best-in-class blocking resistant technology to ensure your chats are private and always accessible. To start using Lantern chat, click get started below!'
                    .i18n,
                style: tsBody1),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: Button(
              text: 'Get Started'.i18n,
              width: 200.0,
              onPressed: () => context.router.push(const SecureChatNumber()),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: CText('Have an Secure Chat Number?'.i18n.toUpperCase(),
                      style: tsBody2),
                ),
                TextButton(
                    onPressed: () => context.router.push(const Recovery()),
                    child: CText('Recover'.i18n.toUpperCase(),
                        style: tsBody2.copiedWith(
                            color: pink4, fontWeight: FontWeight.w500)))
              ],
            ),
          )
        ],
      ),
    );
  }
}
