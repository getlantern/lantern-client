import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';

class DisappearingTimerAction extends StatelessWidget {
  final Contact contact;

  DisappearingTimerAction(this.contact) : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.singleContact(
      context,
      contact,
      (context, contact, child) => PopupMenuButton(
        itemBuilder: (BuildContext context) => [5, 60, 3600, 86400]
            .map((e) => DisappearingTimerMenuItem(contact, e))
            .toList(),
        onSelected: (int value) {
          model.setDisappearSettings(contact, value);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Flex(direction: Axis.vertical, children: [
            const Flexible(
              child: Icon(Icons.timer),
            ),
            contact.messagesDisappearAfterSeconds > 0
                ? Flexible(
                    child: Text(contact.messagesDisappearAfterSeconds
                        .humanizeSeconds()),
                  )
                : const SizedBox.shrink()
          ]),
        ),
      ),
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
                  ? 'Never'.i18n
                  : value.humanizeSeconds(longForm: true)),
            ));
}
