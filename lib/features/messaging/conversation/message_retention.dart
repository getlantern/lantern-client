import 'package:lantern/features/messaging/messaging.dart';

class MessageRetention extends StatelessWidget {
  const MessageRetention({
    Key? key,
    required this.contact,
  }) : super(key: key);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(top: 8, bottom: 10),
      child: FittedBox(
        fit: BoxFit.none,
        child: Container(
          decoration: BoxDecoration(
            color: white,
            border: Border.all(color: grey3),
            borderRadius: const BorderRadius.all(Radius.circular(borderRadius)),
          ),
          child: Container(
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              end: 16.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                contact.messagesDisappearAfterSeconds > 0
                    ? const CAssetImage(
                        path: ImagePaths.timer,
                        color: Colors.black,
                      )
                    : const CAssetImage(
                        path: ImagePaths.lock_clock,
                        color: Colors.black,
                      ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4.0),
                  child: contact.messagesDisappearAfterSeconds > 0
                      ? CText(
                          'banner_message_retention'.i18n.fill([
                            contact.messagesDisappearAfterSeconds
                                .humanizeSeconds(longForm: true)
                          ]),
                          style: tsBody2.copiedWith(color: grey5),
                        )
                      : CText(
                          'banner_messages_persist'.i18n,
                          style: tsBody2.copiedWith(color: grey5),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
