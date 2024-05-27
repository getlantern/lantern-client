// import 'calls/signaling.dart';
import 'package:lantern/common/common_desktop.dart';

import 'messaging.dart';

final messagingModel = MessagingModel();

class MessagingModel extends Model {
  late LRUCache<StoredAttachment, Uint8List> _thumbnailCache;
  // late Signaling signaling;

  MessagingModel() : super('messaging') {
    _thumbnailCache = LRUCache<StoredAttachment, Uint8List>(
      100,
      (attachment) =>
          methodChannel.invokeMethod('decryptAttachment', <String, dynamic>{
        'attachment':
            (attachment.hasThumbnail() ? attachment.thumbnail : attachment)
                .writeToBuffer(),
      }).then((value) => value as Uint8List),
    );

    // signaling = Signaling(methodChannel);
    if (isMobile()) {
      methodChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          // case 'onSignal':
          //   var args = call.arguments as Map;
          //   signaling.onMessage(
          //     args['senderId'],
          //     args['content'],
          //     args['acceptedCall'],
          //   );
          //   break;
          default:
            break;
        }
      });
    }
  }

  /*
   * Lifecycle
   */
  Future<void> start() {
    return methodChannel.invokeMethod('start');
  }

  Future<void> kill() {
    return methodChannel.invokeMethod('kill');
  }

  Future<void> wipeData() {
    return methodChannel.invokeMethod('wipeData');
  }

  /*
  * CONTACTS
  */

  Future<ChatNumber> findChatNumberByShortNumber(String shortNumber) {
    return methodChannel
        .invokeMethod('findChatNumberByShortNumber', <String, dynamic>{
      'shortNumber': shortNumber,
    }).then((value) => ChatNumber.fromBuffer(value));
  }

  Future<Map> addProvisionalContact(
    String contactId,
    String? source,
  ) {
    return methodChannel
        .invokeMethod('addProvisionalContact', <String, dynamic>{
      'unsafeContactId': contactId,
      'source': source,
    }).then((value) => value as Map);
  }

  Future<void> deleteProvisionalContact(String contactId) {
    return methodChannel.invokeMethod(
      'deleteProvisionalContact',
      <String, dynamic>{'unsafeContactId': contactId},
    );
  }

  Future<Contact> addOrUpdateDirectContact({
    String? unsafeId,
    ChatNumber? chatNumber,
    String? displayName,
    String? source,
  }) {
    return methodChannel
        .invokeMethod('addOrUpdateDirectContact', <String, dynamic>{
      'unsafeId': unsafeId,
      'chatNumber': chatNumber?.writeToBuffer(),
      'displayName': displayName,
      'source': source,
    }).then((value) => Contact.fromBuffer(value));
  }

  Future<void> acceptDirectContact(String unsafeId) {
    return methodChannel.invokeMethod(
      'acceptDirectContact',
      <String, dynamic>{'unsafeId': unsafeId},
    );
  }

  Future<void> markDirectContactVerified(String unsafeId) {
    return methodChannel.invokeMethod(
      'markDirectContactVerified',
      <String, dynamic>{'unsafeId': unsafeId},
    );
  }

  Future<void> blockDirectContact(String unsafeId) {
    return methodChannel.invokeMethod(
      'blockDirectContact',
      <String, dynamic>{'unsafeId': unsafeId},
    );
  }

  Future<void> unblockDirectContact(String unsafeId) {
    return methodChannel.invokeMethod(
      'unblockDirectContact',
      <String, dynamic>{'unsafeId': unsafeId},
    );
  }

  Future<void> setCurrentConversationContact(
    String currentConversationContact,
  ) async =>
      methodChannel.invokeMethod(
        'setCurrentConversationContact',
        currentConversationContact,
      );

  Future<void> clearCurrentConversationContact() async =>
      methodChannel.invokeMethod(
        'clearCurrentConversationContact',
      );

  Future<Contact?> getContact(String contactPath) async {
    return get<Uint8List?>(contactPath).then(
      (serialized) =>
          serialized == null ? null : Contact.fromBuffer(serialized),
    );
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

  /// Returns the best introductions to each contact.
  Widget bestIntroductions({
    required ValueWidgetBuilder<Iterable<PathAndValue<StoredMessage>>> builder,
  }) {
    return subscribedListBuilder<StoredMessage>(
      '/intro/best/',
      details: true,
      builder: builder,
      deserialize: (Uint8List serialized) {
        return StoredMessage.fromBuffer(serialized);
      },
    );
  }

  Widget contactsByActivity({
    required ValueWidgetBuilder<Iterable<PathAndValue<Contact>>> builder,
  }) {
    return subscribedListBuilder<Contact>(
      '/cba/',
      details: true,
      builder: builder,
      deserialize: (Uint8List serialized) {
        return Contact.fromBuffer(serialized);
      },
    );
  }

  Widget contacts({
    required ValueWidgetBuilder<Iterable<PathAndValue<Contact>>> builder,
  }) {
    return subscribedListBuilder<Contact>(
      '/contacts/',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return Contact.fromBuffer(serialized);
      },
    );
  }

  Widget contact(
    BuildContext context,
    PathAndValue<Contact> contact,
    ValueWidgetBuilder<Contact> builder,
  ) {
    return listChildBuilder(
      context,
      contact.path,
      defaultValue: contact.value,
      builder: builder,
    );
  }

  Widget singleContact(Contact contact, ValueWidgetBuilder<Contact> builder) {
    return subscribedSingleValueBuilder(
      '/contacts/${_contactPathSegment(contact.contactId)}',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return Contact.fromBuffer(serialized);
      },
    );
  }

  /*
  Matches a ContactId to a direct or group Contact
  */
  Widget singleContactById(
    ContactId contactId,
    ValueWidgetBuilder<Contact> builder,
  ) {
    return subscribedSingleValueBuilder(
      '/contacts/${_contactPathSegment(contactId)}',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return Contact.fromBuffer(serialized);
      },
    );
  }

  ValueNotifier<Contact?> contactNotifier(String contactId) {
    return singleValueNotifier(
      _directContactPath(contactId),
      null,
      deserialize: (Uint8List serialized) {
        return Contact.fromBuffer(serialized);
      },
    );
  }

  Widget contactMessages(
    Contact contact, {
    required ValueWidgetBuilder<Iterable<PathAndValue<StoredMessage>>> builder,
  }) {
    return subscribedListBuilder<StoredMessage>(
      '/cm/${_contactPathSegment(contact.contactId)}',
      details: true,
      compare: sortReversed,
      builder: builder,
      deserialize: (Uint8List serialized) {
        return StoredMessage.fromBuffer(serialized);
      },
    );
  }

  Future<Contact> getDirectContact(String contactId) {
    return methodChannel
        .invokeMethod('get', _directContactPath(contactId))
        .then((value) => Contact.fromBuffer(value as Uint8List));
  }

  Widget message(
    BuildContext context,
    PathAndValue<StoredMessage> message,
    ValueWidgetBuilder<StoredMessage> builder,
  ) {
    return listChildBuilder(
      context,
      message.path,
      defaultValue: message.value,
      builder: builder,
    );
  }

  Widget singleMessage(
    String senderId,
    String messageId,
    ValueWidgetBuilder<StoredMessage> builder,
  ) {
    return subscribedSingleValueBuilder<StoredMessage>(
      '/m/$senderId/$messageId',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return StoredMessage.fromBuffer(serialized);
      },
    );
  }

  Widget me(ValueWidgetBuilder<Contact> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<Contact>(
        '/me',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return Contact.fromBuffer(serialized);
        },
      );
    }
    return ffiValueBuilder<Contact>(
      'chatMe',
      ffiChatMe,
      defaultValue: null,
      builder: builder,
    );
  }

  Future<void> recover(String recoveryCode) async => methodChannel
      .invokeMethod('recover', <String, dynamic>{'recoveryCode': recoveryCode});

  Future<String> getRecoveryCode() => methodChannel
      .invokeMethod('getRecoveryCode')
      .then((value) => value as String);

  String _contactPathSegment(ContactId contactId) {
    return contactId.type == ContactType.DIRECT
        ? 'd/${contactId.id}'
        : 'g/${contactId.id}';
  }

  String _directContactPath(String contactId) => '/contacts/d/$contactId';

  /*
  * MESSAGES
  */

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
      'markViewed',
      <String, dynamic>{'msg': message.writeToBuffer()},
    );
  }

  Future<void> deleteLocally(StoredMessage message) {
    return methodChannel.invokeMethod(
      'deleteLocally',
      <String, dynamic>{'msg': message.writeToBuffer()},
    );
  }

  Future<void> deleteGlobally(StoredMessage message) {
    return methodChannel.invokeMethod(
      'deleteGlobally',
      <String, dynamic>{'msg': message.writeToBuffer()},
    );
  }

  Future<void> setDisappearSettings(Contact contact, int seconds) {
    return methodChannel.invokeMethod('setDisappearSettings', <String, dynamic>{
      'contactId': contact.contactId.id,
      'seconds': seconds
    });
  }

  /*
  * ATTACHMENTS
  */

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
    String filePath,
    Map<String, String> metadata,
  ) async {
    return methodChannel
        .invokeMethod('filePickerLoadAttachment', <String, dynamic>{
      'filePath': filePath,
      'metadata': metadata,
    }).then((value) {
      return value as Uint8List;
    });
  }

  ValueListenable<CachedValue<Uint8List>> thumbnail(
    StoredAttachment attachment,
  ) {
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

  /*
  * SEARCH
  */

  Future<List<SearchResult<Contact>>> searchContacts(
    String query,
    int? numTokens,
  ) async =>
      methodChannel.invokeMethod('searchContacts', <String, dynamic>{
        'query': sanitizeQuery(query),
        'numTokens': numTokens,
      }).then((value) {
        final results = <SearchResult<Contact>>[];
        value.forEach((element) {
          final result = SearchResult<Contact>(
            element['path'],
            Contact.fromBuffer(element['contact']),
            element['snippet'],
          );
          results.add(result);
        });
        return Future.value(results);
      });

  Future<List<SearchResult<StoredMessage>>> searchMessages(
    String query,
    int? numTokens,
  ) async =>
      methodChannel.invokeMethod('searchMessages', <String, dynamic>{
        'query': sanitizeQuery(query),
        'numTokens': numTokens,
      }).then((value) {
        final results = <SearchResult<StoredMessage>>[];
        value.forEach((element) {
          final result = SearchResult<StoredMessage>(
            element['path'],
            StoredMessage.fromBuffer(element['message']),
            element['snippet'],
          );
          results.add(result);
        });
        return Future.value(results);
      });

  String sanitizeQuery(String query) => query
      .split(RegExp(r'\s'))
      .map((s) => '"${s.replaceAll('\"', '')}"')
      .join(' ');

  /*
  * REMINDERS
  */

  Future<void> dismissVerificationReminder(String unsafeId) {
    return methodChannel
        .invokeMethod('dismissVerificationReminder', <String, dynamic>{
      'unsafeId': unsafeId,
    }).then((value) => Contact.fromBuffer(value));
  }

  Future<void> markIsOnboarded<T>() async {
    return methodChannel.invokeMethod('markIsOnboarded');
  }

  Widget getOnBoardingStatus(ValueWidgetBuilder<bool?> builder) {
    // Note - we use null as a placeholder for "unknown" to indicate when we
    // haven't yet read the actual onboarding status from the back-end
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool?>(
        'onBoardingStatus',
        defaultValue: null,
        builder: builder,
      );
    }
    return ffiValueBuilder<bool?>(
      'onBoardingStatus',
      defaultValue: false,
      ffiOnBoardingStatus,
      builder: builder,
    );
  }

  Future<void> markCopiedRecoveryKey<T>() async {
    return methodChannel.invokeMethod('markCopiedRecoveryKey');
  }

  Widget getCopiedRecoveryStatus(ValueWidgetBuilder<bool> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>(
        'copiedRecoveryStatus',
        defaultValue: false,
        builder: builder,
      );
    }
    return ffiValueBuilder<bool>(
      'onBoardingStatus',
      defaultValue: false,
      ffiOnBoardingStatus,
      builder: builder,
    );
  }

  Future<void> saveNotificationsTS<T>() async {
    return methodChannel.invokeMethod('saveNotificationsTS');
  }

  Widget getLastDismissedNotificationTS(ValueWidgetBuilder<int> builder) {
    return subscribedSingleValueBuilder<int>(
      'requestNotificationLastDismissedTS',
      defaultValue: 0,
      builder: builder,
    );
  }

  Future<String> getDefaultRingtoneUri() {
    return methodChannel
        .invokeMethod('getDefaultRingtoneUri')
        .then((v) => v as String);
  }

  Future<bool> shouldShowTryLanternChatModal<T>() async {
    return methodChannel
        .invokeMethod('shouldShowTryLanternChatModal')
        .then((value) => value as bool);
  }

  Future<void> dismissTryLanternChatBadge<T>() async {
    return methodChannel.invokeMethod('dismissTryLanternChatBadge');
  }

  Widget getFirstShownTryLanternChatModalTS(ValueWidgetBuilder<int> builder) {
    return subscribedSingleValueBuilder<int>(
      'firstShownTryLanternChatModalTS',
      defaultValue: 0,
      builder: builder,
    );
  }

  // * DEV AND TESTING PURPOSES
  static const dummyContactIds = [
    'f46zym45eke4yrcgj7yz9q9oa5kjtghrddn4ekrnf69333jjxbmy',
    'a77ngft83zg3cg1b2hrr6yng31wn9xamu26spze5ojnot2bwmtto',
    'gsg2wytn11sztcaomzbgse3focrdbtuthydr2pudbtmzngsn5tso',
  ];

  Future<void> resetTimestamps() {
    return methodChannel.invokeMethod('resetTimestamps');
  }

  Future<void> resetFlags() {
    return methodChannel.invokeMethod('resetFlags');
  }

  void addDummyContacts() {
    return dummyContactIds.forEach(
      (element) => methodChannel
          .invokeMethod('addOrUpdateDirectContact', <String, dynamic>{
        'unsafeId': element,
      }),
    );
  }

  Future<void> saveDummyAttachment(
    String url,
    String displayName,
  ) async {
    return methodChannel.invokeMethod('saveDummyAttachment', {
      'url': url,
      'displayName': displayName,
    });
  }

  Future<void> sendDummyAttachment(
    String fileName,
    Map<String, String> metadata,
  ) async {
    try {
      // create attachment in messaging
      final attachment = await methodChannel
          .invokeMethod('sendDummyAttachment', <String, dynamic>{
        'fileName': fileName,
        'metadata': metadata,
      }).then((value) {
        return value as Uint8List;
      });

      // send to the first of the 3 dummy direct contact
      return methodChannel
          .invokeMethod('sendToDirectContact', <String, dynamic>{
        'identityKey': dummyContactIds.first,
        'attachments': [attachment],
      });
    } catch (e) {
      print(e);
    }
  }
}
