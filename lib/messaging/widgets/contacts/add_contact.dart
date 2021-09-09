import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/package_store.dart';

abstract class AddContactState<T extends StatefulWidget> extends State<T> {
  void waitForContact(MessagingModel model, String contactId,
      int mostRecentHelloTs, AnimationController? animationController) {
    var contactNotifier = model.contactNotifier(contactId);
    late void Function() listener;
    listener = () async {
      var updatedContact = contactNotifier.value;
      if (updatedContact != null &&
          updatedContact.mostRecentHelloTs > mostRecentHelloTs) {
        contactNotifier.removeListener(listener);
        // go back to New Message with the updatedContact info
        Navigator.pop(context, updatedContact);
        if (animationController != null) animationController.stop();
      }
    };
    contactNotifier.addListener(listener);
    // immediately invoke listener in case the contactNotifier already has
    // an up-to-date contact.
    listener();
  }
}
