import 'dart:typed_data';

import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

import '../package_store.dart';
import 'list_subscriber.dart';
import 'protos_flutteronly/messaging.pb.dart';

class MessagingModel extends Model {
  MessagingModel() : super("messaging");

  Future<void> setMyDisplayName<T>(String displayName) {
    return methodChannel.invokeMethod('setMyDisplayName', <String, dynamic>{
      "displayName": displayName,
    });
  }

  Future<void> addOrUpdateDirectContact<T>(
      String identityKey, String displayName) {
    return methodChannel
        .invokeMethod('addOrUpdateDirectContact', <String, dynamic>{
      "identityKey": identityKey,
      "displayName": displayName,
    });
  }

  Future<void> sendToDirectContact(String identityKey, String text) {
    return methodChannel.invokeMethod('sendToDirectContact', <String, dynamic>{
      "identityKey": identityKey,
      "text": text,
    });
  }

  ValueListenableBuilder<ChangeTrackingList<Contact>> contacts(
      {@required ValueWidgetBuilder<Iterable<PathAndValue<Contact>>> builder}) {
    return subscribedListBuilder<Contact>('/contacts/', builder: builder,
        deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  ValueListenableBuilder<ChangeTrackingList<ShortMessageRecord>>
      contactMessages(
          Contact contact,
          {@required
              ValueWidgetBuilder<List<PathAndValue<ShortMessageRecord>>>
                  builder}) {
    return subscribedListBuilder<ShortMessageRecord>(
        '/cm/${_contactPathSegment(contact)}',
        details: true,
        compare: sortReversed,
        builder: builder, deserialize: (Uint8List serialized) {
      return ShortMessageRecord.fromBuffer(serialized);
    });
  }

  ValueListenableBuilder<ShortMessageRecord> message(
      BuildContext context,
      PathAndValue<ShortMessageRecord> message,
      ValueWidgetBuilder<ShortMessageRecord> builder) {
    return listChildBuilder(context, message.path,
        defaultValue: message.value, builder: builder);
  }

  ValueListenableBuilder<Contact> me(ValueWidgetBuilder<Contact> builder) {
    return subscribedSingleValueBuilder<Contact>('/me', builder: builder,
        deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  String _contactPathSegment(Contact contact) {
    return contact.type == Contact_Type.DIRECT
        ? "d/${contact.id}"
        : "g/${contact.id}";
  }
}
