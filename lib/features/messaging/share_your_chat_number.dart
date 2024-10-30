import 'package:lantern/features/messaging/messaging.dart';
import 'package:share_plus/share_plus.dart';

class ShareYourChatNumber {
  ShareYourChatNumber(this.me);

  final Contact me;

  final icon = ImagePaths.share;

  final leading = const CAssetImage(
    path: ImagePaths.share,
  );

  Future<void> share() {
    return Share.share(me.chatNumber.shortNumber.formattedChatNumber);
  }

  Widget get content => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CText('share_your_chat_number'.i18n, style: tsSubtitle1Short),
          CText(
            me.chatNumber.shortNumber.formattedChatNumber,
            style: tsBody1.copiedWith(color: grey5),
          )
        ],
      );

  Widget get messagingItem => ListItemFactory.messagingItem(
        leading: leading,
        content: content,
        trailingArray: [const ContinueArrow()],
        onTap: share,
      );

  Widget get bottomItem => ListItemFactory.bottomItem(
        icon: icon,
        content: content,
        onTap: share,
        height: null,
      );
}
