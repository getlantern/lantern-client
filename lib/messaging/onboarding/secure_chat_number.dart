import '../messaging.dart';

class SecureChatNumber extends StatelessWidget {
  var textCopied = false;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'secure_chat_number'.i18n,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin:
                const EdgeInsetsDirectional.only(start: 4, top: 21, bottom: 3),
            child: CText('Your Secure Chat Number'.i18n.toUpperCase(),
                maxLines: 1, style: tsOverline),
          ),
          const CDivider(),
          //* Your Secure Chat Number
          StatefulBuilder(
              builder: (context, setState) => CListTile(
                    onTap: () async {
                      copyText(
                          context, '637 5163 8576'); // TODO: use chatNumber
                      setState(() => textCopied = true);
                      await Future.delayed(defaultAnimationDuration,
                          () => setState(() => textCopied = false));
                    },
                    leading: const CAssetImage(
                      path: ImagePaths.tag,
                    ),
                    content: CText(
                      '637 5163 8576', // TODO: use chatNumber
                      style: tsSubtitle1Short,
                    ),
                    trailing: CInkWell(
                      onTap: () async {
                        copyText(
                            context, '637 5163 8576'); // TODO: use chatNumber
                        setState(() => textCopied = true);
                        await Future.delayed(defaultAnimationDuration,
                            () => setState(() => textCopied = false));
                      },
                      child: CAssetImage(
                        path: textCopied
                            ? ImagePaths.check_green
                            : ImagePaths.content_copy,
                      ),
                    ),
                  )),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: CText(
                'Your Secure Chat Number works like a phone number that your friends can use to contact you on Lantern. Lantern gives you a Secure Chat Number, so you do not have to use your phone number to chat.'
                    .i18n,
                style: tsBody1),
          ),
        ],
      ),
    );
  }
}
