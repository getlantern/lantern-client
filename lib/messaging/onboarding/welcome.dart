import '../messaging.dart';

class Welcome extends StatelessWidget {
  Welcome() : super() {
    messagingModel.dismissTryLanternChatBadge();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'lantern_chat'.i18n,
      automaticallyImplyLeading: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              padding: const EdgeInsetsDirectional.only(top: 16.0),
              child: CAssetImage(
                path: ImagePaths.welcome_illustration,
                size: MediaQuery.of(context).size.height,
              ),
            ),
          ),
          Flexible(
            flex: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: 16.0,
                    start: 24.0,
                    end: 24.0,
                  ),
                  child: CText('welcome_title'.i18n, style: tsSubtitle1),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 16.0,
                    bottom: 16.0,
                    start: 24.0,
                    end: 24.0,
                  ),
                  child: CText(
                    'welcome_text'.i18n,
                    style: tsBody1.copiedWith(color: grey5),
                    textAlign: TextAlign.center,
                  ),
                ),
                Button(
                  text: 'get_started'.i18n,
                  onPressed: () async {
                    await messagingModel.start();
                    await sessionModel.trackUserAction('New Lantern Chat');
                    await context.router.push(const ChatNumberMessaging());
                  },
                ),
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
                            context.router.push(const ChatNumberRecovery()),
                        child: CText(
                          'recover'.i18n.toUpperCase(),
                          style: tsBody2.copiedWith(
                            fontSize: 14,
                            color: pink4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
