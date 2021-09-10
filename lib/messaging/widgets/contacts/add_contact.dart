import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/package_store.dart';
import 'package:pedantic/pedantic.dart';

abstract class AddContactState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  late MessagingModel model;
  String? provisionalContactId;
  int timeoutMillis = 0;
  late AnimationController countdownController;

  Future<void> addProvisionalContact(
      MessagingModel model, String contactId) async {
    if (provisionalContactId != null) {
      // we've already added a provisional contact
      return;
    }
    var result = await model.addProvisionalContact(contactId);

    var contactNotifier = model.contactNotifier(contactId);
    late void Function() listener;
    listener = () async {
      var updatedContact = contactNotifier.value;
      if (updatedContact != null &&
          updatedContact.mostRecentHelloTs >
              result['mostRecentHelloTsMillis']) {
        contactNotifier.removeListener(listener);
        countdownController.stop(canceled: true);
        // go back to New Message with the updatedContact info
        Navigator.pop(context, updatedContact);
      }
    };
    contactNotifier.addListener(listener);
    // immediately invoke listener in case the contactNotifier already has
    // an up-to-date contact.
    listener();

    final int expiresAt = result['expiresAtMillis'];
    if (expiresAt > 0) {
      final timeout = expiresAt - DateTime.now().millisecondsSinceEpoch;
      setState(() {
        provisionalContactId = contactId;
        timeoutMillis = timeout;
        countdownController.duration = Duration(milliseconds: timeoutMillis);
      });

      unawaited(countdownController.forward().then((value) {
        // we ran out of time before completing handshake, go back
        Navigator.pop(context);
      }));
    } else {
      // TODO: we need to show something to the user to indicate that we're
      // waiting on the other person to scan the QR code, but in this case
      // there is no time limit.
    }
  }

  @override
  void initState() {
    super.initState();
    countdownController =
        AnimationController(vsync: this, duration: const Duration(hours: 24));
  }

  @override
  void dispose() {
    countdownController.stop(canceled: true);
    countdownController.dispose();
    if (provisionalContactId?.isNotEmpty == true) {
      // when exiting this screen, immediately delete any provisional contact
      model.deleteProvisionalContact(provisionalContactId!);
    }
    super.dispose();
  }
}
