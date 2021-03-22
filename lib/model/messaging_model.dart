import 'dart:typed_data';

import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

import '../package_store.dart';

class MessagingModel extends Model {
  MessagingModel() : super("messaging");

  ValueListenableBuilder<Conversation> conversation(
      Conversation conversation, ValueWidgetBuilder<Conversation> builder) {
    return subscribedBuilder<Conversation>("/con/${_partyPath(conversation)}",
        defaultValue: conversation,
        builder: builder, deserialize: (Uint8List serialized) {
      return Conversation.fromBuffer(serialized);
    });
  }

  ValueListenableBuilder<dynamic> contactOrGroup(
      Conversation conversation, ValueWidgetBuilder<dynamic> builder) {
    return subscribedBuilder<dynamic>(_partyPath(conversation),
        builder: builder, deserialize: (Uint8List serialized) {
      if (conversation.contactId != null) {
        return Contact.fromBuffer(serialized);
      } else {
        return Group.fromBuffer(serialized);
      }
    });
  }

  String _partyPath(Conversation conversation) {
    return conversation.contactId != null
        ? "/c/${conversation.contactId}"
        : "/g/${conversation.groupId}";
  }
}
