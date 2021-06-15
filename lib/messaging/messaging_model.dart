import 'dart:typed_data';

import 'package:lantern/model/lru_cache.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

import '../model/list_subscriber.dart';
import '../model/protos_flutteronly/messaging.pb.dart';
import '../package_store.dart';

class MessagingModel extends Model {
  late LRUCache<StoredAttachment, Uint8List> _thumbnailCache;

  MessagingModel() : super('messaging') {
    _thumbnailCache = LRUCache<StoredAttachment, Uint8List>(
        100,
        (attachment) =>
            methodChannel.invokeMethod('decryptAttachment', <String, dynamic>{
              'attachment': (attachment.hasThumbnail()
                      ? attachment.thumbnail
                      : attachment)
                  .writeToBuffer(),
            }).then((value) => value as Uint8List));
  }

  Future<void> setMyDisplayName<T>(String displayName) {
    return methodChannel.invokeMethod('setMyDisplayName', <String, dynamic>{
      'displayName': displayName,
    });
  }

  // TODO: update on messaging-android
  Future<void> addOrUpdateDirectContact<T>(
      String identityKey, String displayName, bool isFullyVerified) {
    return methodChannel
        .invokeMethod('addOrUpdateDirectContact', <String, dynamic>{
      'identityKey': identityKey,
      'displayName': displayName,
      'isFullyVerified': isFullyVerified,
    });
  }

  Future<void> sendToDirectContact(
    String identityKey, {
    String? text,
    List<Uint8List>? attachments,
    String? replyToId,
    String? replyToSenderId,
  }) {
    return methodChannel.invokeMethod('sendToDirectContact', <String, dynamic>{
      'identityKey': identityKey,
      'text': text,
      'attachments': attachments,
      'replyToId': replyToId,
      'replyToSenderId': replyToSenderId,
    });
  }

  Future<void> react(PathAndValue<StoredMessage> message, String reaction) {
    return methodChannel.invokeMethod('react', <String, dynamic>{
      'msg': message.value.writeToBuffer(),
      'reaction': reaction
    });
  }

  Future<void> markViewed(PathAndValue<StoredMessage> message) {
    return methodChannel.invokeMethod(
        'markViewed', <String, dynamic>{'msg': message.value.writeToBuffer()});
  }

  Future<void> deleteLocally(PathAndValue<StoredMessage> message) {
    return methodChannel.invokeMethod('deleteLocally',
        <String, dynamic>{'msg': message.value.writeToBuffer()});
  }

  Future<void> deleteGlobally(PathAndValue<StoredMessage> message) {
    return methodChannel.invokeMethod('deleteGlobally',
        <String, dynamic>{'msg': message.value.writeToBuffer()});
  }

  Future<void> setDisappearSettings(Contact contact, int seconds) {
    return methodChannel.invokeMethod('setDisappearSettings', <String, dynamic>{
      'contactId': contact.contactId.id,
      'seconds': seconds
    });
  }

  Future<bool> startRecordingVoiceMemo() async {
    return methodChannel
        .invokeMethod('startRecordingVoiceMemo')
        .then((value) => value as bool);
  }

  Future<Uint8List> stopRecordingVoiceMemo() async {
    return methodChannel
        .invokeMethod('stopRecordingVoiceMemo')
        .then((value) => value as Uint8List);
  }

  Future<Uint8List> filePickerLoadAttachment(
      String filePath, Map<String, String> metadata) async {
    return methodChannel.invokeMethod(
        'filePickerLoadAttachment', <String, dynamic>{
      'filePath': filePath,
      'metadata': metadata
    }).then((value) => value as Uint8List);
  }

  Future<Uint8List> thumbnail(StoredAttachment attachment) async {
    return _thumbnailCache.get(attachment);
  }

  Future<Uint8List> decryptAttachment(StoredAttachment attachment) async {
    return methodChannel.invokeMethod('decryptAttachment', <String, dynamic>{
      'attachment': attachment.writeToBuffer(),
    }).then((value) => value as Uint8List);
  }

  Future<String> decryptVideoForPlayback(StoredAttachment attachment) async {
    return methodChannel
        .invokeMethod('decryptVideoForPlayback', <String, dynamic>{
      'attachment': attachment.writeToBuffer(),
    }).then((value) => value as String);
  }

  Future<void> setCurrentConversationContact(
          String currentConversationContact) async =>
      methodChannel.invokeMethod(
          'setCurrentConversationContact', currentConversationContact);

  Future<void> clearCurrentConversationContact() async =>
      methodChannel.invokeMethod(
        'clearCurrentConversationContact',
      );

  Future<Contact?> getContact(String contactPath) async {
    return get<Uint8List?>(contactPath).then((serialized) =>
        serialized == null ? null : Contact.fromBuffer(serialized));
  }

  // TODO: implement this on messaging-android, unless we modify the function above ^ (which I don't think we are currently using anywhere)
  Future<Contact> getContactFromUsername<T>(String username) async {
    return methodChannel
        .invokeMethod('getContactFromUsername', <String, dynamic>{
      'username': username,
    }).then((value) => value as Contact);
  }

  // TODO: implement this on messaging-android
  Future<bool> getVerificationStatus<T>(Contact contact) async {
    return methodChannel
        .invokeMethod('getVerificationStatus', <String, dynamic>{
      'contact': contact,
    }).then((value) => value as bool);
  }

  // TODO: implement this on messaging-android
  Future<void> verifyContact<T>(Contact contact) async {
    return methodChannel.invokeMethod('verifyContact', <String, dynamic>{
      'contact': contact,
    });
  }

  Widget contactsByActivity(
      {required ValueWidgetBuilder<Iterable<PathAndValue<Contact>>> builder}) {
    return subscribedListBuilder<Contact>('/cba/',
        details: true, builder: builder, deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  Widget contacts(
      {required ValueWidgetBuilder<Iterable<PathAndValue<Contact>>> builder}) {
    return subscribedListBuilder<Contact>('/contacts/', builder: builder,
        deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  Widget contact(BuildContext context, PathAndValue<Contact> contact,
      ValueWidgetBuilder<Contact> builder) {
    return listChildBuilder(context, contact.path,
        defaultValue: contact.value, builder: builder);
  }

  Widget singleContact(BuildContext context, Contact contact,
      ValueWidgetBuilder<Contact> builder) {
    return subscribedSingleValueBuilder(
        '/contacts/${_contactPathSegment(contact.contactId)}',
        builder: builder, deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  Widget contactMessages(Contact contact,
      {required ValueWidgetBuilder<Iterable<PathAndValue<StoredMessage>>>
          builder}) {
    return subscribedListBuilder<StoredMessage>(
        '/cm/${_contactPathSegment(contact.contactId)}',
        details: true,
        compare: sortReversed,
        builder: builder, deserialize: (Uint8List serialized) {
      return StoredMessage.fromBuffer(serialized);
    });
  }

  Widget message(BuildContext context, PathAndValue<StoredMessage> message,
      ValueWidgetBuilder<StoredMessage> builder) {
    return listChildBuilder(context, message.path,
        defaultValue: message.value, builder: builder);
  }

  Widget me(ValueWidgetBuilder<Contact> builder) {
    return subscribedSingleValueBuilder<Contact>('/me', builder: builder,
        deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  String _contactPathSegment(ContactId contactId) {
    return contactId.type == ContactType.DIRECT
        ? 'd/${contactId.id}'
        : 'g/${contactId.id}';
  }
}
