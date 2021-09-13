import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/common/humanize.dart';

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
        contact.messagesDisappearAfterSeconds > 0
            ? Text(
                contact.messagesDisappearAfterSeconds
                    .humanizeSeconds()
                    .toUpperCase(),
                style: tsDisappearingTimer)
            : Text(
                'off'.i18n,
                style: tsDisappearingTimerDetail,
              ),
      ]),
    );
  }
}

class DisappearingTimerMenuItem extends PopupMenuItem<int> {
  DisappearingTimerMenuItem(Contact contact, int value)
      : super(
            value: value,
            child: ListTile(
              leading: Icon(contact.messagesDisappearAfterSeconds == value
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank),
              title: Text(value == 0
                  ? 'never'.i18n
                  : value.humanizeSeconds(longForm: true)),
            ));
}
