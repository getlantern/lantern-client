import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

/// An item in a conversation list.
class ContactOptions extends StatelessWidget {
  final PathAndValue<Contact> _contact;

  ContactOptions(this._contact) : super();

  @override
  Widget build(BuildContext context) {
    return // Conversation header
        Card(
            color: Colors.white70,
            child: Column(
              children: [
                Container(
                  child: const Icon(Icons.account_circle_rounded, size: 140),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Text(_contact.value.displayName,
                        style: const TextStyle(fontSize: 25))),
              ],
            ));
  }
}
