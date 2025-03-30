//
//  Generated code. Do not modify.
//  source: protos_flutteronly/messaging.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'messaging.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'messaging.pbenum.dart';

/// A globally unique identifier for a Contact
class ContactId extends $pb.GeneratedMessage {
  factory ContactId({
    ContactType? type,
    $core.String? id,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  ContactId._() : super();
  factory ContactId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactId', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..e<ContactType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ContactType.DIRECT, valueOf: ContactType.valueOf, enumValues: ContactType.values)
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactId clone() => ContactId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactId copyWith(void Function(ContactId) updates) => super.copyWith((message) => updates(message as ContactId)) as ContactId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactId create() => ContactId._();
  ContactId createEmptyInstance() => create();
  static $pb.PbList<ContactId> createRepeated() => $pb.PbList<ContactId>();
  @$core.pragma('dart2js:noInline')
  static ContactId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactId>(create);
  static ContactId? _defaultInstance;

  @$pb.TagNumber(1)
  ContactType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ContactType v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

/// A numeric version of the IdentityKey encoded in a phone-number like encoding
class ChatNumber extends $pb.GeneratedMessage {
  factory ChatNumber({
    $core.String? number,
    $core.String? shortNumber,
    $core.String? domain,
  }) {
    final $result = create();
    if (number != null) {
      $result.number = number;
    }
    if (shortNumber != null) {
      $result.shortNumber = shortNumber;
    }
    if (domain != null) {
      $result.domain = domain;
    }
    return $result;
  }
  ChatNumber._() : super();
  factory ChatNumber.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatNumber.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatNumber', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'number')
    ..aOS(2, _omitFieldNames ? '' : 'shortNumber', protoName: 'shortNumber')
    ..aOS(3, _omitFieldNames ? '' : 'domain')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatNumber clone() => ChatNumber()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatNumber copyWith(void Function(ChatNumber) updates) => super.copyWith((message) => updates(message as ChatNumber)) as ChatNumber;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatNumber create() => ChatNumber._();
  ChatNumber createEmptyInstance() => create();
  static $pb.PbList<ChatNumber> createRepeated() => $pb.PbList<ChatNumber>();
  @$core.pragma('dart2js:noInline')
  static ChatNumber getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatNumber>(create);
  static ChatNumber? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get number => $_getSZ(0);
  @$pb.TagNumber(1)
  set number($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shortNumber => $_getSZ(1);
  @$pb.TagNumber(2)
  set shortNumber($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShortNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearShortNumber() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get domain => $_getSZ(2);
  @$pb.TagNumber(3)
  set domain($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDomain() => $_has(2);
  @$pb.TagNumber(3)
  void clearDomain() => $_clearField(3);
}

enum Datum_Value {
  string, 
  float, 
  int_3, 
  bool_4, 
  bytes, 
  notSet
}

/// A typed datum
class Datum extends $pb.GeneratedMessage {
  factory Datum({
    $core.String? string,
    $core.double? float,
    $fixnum.Int64? int_3,
    $core.bool? bool_4,
    $core.List<$core.int>? bytes,
  }) {
    final $result = create();
    if (string != null) {
      $result.string = string;
    }
    if (float != null) {
      $result.float = float;
    }
    if (int_3 != null) {
      $result.int_3 = int_3;
    }
    if (bool_4 != null) {
      $result.bool_4 = bool_4;
    }
    if (bytes != null) {
      $result.bytes = bytes;
    }
    return $result;
  }
  Datum._() : super();
  factory Datum.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Datum.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Datum_Value> _Datum_ValueByTag = {
    1 : Datum_Value.string,
    2 : Datum_Value.float,
    3 : Datum_Value.int_3,
    4 : Datum_Value.bool_4,
    5 : Datum_Value.bytes,
    0 : Datum_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Datum', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5])
    ..aOS(1, _omitFieldNames ? '' : 'string')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'float', $pb.PbFieldType.OD)
    ..aInt64(3, _omitFieldNames ? '' : 'int')
    ..aOB(4, _omitFieldNames ? '' : 'bool')
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'bytes', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Datum clone() => Datum()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Datum copyWith(void Function(Datum) updates) => super.copyWith((message) => updates(message as Datum)) as Datum;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Datum create() => Datum._();
  Datum createEmptyInstance() => create();
  static $pb.PbList<Datum> createRepeated() => $pb.PbList<Datum>();
  @$core.pragma('dart2js:noInline')
  static Datum getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Datum>(create);
  static Datum? _defaultInstance;

  Datum_Value whichValue() => _Datum_ValueByTag[$_whichOneof(0)]!;
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get string => $_getSZ(0);
  @$pb.TagNumber(1)
  set string($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasString() => $_has(0);
  @$pb.TagNumber(1)
  void clearString() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get float => $_getN(1);
  @$pb.TagNumber(2)
  set float($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFloat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFloat() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get int_3 => $_getI64(2);
  @$pb.TagNumber(3)
  set int_3($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInt_3() => $_has(2);
  @$pb.TagNumber(3)
  void clearInt_3() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get bool_4 => $_getBF(3);
  @$pb.TagNumber(4)
  set bool_4($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBool_4() => $_has(3);
  @$pb.TagNumber(4)
  void clearBool_4() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get bytes => $_getN(4);
  @$pb.TagNumber(5)
  set bytes($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearBytes() => $_clearField(5);
}

/// A contact in the address book
class Contact extends $pb.GeneratedMessage {
  factory Contact({
    ContactId? contactId,
    $core.Iterable<$core.String>? memberIds,
    $core.String? displayName,
    $fixnum.Int64? createdTs,
    $fixnum.Int64? mostRecentMessageTs,
    MessageDirection? mostRecentMessageDirection,
    $core.String? mostRecentMessageText,
    $core.String? mostRecentAttachmentMimeType,
    $core.int? messagesDisappearAfterSeconds,
    $fixnum.Int64? firstReceivedMessageTs,
    $core.bool? hasReceivedMessage,
    $fixnum.Int64? mostRecentHelloTs,
    ContactSource? source,
    $pb.PbMap<$core.int, $core.String>? applicationIds,
    VerificationLevel? verificationLevel,
    $core.String? numericFingerprint,
    $core.bool? blocked,
    $pb.PbMap<$core.String, Datum>? applicationData,
    ChatNumber? chatNumber,
    $core.bool? isMe,
    $core.int? numUnviewedMessages,
  }) {
    final $result = create();
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (memberIds != null) {
      $result.memberIds.addAll(memberIds);
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (createdTs != null) {
      $result.createdTs = createdTs;
    }
    if (mostRecentMessageTs != null) {
      $result.mostRecentMessageTs = mostRecentMessageTs;
    }
    if (mostRecentMessageDirection != null) {
      $result.mostRecentMessageDirection = mostRecentMessageDirection;
    }
    if (mostRecentMessageText != null) {
      $result.mostRecentMessageText = mostRecentMessageText;
    }
    if (mostRecentAttachmentMimeType != null) {
      $result.mostRecentAttachmentMimeType = mostRecentAttachmentMimeType;
    }
    if (messagesDisappearAfterSeconds != null) {
      $result.messagesDisappearAfterSeconds = messagesDisappearAfterSeconds;
    }
    if (firstReceivedMessageTs != null) {
      $result.firstReceivedMessageTs = firstReceivedMessageTs;
    }
    if (hasReceivedMessage != null) {
      $result.hasReceivedMessage = hasReceivedMessage;
    }
    if (mostRecentHelloTs != null) {
      $result.mostRecentHelloTs = mostRecentHelloTs;
    }
    if (source != null) {
      $result.source = source;
    }
    if (applicationIds != null) {
      $result.applicationIds.addAll(applicationIds);
    }
    if (verificationLevel != null) {
      $result.verificationLevel = verificationLevel;
    }
    if (numericFingerprint != null) {
      $result.numericFingerprint = numericFingerprint;
    }
    if (blocked != null) {
      $result.blocked = blocked;
    }
    if (applicationData != null) {
      $result.applicationData.addAll(applicationData);
    }
    if (chatNumber != null) {
      $result.chatNumber = chatNumber;
    }
    if (isMe != null) {
      $result.isMe = isMe;
    }
    if (numUnviewedMessages != null) {
      $result.numUnviewedMessages = numUnviewedMessages;
    }
    return $result;
  }
  Contact._() : super();
  factory Contact.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Contact.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Contact', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOM<ContactId>(1, _omitFieldNames ? '' : 'contactId', protoName: 'contactId', subBuilder: ContactId.create)
    ..pPS(2, _omitFieldNames ? '' : 'memberIds', protoName: 'memberIds')
    ..aOS(3, _omitFieldNames ? '' : 'displayName', protoName: 'displayName')
    ..aInt64(4, _omitFieldNames ? '' : 'createdTs', protoName: 'createdTs')
    ..aInt64(5, _omitFieldNames ? '' : 'mostRecentMessageTs', protoName: 'mostRecentMessageTs')
    ..e<MessageDirection>(6, _omitFieldNames ? '' : 'mostRecentMessageDirection', $pb.PbFieldType.OE, protoName: 'mostRecentMessageDirection', defaultOrMaker: MessageDirection.OUT, valueOf: MessageDirection.valueOf, enumValues: MessageDirection.values)
    ..aOS(7, _omitFieldNames ? '' : 'mostRecentMessageText', protoName: 'mostRecentMessageText')
    ..aOS(8, _omitFieldNames ? '' : 'mostRecentAttachmentMimeType', protoName: 'mostRecentAttachmentMimeType')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'messagesDisappearAfterSeconds', $pb.PbFieldType.O3, protoName: 'messagesDisappearAfterSeconds')
    ..aInt64(10, _omitFieldNames ? '' : 'firstReceivedMessageTs', protoName: 'firstReceivedMessageTs')
    ..aOB(11, _omitFieldNames ? '' : 'hasReceivedMessage', protoName: 'hasReceivedMessage')
    ..aInt64(12, _omitFieldNames ? '' : 'mostRecentHelloTs', protoName: 'mostRecentHelloTs')
    ..e<ContactSource>(13, _omitFieldNames ? '' : 'source', $pb.PbFieldType.OE, defaultOrMaker: ContactSource.UNKNOWN, valueOf: ContactSource.valueOf, enumValues: ContactSource.values)
    ..m<$core.int, $core.String>(14, _omitFieldNames ? '' : 'applicationIds', protoName: 'applicationIds', entryClassName: 'Contact.ApplicationIdsEntry', keyFieldType: $pb.PbFieldType.O3, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('model'))
    ..e<VerificationLevel>(15, _omitFieldNames ? '' : 'verificationLevel', $pb.PbFieldType.OE, protoName: 'verificationLevel', defaultOrMaker: VerificationLevel.UNACCEPTED, valueOf: VerificationLevel.valueOf, enumValues: VerificationLevel.values)
    ..aOS(16, _omitFieldNames ? '' : 'numericFingerprint', protoName: 'numericFingerprint')
    ..aOB(17, _omitFieldNames ? '' : 'blocked')
    ..m<$core.String, Datum>(18, _omitFieldNames ? '' : 'applicationData', protoName: 'applicationData', entryClassName: 'Contact.ApplicationDataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: Datum.create, valueDefaultOrMaker: Datum.getDefault, packageName: const $pb.PackageName('model'))
    ..aOM<ChatNumber>(19, _omitFieldNames ? '' : 'chatNumber', protoName: 'chatNumber', subBuilder: ChatNumber.create)
    ..aOB(20, _omitFieldNames ? '' : 'isMe', protoName: 'isMe')
    ..a<$core.int>(21, _omitFieldNames ? '' : 'numUnviewedMessages', $pb.PbFieldType.O3, protoName: 'numUnviewedMessages')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Contact clone() => Contact()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Contact copyWith(void Function(Contact) updates) => super.copyWith((message) => updates(message as Contact)) as Contact;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Contact create() => Contact._();
  Contact createEmptyInstance() => create();
  static $pb.PbList<Contact> createRepeated() => $pb.PbList<Contact>();
  @$core.pragma('dart2js:noInline')
  static Contact getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Contact>(create);
  static Contact? _defaultInstance;

  @$pb.TagNumber(1)
  ContactId get contactId => $_getN(0);
  @$pb.TagNumber(1)
  set contactId(ContactId v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactId() => $_clearField(1);
  @$pb.TagNumber(1)
  ContactId ensureContactId() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get memberIds => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get createdTs => $_getI64(3);
  @$pb.TagNumber(4)
  set createdTs($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCreatedTs() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedTs() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get mostRecentMessageTs => $_getI64(4);
  @$pb.TagNumber(5)
  set mostRecentMessageTs($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMostRecentMessageTs() => $_has(4);
  @$pb.TagNumber(5)
  void clearMostRecentMessageTs() => $_clearField(5);

  @$pb.TagNumber(6)
  MessageDirection get mostRecentMessageDirection => $_getN(5);
  @$pb.TagNumber(6)
  set mostRecentMessageDirection(MessageDirection v) { $_setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasMostRecentMessageDirection() => $_has(5);
  @$pb.TagNumber(6)
  void clearMostRecentMessageDirection() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get mostRecentMessageText => $_getSZ(6);
  @$pb.TagNumber(7)
  set mostRecentMessageText($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMostRecentMessageText() => $_has(6);
  @$pb.TagNumber(7)
  void clearMostRecentMessageText() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get mostRecentAttachmentMimeType => $_getSZ(7);
  @$pb.TagNumber(8)
  set mostRecentAttachmentMimeType($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasMostRecentAttachmentMimeType() => $_has(7);
  @$pb.TagNumber(8)
  void clearMostRecentAttachmentMimeType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get messagesDisappearAfterSeconds => $_getIZ(8);
  @$pb.TagNumber(9)
  set messagesDisappearAfterSeconds($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasMessagesDisappearAfterSeconds() => $_has(8);
  @$pb.TagNumber(9)
  void clearMessagesDisappearAfterSeconds() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get firstReceivedMessageTs => $_getI64(9);
  @$pb.TagNumber(10)
  set firstReceivedMessageTs($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasFirstReceivedMessageTs() => $_has(9);
  @$pb.TagNumber(10)
  void clearFirstReceivedMessageTs() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get hasReceivedMessage => $_getBF(10);
  @$pb.TagNumber(11)
  set hasReceivedMessage($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasHasReceivedMessage() => $_has(10);
  @$pb.TagNumber(11)
  void clearHasReceivedMessage() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get mostRecentHelloTs => $_getI64(11);
  @$pb.TagNumber(12)
  set mostRecentHelloTs($fixnum.Int64 v) { $_setInt64(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasMostRecentHelloTs() => $_has(11);
  @$pb.TagNumber(12)
  void clearMostRecentHelloTs() => $_clearField(12);

  @$pb.TagNumber(13)
  ContactSource get source => $_getN(12);
  @$pb.TagNumber(13)
  set source(ContactSource v) { $_setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasSource() => $_has(12);
  @$pb.TagNumber(13)
  void clearSource() => $_clearField(13);

  @$pb.TagNumber(14)
  $pb.PbMap<$core.int, $core.String> get applicationIds => $_getMap(13);

  @$pb.TagNumber(15)
  VerificationLevel get verificationLevel => $_getN(14);
  @$pb.TagNumber(15)
  set verificationLevel(VerificationLevel v) { $_setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasVerificationLevel() => $_has(14);
  @$pb.TagNumber(15)
  void clearVerificationLevel() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get numericFingerprint => $_getSZ(15);
  @$pb.TagNumber(16)
  set numericFingerprint($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasNumericFingerprint() => $_has(15);
  @$pb.TagNumber(16)
  void clearNumericFingerprint() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.bool get blocked => $_getBF(16);
  @$pb.TagNumber(17)
  set blocked($core.bool v) { $_setBool(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasBlocked() => $_has(16);
  @$pb.TagNumber(17)
  void clearBlocked() => $_clearField(17);

  @$pb.TagNumber(18)
  $pb.PbMap<$core.String, Datum> get applicationData => $_getMap(17);

  @$pb.TagNumber(19)
  ChatNumber get chatNumber => $_getN(18);
  @$pb.TagNumber(19)
  set chatNumber(ChatNumber v) { $_setField(19, v); }
  @$pb.TagNumber(19)
  $core.bool hasChatNumber() => $_has(18);
  @$pb.TagNumber(19)
  void clearChatNumber() => $_clearField(19);
  @$pb.TagNumber(19)
  ChatNumber ensureChatNumber() => $_ensure(18);

  @$pb.TagNumber(20)
  $core.bool get isMe => $_getBF(19);
  @$pb.TagNumber(20)
  set isMe($core.bool v) { $_setBool(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasIsMe() => $_has(19);
  @$pb.TagNumber(20)
  void clearIsMe() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.int get numUnviewedMessages => $_getIZ(20);
  @$pb.TagNumber(21)
  set numUnviewedMessages($core.int v) { $_setSignedInt32(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasNumUnviewedMessages() => $_has(20);
  @$pb.TagNumber(21)
  void clearNumUnviewedMessages() => $_clearField(21);
}

/// A provisional direct contact that is not yet in the address book. If we receive a Hello from that
/// Contact before the ProvisionalContact expires, then the contact is added to the address book.
/// Otherwise, the provisional contact is deleted and the contactId is deleted from our Signal
/// protocol store, ensuring no trace is left of this contact.
class ProvisionalContact extends $pb.GeneratedMessage {
  factory ProvisionalContact({
    $core.String? contactId,
    $fixnum.Int64? expiresAt,
    ContactSource? source,
    VerificationLevel? verificationLevel,
  }) {
    final $result = create();
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (expiresAt != null) {
      $result.expiresAt = expiresAt;
    }
    if (source != null) {
      $result.source = source;
    }
    if (verificationLevel != null) {
      $result.verificationLevel = verificationLevel;
    }
    return $result;
  }
  ProvisionalContact._() : super();
  factory ProvisionalContact.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProvisionalContact.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProvisionalContact', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contactId', protoName: 'contactId')
    ..aInt64(2, _omitFieldNames ? '' : 'expiresAt', protoName: 'expiresAt')
    ..e<ContactSource>(3, _omitFieldNames ? '' : 'source', $pb.PbFieldType.OE, defaultOrMaker: ContactSource.UNKNOWN, valueOf: ContactSource.valueOf, enumValues: ContactSource.values)
    ..e<VerificationLevel>(4, _omitFieldNames ? '' : 'verificationLevel', $pb.PbFieldType.OE, protoName: 'verificationLevel', defaultOrMaker: VerificationLevel.UNACCEPTED, valueOf: VerificationLevel.valueOf, enumValues: VerificationLevel.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProvisionalContact clone() => ProvisionalContact()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProvisionalContact copyWith(void Function(ProvisionalContact) updates) => super.copyWith((message) => updates(message as ProvisionalContact)) as ProvisionalContact;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProvisionalContact create() => ProvisionalContact._();
  ProvisionalContact createEmptyInstance() => create();
  static $pb.PbList<ProvisionalContact> createRepeated() => $pb.PbList<ProvisionalContact>();
  @$core.pragma('dart2js:noInline')
  static ProvisionalContact getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProvisionalContact>(create);
  static ProvisionalContact? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contactId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contactId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expiresAt => $_getI64(1);
  @$pb.TagNumber(2)
  set expiresAt($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasExpiresAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresAt() => $_clearField(2);

  @$pb.TagNumber(3)
  ContactSource get source => $_getN(2);
  @$pb.TagNumber(3)
  set source(ContactSource v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSource() => $_has(2);
  @$pb.TagNumber(3)
  void clearSource() => $_clearField(3);

  @$pb.TagNumber(4)
  VerificationLevel get verificationLevel => $_getN(3);
  @$pb.TagNumber(4)
  set verificationLevel(VerificationLevel v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasVerificationLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearVerificationLevel() => $_clearField(4);
}

/// An attachment to a Message
class Attachment extends $pb.GeneratedMessage {
  factory Attachment({
    $core.String? mimeType,
    $core.List<$core.int>? keyMaterial,
    $core.List<$core.int>? digest,
    $fixnum.Int64? plaintextLength,
    $pb.PbMap<$core.String, $core.String>? metadata,
    $core.String? downloadUrl,
  }) {
    final $result = create();
    if (mimeType != null) {
      $result.mimeType = mimeType;
    }
    if (keyMaterial != null) {
      $result.keyMaterial = keyMaterial;
    }
    if (digest != null) {
      $result.digest = digest;
    }
    if (plaintextLength != null) {
      $result.plaintextLength = plaintextLength;
    }
    if (metadata != null) {
      $result.metadata.addAll(metadata);
    }
    if (downloadUrl != null) {
      $result.downloadUrl = downloadUrl;
    }
    return $result;
  }
  Attachment._() : super();
  factory Attachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Attachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Attachment', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mimeType', protoName: 'mimeType')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'keyMaterial', $pb.PbFieldType.OY, protoName: 'keyMaterial')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'digest', $pb.PbFieldType.OY)
    ..aInt64(4, _omitFieldNames ? '' : 'plaintextLength', protoName: 'plaintextLength')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'metadata', entryClassName: 'Attachment.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('model'))
    ..aOS(6, _omitFieldNames ? '' : 'downloadUrl', protoName: 'downloadUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Attachment clone() => Attachment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Attachment copyWith(void Function(Attachment) updates) => super.copyWith((message) => updates(message as Attachment)) as Attachment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Attachment create() => Attachment._();
  Attachment createEmptyInstance() => create();
  static $pb.PbList<Attachment> createRepeated() => $pb.PbList<Attachment>();
  @$core.pragma('dart2js:noInline')
  static Attachment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Attachment>(create);
  static Attachment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mimeType => $_getSZ(0);
  @$pb.TagNumber(1)
  set mimeType($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMimeType() => $_has(0);
  @$pb.TagNumber(1)
  void clearMimeType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get keyMaterial => $_getN(1);
  @$pb.TagNumber(2)
  set keyMaterial($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasKeyMaterial() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeyMaterial() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get digest => $_getN(2);
  @$pb.TagNumber(3)
  set digest($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDigest() => $_has(2);
  @$pb.TagNumber(3)
  void clearDigest() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get plaintextLength => $_getI64(3);
  @$pb.TagNumber(4)
  set plaintextLength($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPlaintextLength() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlaintextLength() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(4);

  @$pb.TagNumber(6)
  $core.String get downloadUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set downloadUrl($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDownloadUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearDownloadUrl() => $_clearField(6);
}

/// A locally stored Attachment
class StoredAttachment extends $pb.GeneratedMessage {
  factory StoredAttachment({
    $core.String? guid,
    Attachment? attachment,
    $core.String? encryptedFilePath,
    StoredAttachment_Status? status,
    $core.String? plainTextFilePath,
    StoredAttachment? thumbnail,
  }) {
    final $result = create();
    if (guid != null) {
      $result.guid = guid;
    }
    if (attachment != null) {
      $result.attachment = attachment;
    }
    if (encryptedFilePath != null) {
      $result.encryptedFilePath = encryptedFilePath;
    }
    if (status != null) {
      $result.status = status;
    }
    if (plainTextFilePath != null) {
      $result.plainTextFilePath = plainTextFilePath;
    }
    if (thumbnail != null) {
      $result.thumbnail = thumbnail;
    }
    return $result;
  }
  StoredAttachment._() : super();
  factory StoredAttachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoredAttachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoredAttachment', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'guid')
    ..aOM<Attachment>(2, _omitFieldNames ? '' : 'attachment', subBuilder: Attachment.create)
    ..aOS(3, _omitFieldNames ? '' : 'encryptedFilePath', protoName: 'encryptedFilePath')
    ..e<StoredAttachment_Status>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: StoredAttachment_Status.PENDING, valueOf: StoredAttachment_Status.valueOf, enumValues: StoredAttachment_Status.values)
    ..aOS(5, _omitFieldNames ? '' : 'plainTextFilePath', protoName: 'plainTextFilePath')
    ..aOM<StoredAttachment>(6, _omitFieldNames ? '' : 'thumbnail', subBuilder: StoredAttachment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoredAttachment clone() => StoredAttachment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoredAttachment copyWith(void Function(StoredAttachment) updates) => super.copyWith((message) => updates(message as StoredAttachment)) as StoredAttachment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoredAttachment create() => StoredAttachment._();
  StoredAttachment createEmptyInstance() => create();
  static $pb.PbList<StoredAttachment> createRepeated() => $pb.PbList<StoredAttachment>();
  @$core.pragma('dart2js:noInline')
  static StoredAttachment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoredAttachment>(create);
  static StoredAttachment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get guid => $_getSZ(0);
  @$pb.TagNumber(1)
  set guid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearGuid() => $_clearField(1);

  @$pb.TagNumber(2)
  Attachment get attachment => $_getN(1);
  @$pb.TagNumber(2)
  set attachment(Attachment v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAttachment() => $_has(1);
  @$pb.TagNumber(2)
  void clearAttachment() => $_clearField(2);
  @$pb.TagNumber(2)
  Attachment ensureAttachment() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get encryptedFilePath => $_getSZ(2);
  @$pb.TagNumber(3)
  set encryptedFilePath($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEncryptedFilePath() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedFilePath() => $_clearField(3);

  @$pb.TagNumber(4)
  StoredAttachment_Status get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(StoredAttachment_Status v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get plainTextFilePath => $_getSZ(4);
  @$pb.TagNumber(5)
  set plainTextFilePath($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPlainTextFilePath() => $_has(4);
  @$pb.TagNumber(5)
  void clearPlainTextFilePath() => $_clearField(5);

  @$pb.TagNumber(6)
  StoredAttachment get thumbnail => $_getN(5);
  @$pb.TagNumber(6)
  set thumbnail(StoredAttachment v) { $_setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasThumbnail() => $_has(5);
  @$pb.TagNumber(6)
  void clearThumbnail() => $_clearField(6);
  @$pb.TagNumber(6)
  StoredAttachment ensureThumbnail() => $_ensure(5);
}

/// An attachment with optional associated Thumbnail
class AttachmentWithThumbnail extends $pb.GeneratedMessage {
  factory AttachmentWithThumbnail({
    Attachment? attachment,
    Attachment? thumbnail,
  }) {
    final $result = create();
    if (attachment != null) {
      $result.attachment = attachment;
    }
    if (thumbnail != null) {
      $result.thumbnail = thumbnail;
    }
    return $result;
  }
  AttachmentWithThumbnail._() : super();
  factory AttachmentWithThumbnail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AttachmentWithThumbnail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AttachmentWithThumbnail', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOM<Attachment>(1, _omitFieldNames ? '' : 'attachment', subBuilder: Attachment.create)
    ..aOM<Attachment>(2, _omitFieldNames ? '' : 'thumbnail', subBuilder: Attachment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AttachmentWithThumbnail clone() => AttachmentWithThumbnail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AttachmentWithThumbnail copyWith(void Function(AttachmentWithThumbnail) updates) => super.copyWith((message) => updates(message as AttachmentWithThumbnail)) as AttachmentWithThumbnail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttachmentWithThumbnail create() => AttachmentWithThumbnail._();
  AttachmentWithThumbnail createEmptyInstance() => create();
  static $pb.PbList<AttachmentWithThumbnail> createRepeated() => $pb.PbList<AttachmentWithThumbnail>();
  @$core.pragma('dart2js:noInline')
  static AttachmentWithThumbnail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttachmentWithThumbnail>(create);
  static AttachmentWithThumbnail? _defaultInstance;

  @$pb.TagNumber(1)
  Attachment get attachment => $_getN(0);
  @$pb.TagNumber(1)
  set attachment(Attachment v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAttachment() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttachment() => $_clearField(1);
  @$pb.TagNumber(1)
  Attachment ensureAttachment() => $_ensure(0);

  @$pb.TagNumber(2)
  Attachment get thumbnail => $_getN(1);
  @$pb.TagNumber(2)
  set thumbnail(Attachment v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasThumbnail() => $_has(1);
  @$pb.TagNumber(2)
  void clearThumbnail() => $_clearField(2);
  @$pb.TagNumber(2)
  Attachment ensureThumbnail() => $_ensure(1);
}

/// Introduction is an introduction to a potential direct Contact
class Introduction extends $pb.GeneratedMessage {
  factory Introduction({
    $core.List<$core.int>? id,
    $core.String? displayName,
    VerificationLevel? verificationLevel,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (verificationLevel != null) {
      $result.verificationLevel = verificationLevel;
    }
    return $result;
  }
  Introduction._() : super();
  factory Introduction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Introduction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Introduction', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'displayName', protoName: 'displayName')
    ..e<VerificationLevel>(3, _omitFieldNames ? '' : 'verificationLevel', $pb.PbFieldType.OE, protoName: 'verificationLevel', defaultOrMaker: VerificationLevel.UNACCEPTED, valueOf: VerificationLevel.valueOf, enumValues: VerificationLevel.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Introduction clone() => Introduction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Introduction copyWith(void Function(Introduction) updates) => super.copyWith((message) => updates(message as Introduction)) as Introduction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Introduction create() => Introduction._();
  Introduction createEmptyInstance() => create();
  static $pb.PbList<Introduction> createRepeated() => $pb.PbList<Introduction>();
  @$core.pragma('dart2js:noInline')
  static Introduction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Introduction>(create);
  static Introduction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  VerificationLevel get verificationLevel => $_getN(2);
  @$pb.TagNumber(3)
  set verificationLevel(VerificationLevel v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasVerificationLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerificationLevel() => $_clearField(3);
}

/// Details of an Introduction (attached to a StoredMessage)
class IntroductionDetails extends $pb.GeneratedMessage {
  factory IntroductionDetails({
    ContactId? to,
    $core.String? displayName,
    $core.String? originalDisplayName,
    IntroductionDetails_IntroductionStatus? status,
    VerificationLevel? verificationLevel,
    VerificationLevel? constrainedVerificationLevel,
  }) {
    final $result = create();
    if (to != null) {
      $result.to = to;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (originalDisplayName != null) {
      $result.originalDisplayName = originalDisplayName;
    }
    if (status != null) {
      $result.status = status;
    }
    if (verificationLevel != null) {
      $result.verificationLevel = verificationLevel;
    }
    if (constrainedVerificationLevel != null) {
      $result.constrainedVerificationLevel = constrainedVerificationLevel;
    }
    return $result;
  }
  IntroductionDetails._() : super();
  factory IntroductionDetails.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IntroductionDetails.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'IntroductionDetails', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOM<ContactId>(1, _omitFieldNames ? '' : 'to', subBuilder: ContactId.create)
    ..aOS(2, _omitFieldNames ? '' : 'displayName', protoName: 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'originalDisplayName', protoName: 'originalDisplayName')
    ..e<IntroductionDetails_IntroductionStatus>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: IntroductionDetails_IntroductionStatus.PENDING, valueOf: IntroductionDetails_IntroductionStatus.valueOf, enumValues: IntroductionDetails_IntroductionStatus.values)
    ..e<VerificationLevel>(5, _omitFieldNames ? '' : 'verificationLevel', $pb.PbFieldType.OE, protoName: 'verificationLevel', defaultOrMaker: VerificationLevel.UNACCEPTED, valueOf: VerificationLevel.valueOf, enumValues: VerificationLevel.values)
    ..e<VerificationLevel>(6, _omitFieldNames ? '' : 'constrainedVerificationLevel', $pb.PbFieldType.OE, protoName: 'constrainedVerificationLevel', defaultOrMaker: VerificationLevel.UNACCEPTED, valueOf: VerificationLevel.valueOf, enumValues: VerificationLevel.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  IntroductionDetails clone() => IntroductionDetails()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  IntroductionDetails copyWith(void Function(IntroductionDetails) updates) => super.copyWith((message) => updates(message as IntroductionDetails)) as IntroductionDetails;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IntroductionDetails create() => IntroductionDetails._();
  IntroductionDetails createEmptyInstance() => create();
  static $pb.PbList<IntroductionDetails> createRepeated() => $pb.PbList<IntroductionDetails>();
  @$core.pragma('dart2js:noInline')
  static IntroductionDetails getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IntroductionDetails>(create);
  static IntroductionDetails? _defaultInstance;

  @$pb.TagNumber(1)
  ContactId get to => $_getN(0);
  @$pb.TagNumber(1)
  set to(ContactId v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTo() => $_has(0);
  @$pb.TagNumber(1)
  void clearTo() => $_clearField(1);
  @$pb.TagNumber(1)
  ContactId ensureTo() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  /// may change when accepting an Introduction to the same contact made by
  /// someone else.
  @$pb.TagNumber(3)
  $core.String get originalDisplayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set originalDisplayName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOriginalDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginalDisplayName() => $_clearField(3);

  @$pb.TagNumber(4)
  IntroductionDetails_IntroductionStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(IntroductionDetails_IntroductionStatus v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  VerificationLevel get verificationLevel => $_getN(4);
  @$pb.TagNumber(5)
  set verificationLevel(VerificationLevel v) { $_setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasVerificationLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearVerificationLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  VerificationLevel get constrainedVerificationLevel => $_getN(5);
  @$pb.TagNumber(6)
  set constrainedVerificationLevel(VerificationLevel v) { $_setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasConstrainedVerificationLevel() => $_has(5);
  @$pb.TagNumber(6)
  void clearConstrainedVerificationLevel() => $_clearField(6);
}

/// A text message with attachments, the primary type of message exchanged by users.
class Message extends $pb.GeneratedMessage {
  factory Message({
    $core.List<$core.int>? id,
    $core.List<$core.int>? replyToSenderId,
    $core.List<$core.int>? replyToId,
    $core.String? text,
    $pb.PbMap<$core.int, AttachmentWithThumbnail>? attachments,
    $core.int? disappearAfterSeconds,
    Introduction? introduction,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (replyToSenderId != null) {
      $result.replyToSenderId = replyToSenderId;
    }
    if (replyToId != null) {
      $result.replyToId = replyToId;
    }
    if (text != null) {
      $result.text = text;
    }
    if (attachments != null) {
      $result.attachments.addAll(attachments);
    }
    if (disappearAfterSeconds != null) {
      $result.disappearAfterSeconds = disappearAfterSeconds;
    }
    if (introduction != null) {
      $result.introduction = introduction;
    }
    return $result;
  }
  Message._() : super();
  factory Message.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'replyToSenderId', $pb.PbFieldType.OY, protoName: 'replyToSenderId')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'replyToId', $pb.PbFieldType.OY, protoName: 'replyToId')
    ..aOS(4, _omitFieldNames ? '' : 'text')
    ..m<$core.int, AttachmentWithThumbnail>(5, _omitFieldNames ? '' : 'attachments', entryClassName: 'Message.AttachmentsEntry', keyFieldType: $pb.PbFieldType.O3, valueFieldType: $pb.PbFieldType.OM, valueCreator: AttachmentWithThumbnail.create, valueDefaultOrMaker: AttachmentWithThumbnail.getDefault, packageName: const $pb.PackageName('model'))
    ..a<$core.int>(6, _omitFieldNames ? '' : 'disappearAfterSeconds', $pb.PbFieldType.O3, protoName: 'disappearAfterSeconds')
    ..aOM<Introduction>(7, _omitFieldNames ? '' : 'introduction', subBuilder: Introduction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message clone() => Message()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message copyWith(void Function(Message) updates) => super.copyWith((message) => updates(message as Message)) as Message;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message create() => Message._();
  Message createEmptyInstance() => create();
  static $pb.PbList<Message> createRepeated() => $pb.PbList<Message>();
  @$core.pragma('dart2js:noInline')
  static Message getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message>(create);
  static Message? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get replyToSenderId => $_getN(1);
  @$pb.TagNumber(2)
  set replyToSenderId($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReplyToSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReplyToSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get replyToId => $_getN(2);
  @$pb.TagNumber(3)
  set replyToId($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReplyToId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReplyToId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get text => $_getSZ(3);
  @$pb.TagNumber(4)
  set text($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.int, AttachmentWithThumbnail> get attachments => $_getMap(4);

  @$pb.TagNumber(6)
  $core.int get disappearAfterSeconds => $_getIZ(5);
  @$pb.TagNumber(6)
  set disappearAfterSeconds($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDisappearAfterSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearDisappearAfterSeconds() => $_clearField(6);

  @$pb.TagNumber(7)
  Introduction get introduction => $_getN(6);
  @$pb.TagNumber(7)
  set introduction(Introduction v) { $_setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasIntroduction() => $_has(6);
  @$pb.TagNumber(7)
  void clearIntroduction() => $_clearField(7);
  @$pb.TagNumber(7)
  Introduction ensureIntroduction() => $_ensure(6);
}

/// A locally stored Message
class StoredMessage extends $pb.GeneratedMessage {
  factory StoredMessage({
    ContactId? contactId,
    $core.String? senderId,
    $core.String? id,
    $fixnum.Int64? ts,
    $core.String? replyToSenderId,
    $core.String? replyToId,
    $core.String? text,
    $core.int? disappearAfterSeconds,
    $pb.PbMap<$core.int, StoredAttachment>? attachments,
    MessageDirection? direction,
    $pb.PbMap<$core.String, Reaction>? reactions,
    StoredMessage_DeliveryStatus? status,
    $fixnum.Int64? firstViewedAt,
    $fixnum.Int64? disappearAt,
    $pb.PbMap<$core.int, $core.int>? thumbnails,
    $fixnum.Int64? remotelyDeletedAt,
    ContactId? remotelyDeletedBy,
    IntroductionDetails? introduction,
  }) {
    final $result = create();
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (senderId != null) {
      $result.senderId = senderId;
    }
    if (id != null) {
      $result.id = id;
    }
    if (ts != null) {
      $result.ts = ts;
    }
    if (replyToSenderId != null) {
      $result.replyToSenderId = replyToSenderId;
    }
    if (replyToId != null) {
      $result.replyToId = replyToId;
    }
    if (text != null) {
      $result.text = text;
    }
    if (disappearAfterSeconds != null) {
      $result.disappearAfterSeconds = disappearAfterSeconds;
    }
    if (attachments != null) {
      $result.attachments.addAll(attachments);
    }
    if (direction != null) {
      $result.direction = direction;
    }
    if (reactions != null) {
      $result.reactions.addAll(reactions);
    }
    if (status != null) {
      $result.status = status;
    }
    if (firstViewedAt != null) {
      $result.firstViewedAt = firstViewedAt;
    }
    if (disappearAt != null) {
      $result.disappearAt = disappearAt;
    }
    if (thumbnails != null) {
      $result.thumbnails.addAll(thumbnails);
    }
    if (remotelyDeletedAt != null) {
      $result.remotelyDeletedAt = remotelyDeletedAt;
    }
    if (remotelyDeletedBy != null) {
      $result.remotelyDeletedBy = remotelyDeletedBy;
    }
    if (introduction != null) {
      $result.introduction = introduction;
    }
    return $result;
  }
  StoredMessage._() : super();
  factory StoredMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoredMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoredMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOM<ContactId>(1, _omitFieldNames ? '' : 'contactId', protoName: 'contactId', subBuilder: ContactId.create)
    ..aOS(2, _omitFieldNames ? '' : 'senderId', protoName: 'senderId')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..aInt64(4, _omitFieldNames ? '' : 'ts')
    ..aOS(5, _omitFieldNames ? '' : 'replyToSenderId', protoName: 'replyToSenderId')
    ..aOS(6, _omitFieldNames ? '' : 'replyToId', protoName: 'replyToId')
    ..aOS(7, _omitFieldNames ? '' : 'text')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'disappearAfterSeconds', $pb.PbFieldType.O3, protoName: 'disappearAfterSeconds')
    ..m<$core.int, StoredAttachment>(9, _omitFieldNames ? '' : 'attachments', entryClassName: 'StoredMessage.AttachmentsEntry', keyFieldType: $pb.PbFieldType.O3, valueFieldType: $pb.PbFieldType.OM, valueCreator: StoredAttachment.create, valueDefaultOrMaker: StoredAttachment.getDefault, packageName: const $pb.PackageName('model'))
    ..e<MessageDirection>(10, _omitFieldNames ? '' : 'direction', $pb.PbFieldType.OE, defaultOrMaker: MessageDirection.OUT, valueOf: MessageDirection.valueOf, enumValues: MessageDirection.values)
    ..m<$core.String, Reaction>(11, _omitFieldNames ? '' : 'reactions', entryClassName: 'StoredMessage.ReactionsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: Reaction.create, valueDefaultOrMaker: Reaction.getDefault, packageName: const $pb.PackageName('model'))
    ..e<StoredMessage_DeliveryStatus>(12, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: StoredMessage_DeliveryStatus.SENDING, valueOf: StoredMessage_DeliveryStatus.valueOf, enumValues: StoredMessage_DeliveryStatus.values)
    ..aInt64(13, _omitFieldNames ? '' : 'firstViewedAt', protoName: 'firstViewedAt')
    ..aInt64(14, _omitFieldNames ? '' : 'disappearAt', protoName: 'disappearAt')
    ..m<$core.int, $core.int>(15, _omitFieldNames ? '' : 'thumbnails', entryClassName: 'StoredMessage.ThumbnailsEntry', keyFieldType: $pb.PbFieldType.O3, valueFieldType: $pb.PbFieldType.O3, packageName: const $pb.PackageName('model'))
    ..aInt64(16, _omitFieldNames ? '' : 'remotelyDeletedAt', protoName: 'remotelyDeletedAt')
    ..aOM<ContactId>(17, _omitFieldNames ? '' : 'remotelyDeletedBy', protoName: 'remotelyDeletedBy', subBuilder: ContactId.create)
    ..aOM<IntroductionDetails>(18, _omitFieldNames ? '' : 'introduction', subBuilder: IntroductionDetails.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoredMessage clone() => StoredMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoredMessage copyWith(void Function(StoredMessage) updates) => super.copyWith((message) => updates(message as StoredMessage)) as StoredMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoredMessage create() => StoredMessage._();
  StoredMessage createEmptyInstance() => create();
  static $pb.PbList<StoredMessage> createRepeated() => $pb.PbList<StoredMessage>();
  @$core.pragma('dart2js:noInline')
  static StoredMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoredMessage>(create);
  static StoredMessage? _defaultInstance;

  @$pb.TagNumber(1)
  ContactId get contactId => $_getN(0);
  @$pb.TagNumber(1)
  set contactId(ContactId v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactId() => $_clearField(1);
  @$pb.TagNumber(1)
  ContactId ensureContactId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get senderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get ts => $_getI64(3);
  @$pb.TagNumber(4)
  set ts($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTs() => $_has(3);
  @$pb.TagNumber(4)
  void clearTs() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get replyToSenderId => $_getSZ(4);
  @$pb.TagNumber(5)
  set replyToSenderId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReplyToSenderId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReplyToSenderId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get replyToId => $_getSZ(5);
  @$pb.TagNumber(6)
  set replyToId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReplyToId() => $_has(5);
  @$pb.TagNumber(6)
  void clearReplyToId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get text => $_getSZ(6);
  @$pb.TagNumber(7)
  set text($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasText() => $_has(6);
  @$pb.TagNumber(7)
  void clearText() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get disappearAfterSeconds => $_getIZ(7);
  @$pb.TagNumber(8)
  set disappearAfterSeconds($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasDisappearAfterSeconds() => $_has(7);
  @$pb.TagNumber(8)
  void clearDisappearAfterSeconds() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbMap<$core.int, StoredAttachment> get attachments => $_getMap(8);

  @$pb.TagNumber(10)
  MessageDirection get direction => $_getN(9);
  @$pb.TagNumber(10)
  set direction(MessageDirection v) { $_setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasDirection() => $_has(9);
  @$pb.TagNumber(10)
  void clearDirection() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbMap<$core.String, Reaction> get reactions => $_getMap(10);

  @$pb.TagNumber(12)
  StoredMessage_DeliveryStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(StoredMessage_DeliveryStatus v) { $_setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get firstViewedAt => $_getI64(12);
  @$pb.TagNumber(13)
  set firstViewedAt($fixnum.Int64 v) { $_setInt64(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasFirstViewedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearFirstViewedAt() => $_clearField(13);

  @$pb.TagNumber(14)
  $fixnum.Int64 get disappearAt => $_getI64(13);
  @$pb.TagNumber(14)
  set disappearAt($fixnum.Int64 v) { $_setInt64(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasDisappearAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearDisappearAt() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbMap<$core.int, $core.int> get thumbnails => $_getMap(14);

  @$pb.TagNumber(16)
  $fixnum.Int64 get remotelyDeletedAt => $_getI64(15);
  @$pb.TagNumber(16)
  set remotelyDeletedAt($fixnum.Int64 v) { $_setInt64(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasRemotelyDeletedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearRemotelyDeletedAt() => $_clearField(16);

  @$pb.TagNumber(17)
  ContactId get remotelyDeletedBy => $_getN(16);
  @$pb.TagNumber(17)
  set remotelyDeletedBy(ContactId v) { $_setField(17, v); }
  @$pb.TagNumber(17)
  $core.bool hasRemotelyDeletedBy() => $_has(16);
  @$pb.TagNumber(17)
  void clearRemotelyDeletedBy() => $_clearField(17);
  @$pb.TagNumber(17)
  ContactId ensureRemotelyDeletedBy() => $_ensure(16);

  @$pb.TagNumber(18)
  IntroductionDetails get introduction => $_getN(17);
  @$pb.TagNumber(18)
  set introduction(IntroductionDetails v) { $_setField(18, v); }
  @$pb.TagNumber(18)
  $core.bool hasIntroduction() => $_has(17);
  @$pb.TagNumber(18)
  void clearIntroduction() => $_clearField(18);
  @$pb.TagNumber(18)
  IntroductionDetails ensureIntroduction() => $_ensure(17);
}

/// A reaction to a message
class Reaction extends $pb.GeneratedMessage {
  factory Reaction({
    $core.List<$core.int>? reactingToSenderId,
    $core.List<$core.int>? reactingToMessageId,
    $core.String? emoticon,
  }) {
    final $result = create();
    if (reactingToSenderId != null) {
      $result.reactingToSenderId = reactingToSenderId;
    }
    if (reactingToMessageId != null) {
      $result.reactingToMessageId = reactingToMessageId;
    }
    if (emoticon != null) {
      $result.emoticon = emoticon;
    }
    return $result;
  }
  Reaction._() : super();
  factory Reaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Reaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Reaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'reactingToSenderId', $pb.PbFieldType.OY, protoName: 'reactingToSenderId')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'reactingToMessageId', $pb.PbFieldType.OY, protoName: 'reactingToMessageId')
    ..aOS(3, _omitFieldNames ? '' : 'emoticon')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Reaction clone() => Reaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Reaction copyWith(void Function(Reaction) updates) => super.copyWith((message) => updates(message as Reaction)) as Reaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Reaction create() => Reaction._();
  Reaction createEmptyInstance() => create();
  static $pb.PbList<Reaction> createRepeated() => $pb.PbList<Reaction>();
  @$core.pragma('dart2js:noInline')
  static Reaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Reaction>(create);
  static Reaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get reactingToSenderId => $_getN(0);
  @$pb.TagNumber(1)
  set reactingToSenderId($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReactingToSenderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReactingToSenderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get reactingToMessageId => $_getN(1);
  @$pb.TagNumber(2)
  set reactingToMessageId($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReactingToMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReactingToMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get emoticon => $_getSZ(2);
  @$pb.TagNumber(3)
  set emoticon($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEmoticon() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmoticon() => $_clearField(3);
}

/// An update to disappearing message settings
class DisappearSettings extends $pb.GeneratedMessage {
  factory DisappearSettings({
    $core.int? messagesDisappearAfterSeconds,
  }) {
    final $result = create();
    if (messagesDisappearAfterSeconds != null) {
      $result.messagesDisappearAfterSeconds = messagesDisappearAfterSeconds;
    }
    return $result;
  }
  DisappearSettings._() : super();
  factory DisappearSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DisappearSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisappearSettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'messagesDisappearAfterSeconds', $pb.PbFieldType.O3, protoName: 'messagesDisappearAfterSeconds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DisappearSettings clone() => DisappearSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DisappearSettings copyWith(void Function(DisappearSettings) updates) => super.copyWith((message) => updates(message as DisappearSettings)) as DisappearSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisappearSettings create() => DisappearSettings._();
  DisappearSettings createEmptyInstance() => create();
  static $pb.PbList<DisappearSettings> createRepeated() => $pb.PbList<DisappearSettings>();
  @$core.pragma('dart2js:noInline')
  static DisappearSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisappearSettings>(create);
  static DisappearSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get messagesDisappearAfterSeconds => $_getIZ(0);
  @$pb.TagNumber(1)
  set messagesDisappearAfterSeconds($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessagesDisappearAfterSeconds() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessagesDisappearAfterSeconds() => $_clearField(1);
}

/// A Hello from a Contact. If this Hello is not marked as final, we'll respond with a final Hello of
/// our own. Hellos are only processed in conjunction with ProvisionalContacts.
class Hello extends $pb.GeneratedMessage {
  factory Hello({
    $core.bool? final_2,
  }) {
    final $result = create();
    if (final_2 != null) {
      $result.final_2 = final_2;
    }
    return $result;
  }
  Hello._() : super();
  factory Hello.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Hello.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Hello', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOB(2, _omitFieldNames ? '' : 'final')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Hello clone() => Hello()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Hello copyWith(void Function(Hello) updates) => super.copyWith((message) => updates(message as Hello)) as Hello;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Hello create() => Hello._();
  Hello createEmptyInstance() => create();
  static $pb.PbList<Hello> createRepeated() => $pb.PbList<Hello>();
  @$core.pragma('dart2js:noInline')
  static Hello getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Hello>(create);
  static Hello? _defaultInstance;

  @$pb.TagNumber(2)
  $core.bool get final_2 => $_getBF(0);
  @$pb.TagNumber(2)
  set final_2($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(2)
  $core.bool hasFinal_2() => $_has(0);
  @$pb.TagNumber(2)
  void clearFinal_2() => $_clearField(2);
}

enum TransferMessage_Content {
  message, 
  reaction, 
  deleteMessageId, 
  disappearSettings, 
  hello, 
  webRTCSignal, 
  notSet
}

/// An envelope for messages to be transferred via the message broker
class TransferMessage extends $pb.GeneratedMessage {
  factory TransferMessage({
    $core.List<$core.int>? message,
    $core.List<$core.int>? reaction,
    $core.List<$core.int>? deleteMessageId,
    $core.List<$core.int>? disappearSettings,
    $core.List<$core.int>? hello,
    $core.List<$core.int>? webRTCSignal,
    $fixnum.Int64? sent,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    if (reaction != null) {
      $result.reaction = reaction;
    }
    if (deleteMessageId != null) {
      $result.deleteMessageId = deleteMessageId;
    }
    if (disappearSettings != null) {
      $result.disappearSettings = disappearSettings;
    }
    if (hello != null) {
      $result.hello = hello;
    }
    if (webRTCSignal != null) {
      $result.webRTCSignal = webRTCSignal;
    }
    if (sent != null) {
      $result.sent = sent;
    }
    return $result;
  }
  TransferMessage._() : super();
  factory TransferMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, TransferMessage_Content> _TransferMessage_ContentByTag = {
    1 : TransferMessage_Content.message,
    2 : TransferMessage_Content.reaction,
    3 : TransferMessage_Content.deleteMessageId,
    4 : TransferMessage_Content.disappearSettings,
    5 : TransferMessage_Content.hello,
    6 : TransferMessage_Content.webRTCSignal,
    0 : TransferMessage_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6])
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'message', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'reaction', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'deleteMessageId', $pb.PbFieldType.OY, protoName: 'deleteMessageId')
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'disappearSettings', $pb.PbFieldType.OY, protoName: 'disappearSettings')
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'hello', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'webRTCSignal', $pb.PbFieldType.OY, protoName: 'webRTCSignal')
    ..aInt64(10000, _omitFieldNames ? '' : 'sent')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferMessage clone() => TransferMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferMessage copyWith(void Function(TransferMessage) updates) => super.copyWith((message) => updates(message as TransferMessage)) as TransferMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferMessage create() => TransferMessage._();
  TransferMessage createEmptyInstance() => create();
  static $pb.PbList<TransferMessage> createRepeated() => $pb.PbList<TransferMessage>();
  @$core.pragma('dart2js:noInline')
  static TransferMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferMessage>(create);
  static TransferMessage? _defaultInstance;

  TransferMessage_Content whichContent() => _TransferMessage_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.List<$core.int> get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get reaction => $_getN(1);
  @$pb.TagNumber(2)
  set reaction($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearReaction() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get deleteMessageId => $_getN(2);
  @$pb.TagNumber(3)
  set deleteMessageId($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeleteMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeleteMessageId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get disappearSettings => $_getN(3);
  @$pb.TagNumber(4)
  set disappearSettings($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDisappearSettings() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisappearSettings() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get hello => $_getN(4);
  @$pb.TagNumber(5)
  set hello($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHello() => $_has(4);
  @$pb.TagNumber(5)
  void clearHello() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get webRTCSignal => $_getN(5);
  @$pb.TagNumber(6)
  set webRTCSignal($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasWebRTCSignal() => $_has(5);
  @$pb.TagNumber(6)
  void clearWebRTCSignal() => $_clearField(6);

  @$pb.TagNumber(10000)
  $fixnum.Int64 get sent => $_getI64(6);
  @$pb.TagNumber(10000)
  set sent($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(10000)
  $core.bool hasSent() => $_has(6);
  @$pb.TagNumber(10000)
  void clearSent() => $_clearField(10000);
}

enum OutboundMessage_Content {
  messageId, 
  reaction, 
  deleteMessageId, 
  disappearSettings, 
  hello, 
  notSet
}

/// An outbound Message
class OutboundMessage extends $pb.GeneratedMessage {
  factory OutboundMessage({
    $core.String? id,
    $core.String? senderId,
    $core.String? recipientId,
    $fixnum.Int64? sent,
    $pb.PbMap<$core.String, OutboundMessage_SubDeliveryStatus>? subDeliveryStatuses,
    $core.String? messageId,
    $core.List<$core.int>? reaction,
    $core.List<$core.int>? deleteMessageId,
    $core.List<$core.int>? disappearSettings,
    $core.List<$core.int>? hello,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (senderId != null) {
      $result.senderId = senderId;
    }
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (sent != null) {
      $result.sent = sent;
    }
    if (subDeliveryStatuses != null) {
      $result.subDeliveryStatuses.addAll(subDeliveryStatuses);
    }
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (reaction != null) {
      $result.reaction = reaction;
    }
    if (deleteMessageId != null) {
      $result.deleteMessageId = deleteMessageId;
    }
    if (disappearSettings != null) {
      $result.disappearSettings = disappearSettings;
    }
    if (hello != null) {
      $result.hello = hello;
    }
    return $result;
  }
  OutboundMessage._() : super();
  factory OutboundMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OutboundMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, OutboundMessage_Content> _OutboundMessage_ContentByTag = {
    31 : OutboundMessage_Content.messageId,
    32 : OutboundMessage_Content.reaction,
    33 : OutboundMessage_Content.deleteMessageId,
    34 : OutboundMessage_Content.disappearSettings,
    35 : OutboundMessage_Content.hello,
    0 : OutboundMessage_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OutboundMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..oo(0, [31, 32, 33, 34, 35])
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'senderId', protoName: 'senderId')
    ..aOS(3, _omitFieldNames ? '' : 'recipientId', protoName: 'recipientId')
    ..aInt64(4, _omitFieldNames ? '' : 'sent')
    ..m<$core.String, OutboundMessage_SubDeliveryStatus>(5, _omitFieldNames ? '' : 'subDeliveryStatuses', protoName: 'subDeliveryStatuses', entryClassName: 'OutboundMessage.SubDeliveryStatusesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OE, valueOf: OutboundMessage_SubDeliveryStatus.valueOf, enumValues: OutboundMessage_SubDeliveryStatus.values, valueDefaultOrMaker: OutboundMessage_SubDeliveryStatus.SENDING, defaultEnumValue: OutboundMessage_SubDeliveryStatus.SENDING, packageName: const $pb.PackageName('model'))
    ..aOS(31, _omitFieldNames ? '' : 'messageId', protoName: 'messageId')
    ..a<$core.List<$core.int>>(32, _omitFieldNames ? '' : 'reaction', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(33, _omitFieldNames ? '' : 'deleteMessageId', $pb.PbFieldType.OY, protoName: 'deleteMessageId')
    ..a<$core.List<$core.int>>(34, _omitFieldNames ? '' : 'disappearSettings', $pb.PbFieldType.OY, protoName: 'disappearSettings')
    ..a<$core.List<$core.int>>(35, _omitFieldNames ? '' : 'hello', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OutboundMessage clone() => OutboundMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OutboundMessage copyWith(void Function(OutboundMessage) updates) => super.copyWith((message) => updates(message as OutboundMessage)) as OutboundMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutboundMessage create() => OutboundMessage._();
  OutboundMessage createEmptyInstance() => create();
  static $pb.PbList<OutboundMessage> createRepeated() => $pb.PbList<OutboundMessage>();
  @$core.pragma('dart2js:noInline')
  static OutboundMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OutboundMessage>(create);
  static OutboundMessage? _defaultInstance;

  OutboundMessage_Content whichContent() => _OutboundMessage_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get senderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get recipientId => $_getSZ(2);
  @$pb.TagNumber(3)
  set recipientId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRecipientId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecipientId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sent => $_getI64(3);
  @$pb.TagNumber(4)
  set sent($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSent() => $_has(3);
  @$pb.TagNumber(4)
  void clearSent() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, OutboundMessage_SubDeliveryStatus> get subDeliveryStatuses => $_getMap(4);

  @$pb.TagNumber(31)
  $core.String get messageId => $_getSZ(5);
  @$pb.TagNumber(31)
  set messageId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(31)
  $core.bool hasMessageId() => $_has(5);
  @$pb.TagNumber(31)
  void clearMessageId() => $_clearField(31);

  @$pb.TagNumber(32)
  $core.List<$core.int> get reaction => $_getN(6);
  @$pb.TagNumber(32)
  set reaction($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(32)
  $core.bool hasReaction() => $_has(6);
  @$pb.TagNumber(32)
  void clearReaction() => $_clearField(32);

  @$pb.TagNumber(33)
  $core.List<$core.int> get deleteMessageId => $_getN(7);
  @$pb.TagNumber(33)
  set deleteMessageId($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(33)
  $core.bool hasDeleteMessageId() => $_has(7);
  @$pb.TagNumber(33)
  void clearDeleteMessageId() => $_clearField(33);

  @$pb.TagNumber(34)
  $core.List<$core.int> get disappearSettings => $_getN(8);
  @$pb.TagNumber(34)
  set disappearSettings($core.List<$core.int> v) { $_setBytes(8, v); }
  @$pb.TagNumber(34)
  $core.bool hasDisappearSettings() => $_has(8);
  @$pb.TagNumber(34)
  void clearDisappearSettings() => $_clearField(34);

  @$pb.TagNumber(35)
  $core.List<$core.int> get hello => $_getN(9);
  @$pb.TagNumber(35)
  set hello($core.List<$core.int> v) { $_setBytes(9, v); }
  @$pb.TagNumber(35)
  $core.bool hasHello() => $_has(9);
  @$pb.TagNumber(35)
  void clearHello() => $_clearField(35);
}

/// An inbound Attachment
class InboundAttachment extends $pb.GeneratedMessage {
  factory InboundAttachment({
    $core.String? senderId,
    $core.String? messageId,
    $fixnum.Int64? ts,
    $core.int? attachmentId,
    $core.bool? isThumbnail,
  }) {
    final $result = create();
    if (senderId != null) {
      $result.senderId = senderId;
    }
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (ts != null) {
      $result.ts = ts;
    }
    if (attachmentId != null) {
      $result.attachmentId = attachmentId;
    }
    if (isThumbnail != null) {
      $result.isThumbnail = isThumbnail;
    }
    return $result;
  }
  InboundAttachment._() : super();
  factory InboundAttachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InboundAttachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InboundAttachment', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'senderId', protoName: 'senderId')
    ..aOS(2, _omitFieldNames ? '' : 'messageId', protoName: 'messageId')
    ..aInt64(3, _omitFieldNames ? '' : 'ts')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'attachmentId', $pb.PbFieldType.O3, protoName: 'attachmentId')
    ..aOB(5, _omitFieldNames ? '' : 'isThumbnail', protoName: 'isThumbnail')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InboundAttachment clone() => InboundAttachment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InboundAttachment copyWith(void Function(InboundAttachment) updates) => super.copyWith((message) => updates(message as InboundAttachment)) as InboundAttachment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InboundAttachment create() => InboundAttachment._();
  InboundAttachment createEmptyInstance() => create();
  static $pb.PbList<InboundAttachment> createRepeated() => $pb.PbList<InboundAttachment>();
  @$core.pragma('dart2js:noInline')
  static InboundAttachment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InboundAttachment>(create);
  static InboundAttachment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get senderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set senderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSenderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSenderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get ts => $_getI64(2);
  @$pb.TagNumber(3)
  set ts($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTs() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get attachmentId => $_getIZ(3);
  @$pb.TagNumber(4)
  set attachmentId($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAttachmentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAttachmentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isThumbnail => $_getBF(4);
  @$pb.TagNumber(5)
  set isThumbnail($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsThumbnail() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsThumbnail() => $_clearField(5);
}

/// An audio waveform
class AudioWaveform extends $pb.GeneratedMessage {
  factory AudioWaveform({
    $core.Iterable<$core.int>? bars,
  }) {
    final $result = create();
    if (bars != null) {
      $result.bars.addAll(bars);
    }
    return $result;
  }
  AudioWaveform._() : super();
  factory AudioWaveform.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AudioWaveform.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AudioWaveform', package: const $pb.PackageName(_omitMessageNames ? '' : 'model'), createEmptyInstance: create)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'bars', $pb.PbFieldType.K3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AudioWaveform clone() => AudioWaveform()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AudioWaveform copyWith(void Function(AudioWaveform) updates) => super.copyWith((message) => updates(message as AudioWaveform)) as AudioWaveform;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AudioWaveform create() => AudioWaveform._();
  AudioWaveform createEmptyInstance() => create();
  static $pb.PbList<AudioWaveform> createRepeated() => $pb.PbList<AudioWaveform>();
  @$core.pragma('dart2js:noInline')
  static AudioWaveform getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AudioWaveform>(create);
  static AudioWaveform? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get bars => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
