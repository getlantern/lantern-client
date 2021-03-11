import 'package:lantern/model/model.dart';

import '../extension/date_time_extensions.dart';
import 'protos/messaging.pb.dart';

class MessagingModel extends Model {
  MessagingModel(
      {String methodChannelName = 'messaging_method_channel',
      String eventChannelName = 'messaging_event_channel'})
      : super(methodChannelName, eventChannelName) {
    // Use static list of conversations for now
    var conversationIDs = List<String>();
    for (var i = 0; i < 100; i++) {
      var contact = Contact.create();
      contact.userID = i.toString();
      contact.name = "Contact ${contact.userID}";
      put("/contact/${contact.userID}", contact);
      var conversation = Conversation.create();
      conversation.id = i.toString();
      conversation.userIDs.add(contact.userID);
      conversation.mostRecentMessage =
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
      conversation.mostRecentMessageTime = DateTime.now()
          .subtract(Duration(minutes: i, seconds: i + 1))
          .toTimestamp();
      put("/conversation/${conversation.id}", conversation);
      conversationIDs.add(conversation.id);
    }
    put("/conversationsByRecentActivity", conversationIDs);
  }
}
