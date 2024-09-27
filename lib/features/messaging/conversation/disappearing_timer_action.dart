import 'package:lantern/features/messaging/messaging.dart';

class DisappearingTimerAction extends StatelessWidget {
  final Contact contact;

  DisappearingTimerAction(this.contact) : super();

  @override
  Widget build(BuildContext context) {
    return messagingModel.singleContact(
      contact,
      (context, contact, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer,
            size: 12,
          ),
          const SizedBox(width: 2),
          CText(
            contact.messagesDisappearAfterSeconds == 0
                ? 'off'.i18n
                : contact.messagesDisappearAfterSeconds
                    .humanizeSeconds()
                    .toUpperCase(),
            // customize the lineHeight to get alignment with icon to work right
            style: tsOverline.copiedWith(lineHeight: 14),
          )
        ],
      ),
    );
  }
}
