import 'package:lantern/messaging/messaging.dart';

class DisappearingTimerAction extends StatelessWidget {
  final Contact contact;

  DisappearingTimerAction(this.contact) : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.singleContact(
      context,
      contact,
      (context, contact, child) =>
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
            style: tsDisappearingTimer)
      ]),
    );
  }
}
