import 'dart:typed_data';

import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

import '../package_store.dart';

class MessagingModel extends Model {
  MessagingModel() : super("messaging");

  Future<void> addOrUpdateContact<T>(
      String contactId, String displayName) async {
    return methodChannel.invokeMethod('addOrUpdateContact', <String, dynamic>{
      "contactId": contactId,
      "displayName": displayName,
    });
  }

  Future<List<Conversation>> recentConversations({int count = 2 ^ 32}) {
    return list<Conversation>("/cbt/%", count: count, reverseSort: true,
        deserialize: (Uint8List serialized) {
      return Conversation.fromBuffer(serialized);
    });
  }

  Future<List<Contact>> contactsSortedAlphabetically() {
    return list<Contact>("/c/%", deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    }).then((result) {
      result.sort((a, b) {
        var dc = (a.displayName ?? "").compareTo(b.displayName ?? "");
        if (dc != 0) {
          return dc;
        }
        return a.id.compareTo(b.id);
      });
      return result;
    });
  }

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

  ValueListenableBuilder<Contact> me(ValueWidgetBuilder<Contact> builder) {
    return subscribedBuilder<Contact>("/c/me", builder: builder,
        deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  String _partyPath(Conversation conversation) {
    return conversation.contactId != null
        ? "/c/${conversation.contactId}"
        : "/g/${conversation.groupId}";
  }
}
