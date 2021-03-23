import 'dart:typed_data';

import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

import '../package_store.dart';
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

  ValueListenableBuilder<List<Contact>> contacts(
      {int count = 2 ^ 32,
      @required ValueWidgetBuilder<List<Contact>> builder}) {
    return tailingBuilder<Contact>('/contacts/', count: count, builder: builder,
        deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  ValueListenableBuilder<List<ShortMessageRecord>> contactMessages(
      Contact contact,
      {int count = 2 ^ 32,
      @required ValueWidgetBuilder<List<ShortMessageRecord>> builder}) {
    return tailingBuilder<ShortMessageRecord>(
        '/cm/${_contactPathSegment(contact)}',
        details: true,
        count: count,
        builder: builder, deserialize: (Uint8List serialized) {
      return ShortMessageRecord.fromBuffer(serialized);
    });
  }

  ValueListenableBuilder<ShortMessageRecord> message(ShortMessageRecord message,
      ValueWidgetBuilder<ShortMessageRecord> builder) {
    return subscribedBuilder<ShortMessageRecord>(
        '/m/${message.sent}/${message.senderId}/${message.id}',
        defaultValue: message,
        builder: builder, deserialize: (Uint8List serialized) {
      return ShortMessageRecord.fromBuffer(serialized);
    });
  }

  ValueListenableBuilder<Contact> me(ValueWidgetBuilder<Contact> builder) {
    return subscribedBuilder<Contact>('/me', builder: builder,
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
