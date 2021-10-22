import 'calls/signaling.dart';
import 'messaging.dart';

class MessagingModel extends Model {
  late LRUCache<StoredAttachment, Uint8List> _thumbnailCache;
  late Signaling signaling;

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

    signaling = Signaling(model: this, mc: methodChannel);

    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onSignal':
          var args = call.arguments as Map;
          signaling.onMessage(
              args['senderId'], args['content'], args['acceptedCall']);
          break;
        default:
          break;
      }
    });
  }

  Future<Map> addProvisionalContact(String contactId, {String? source}) {
    return methodChannel
        .invokeMethod('addProvisionalContact', <String, dynamic>{
      'unsafeContactId': contactId,
      'source': source,
    }).then((value) => value as Map);
  }

  Future<void> deleteProvisionalContact(String contactId) {
    return methodChannel.invokeMethod('deleteProvisionalContact',
        <String, dynamic>{'unsafeContactId': contactId});
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

  Future<void> react(StoredMessage message, String reaction) {
    return methodChannel.invokeMethod('react', <String, dynamic>{
      'msg': message.writeToBuffer(),
      'reaction': reaction
    });
  }

  Future<void> markViewed(StoredMessage message) {
    return methodChannel.invokeMethod(
        'markViewed', <String, dynamic>{'msg': message.writeToBuffer()});
  }

  Future<void> deleteLocally(StoredMessage message) {
    return methodChannel.invokeMethod(
        'deleteLocally', <String, dynamic>{'msg': message.writeToBuffer()});
  }

  Future<void> deleteGlobally(StoredMessage message) {
    return methodChannel.invokeMethod(
        'deleteGlobally', <String, dynamic>{'msg': message.writeToBuffer()});
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
    return methodChannel
        .invokeMethod('filePickerLoadAttachment', <String, dynamic>{
      'filePath': filePath,
      'metadata': metadata,
    }).then((value) {
      return value as Uint8List;
    });
  }

  ValueListenable<CachedValue<Uint8List>> thumbnail(
      StoredAttachment attachment) {
    return _thumbnailCache.get(attachment);
  }

  Future<Uint8List> decryptAttachment(StoredAttachment attachment) async {
    return methodChannel.invokeMethod('decryptAttachment', <String, dynamic>{
      'attachment': attachment.writeToBuffer(),
    }).then((value) {
      return value as Uint8List;
    });
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

  Future<void> deleteDirectContact(String id) async =>
      methodChannel.invokeMethod('deleteDirectContact', <String, dynamic>{
        'unsafeContactId': id,
      });

  Future<void> introduce(List<String> recipientIds) async =>
      methodChannel.invokeMethod('introduce', <String, dynamic>{
        'unsafeRecipientIds': recipientIds,
      });

  Future<void> acceptIntroduction(String fromId, String toId) async =>
      methodChannel.invokeMethod('acceptIntroduction', <String, dynamic>{
        'unsafeFromId': fromId,
        'unsafeToId': toId,
      });

  Future<void> rejectIntroduction(String fromId, String toId) async =>
      methodChannel.invokeMethod('rejectIntroduction', <String, dynamic>{
        'unsafeFromId': fromId,
        'unsafeToId': toId,
      });

  Future<List<SearchResult<Contact>>> searchContacts(
          String query, int? numTokens) async =>
      methodChannel.invokeMethod('searchContacts', <String, dynamic>{
        'query': sanitizeQuery(query),
        'numTokens': numTokens,
      }).then((value) {
        final results = <SearchResult<Contact>>[];
        value.forEach((element) {
          final result = SearchResult<Contact>(element['path'],
              Contact.fromBuffer(element['contact']), element['snippet']);
          results.add(result);
        });
        return Future.value(results);
      });

  Future<List<SearchResult<StoredMessage>>> searchMessages(
          String query, int? numTokens) async =>
      methodChannel.invokeMethod('searchMessages', <String, dynamic>{
        'query': sanitizeQuery(query),
        'numTokens': numTokens,
      }).then((value) {
        final results = <SearchResult<StoredMessage>>[];
        value.forEach((element) {
          final result = SearchResult<StoredMessage>(element['path'],
              StoredMessage.fromBuffer(element['message']), element['snippet']);
          results.add(result);
        });
        return Future.value(results);
      });

  String sanitizeQuery(String query) => query
      .split(RegExp(r'\s'))
      .map((s) => '"${s.replaceAll('\"', '')}"')
      .join(' ');

  // Returns the best introductions to each contact.
  // "Best" means most trusted (highest verification level).
  Widget bestIntroductions(
      {required ValueWidgetBuilder<Iterable<PathAndValue<StoredMessage>>>
          builder}) {
    return subscribedListBuilder<StoredMessage>('/intro/best/',
        details: true, builder: builder, deserialize: (Uint8List serialized) {
      return StoredMessage.fromBuffer(serialized);
    });
  }

  /*
  Returns the Contact corresponding to a displayName. Not in use until we implement AUTH.
  */
  // Future<Contact> getContactFromUsername<T>(String username) async {
  //   return methodChannel
  //       .invokeMethod('getContactFromUsername', <String, dynamic>{
  //     'username': username,
  //   }).then((value) => value as Contact);
  // }

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

  /*
  Matches a ContactId to a direct or group Contact
  */
  Widget singleContactById(BuildContext context, ContactId contactId,
      ValueWidgetBuilder<Contact> builder) {
    return subscribedSingleValueBuilder(
        '/contacts/${_contactPathSegment(contactId)}',
        builder: builder, deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  ValueNotifier<Contact?> contactNotifier(String contactId) {
    return singleValueNotifier(_directContactPath(contactId), null,
        deserialize: (Uint8List serialized) {
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

  Future<Contact> getDirectContact(String contactId) {
    return methodChannel
        .invokeMethod('get', _directContactPath(contactId))
        .then((value) => Contact.fromBuffer(value as Uint8List));
  }

  Widget message(BuildContext context, PathAndValue<StoredMessage> message,
      ValueWidgetBuilder<StoredMessage> builder) {
    return listChildBuilder(context, message.path,
        defaultValue: message.value, builder: builder);
  }

  Widget singleMessage(String senderId, String messageId,
      ValueWidgetBuilder<StoredMessage> builder) {
    return subscribedSingleValueBuilder<StoredMessage>(
        '/m/$senderId/$messageId',
        builder: builder, deserialize: (Uint8List serialized) {
      return StoredMessage.fromBuffer(serialized);
    });
  }

  Widget me(ValueWidgetBuilder<Contact> builder) {
    return subscribedSingleValueBuilder<Contact>('/me', builder: builder,
        deserialize: (Uint8List serialized) {
      return Contact.fromBuffer(serialized);
    });
  }

  Future<String> allocateRelayAddress(String localAddr) {
    return methodChannel
        .invokeMethod('allocateRelayAddress', localAddr)
        .then((value) => value as String);
  }

  Future<String> relayTo(String relayAddr) {
    return methodChannel
        .invokeMethod('relayTo', relayAddr)
        .then((value) => value as String);
  }

  String _contactPathSegment(ContactId contactId) {
    return contactId.type == ContactType.DIRECT
        ? 'd/${contactId.id}'
        : 'g/${contactId.id}';
  }

  String _directContactPath(String contactId) => '/contacts/d/$contactId';
}
