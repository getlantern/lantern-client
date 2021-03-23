///
//  Generated code. Do not modify.
//  source: protos_flutteronly/messaging.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'messaging.pbenum.dart';

export 'messaging.pbenum.dart';

class Contact extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Contact', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..e<Contact_Type>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: Contact_Type.DIRECT, valueOf: Contact_Type.valueOf, enumValues: Contact_Type.values)
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'displayName', protoName: 'displayName')
    ..aInt64(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'createdTime', protoName: 'createdTime')
    ..aInt64(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mostRecentMessageTime', protoName: 'mostRecentMessageTime')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mostRecentMessageText', protoName: 'mostRecentMessageText')
    ..pPS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'memberIds', protoName: 'memberIds')
    ..hasRequiredFields = false
  ;

  Contact._() : super();
  factory Contact({
    Contact_Type? type,
    $core.String? id,
    $core.String? displayName,
    $fixnum.Int64? createdTime,
    $fixnum.Int64? mostRecentMessageTime,
    $core.String? mostRecentMessageText,
    $core.Iterable<$core.String>? memberIds,
  }) {
    final _result = create();
    if (type != null) {
      _result.type = type;
    }
    if (id != null) {
      _result.id = id;
    }
    if (displayName != null) {
      _result.displayName = displayName;
    }
    if (createdTime != null) {
      _result.createdTime = createdTime;
    }
    if (mostRecentMessageTime != null) {
      _result.mostRecentMessageTime = mostRecentMessageTime;
    }
    if (mostRecentMessageText != null) {
      _result.mostRecentMessageText = mostRecentMessageText;
    }
    if (memberIds != null) {
      _result.memberIds.addAll(memberIds);
    }
    return _result;
  }
  factory Contact.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Contact.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Contact clone() => Contact()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Contact copyWith(void Function(Contact) updates) => super.copyWith((message) => updates(message as Contact)) as Contact; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Contact create() => Contact._();
  Contact createEmptyInstance() => create();
  static $pb.PbList<Contact> createRepeated() => $pb.PbList<Contact>();
  @$core.pragma('dart2js:noInline')
  static Contact getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Contact>(create);
  static Contact? _defaultInstance;

  @$pb.TagNumber(2)
  Contact_Type get type => $_getN(0);
  @$pb.TagNumber(2)
  set type(Contact_Type v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(3)
  set id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(4)
  set displayName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(4)
  void clearDisplayName() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createdTime => $_getI64(3);
  @$pb.TagNumber(5)
  set createdTime($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreatedTime() => $_has(3);
  @$pb.TagNumber(5)
  void clearCreatedTime() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get mostRecentMessageTime => $_getI64(4);
  @$pb.TagNumber(6)
  set mostRecentMessageTime($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasMostRecentMessageTime() => $_has(4);
  @$pb.TagNumber(6)
  void clearMostRecentMessageTime() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get mostRecentMessageText => $_getSZ(5);
  @$pb.TagNumber(7)
  set mostRecentMessageText($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasMostRecentMessageText() => $_has(5);
  @$pb.TagNumber(7)
  void clearMostRecentMessageText() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.String> get memberIds => $_getList(6);
}

enum ShortMessage_Body {
  text, 
  oggVoice, 
  notSet
}

class ShortMessage extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, ShortMessage_Body> _ShortMessage_BodyByTag = {
    3 : ShortMessage_Body.text,
    4 : ShortMessage_Body.oggVoice,
    0 : ShortMessage_Body.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ShortMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..oo(0, [3, 4])
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id', $pb.PbFieldType.OY)
    ..aInt64(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sent')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'text')
    ..a<$core.List<$core.int>>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'oggVoice', $pb.PbFieldType.OY, protoName: 'oggVoice')
    ..hasRequiredFields = false
  ;

  ShortMessage._() : super();
  factory ShortMessage({
    $core.List<$core.int>? id,
    $fixnum.Int64? sent,
    $core.String? text,
    $core.List<$core.int>? oggVoice,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (sent != null) {
      _result.sent = sent;
    }
    if (text != null) {
      _result.text = text;
    }
    if (oggVoice != null) {
      _result.oggVoice = oggVoice;
    }
    return _result;
  }
  factory ShortMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShortMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShortMessage clone() => ShortMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShortMessage copyWith(void Function(ShortMessage) updates) => super.copyWith((message) => updates(message as ShortMessage)) as ShortMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ShortMessage create() => ShortMessage._();
  ShortMessage createEmptyInstance() => create();
  static $pb.PbList<ShortMessage> createRepeated() => $pb.PbList<ShortMessage>();
  @$core.pragma('dart2js:noInline')
  static ShortMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShortMessage>(create);
  static ShortMessage? _defaultInstance;

  ShortMessage_Body whichBody() => _ShortMessage_BodyByTag[$_whichOneof(0)]!;
  void clearBody() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.List<$core.int> get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sent => $_getI64(1);
  @$pb.TagNumber(2)
  set sent($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSent() => $_has(1);
  @$pb.TagNumber(2)
  void clearSent() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get text => $_getSZ(2);
  @$pb.TagNumber(3)
  set text($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasText() => $_has(2);
  @$pb.TagNumber(3)
  void clearText() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get oggVoice => $_getN(3);
  @$pb.TagNumber(4)
  set oggVoice($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOggVoice() => $_has(3);
  @$pb.TagNumber(4)
  void clearOggVoice() => clearField(4);
}

class ShortMessageRecord extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ShortMessageRecord', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'senderId', protoName: 'senderId')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sent')
    ..e<ShortMessageRecord_Direction>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'direction', $pb.PbFieldType.OE, defaultOrMaker: ShortMessageRecord_Direction.OUT, valueOf: ShortMessageRecord_Direction.valueOf, enumValues: ShortMessageRecord_Direction.values)
    ..e<ShortMessageRecord_DeliveryStatus>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ShortMessageRecord_DeliveryStatus.UNSENT, valueOf: ShortMessageRecord_DeliveryStatus.valueOf, enumValues: ShortMessageRecord_DeliveryStatus.values)
    ..a<$core.List<$core.int>>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  ShortMessageRecord._() : super();
  factory ShortMessageRecord({
    $core.String? senderId,
    $core.String? id,
    $fixnum.Int64? sent,
    ShortMessageRecord_Direction? direction,
    ShortMessageRecord_DeliveryStatus? status,
    $core.List<$core.int>? message,
  }) {
    final _result = create();
    if (senderId != null) {
      _result.senderId = senderId;
    }
    if (id != null) {
      _result.id = id;
    }
    if (sent != null) {
      _result.sent = sent;
    }
    if (direction != null) {
      _result.direction = direction;
    }
    if (status != null) {
      _result.status = status;
    }
    if (message != null) {
      _result.message = message;
    }
    return _result;
  }
  factory ShortMessageRecord.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ShortMessageRecord.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ShortMessageRecord clone() => ShortMessageRecord()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ShortMessageRecord copyWith(void Function(ShortMessageRecord) updates) => super.copyWith((message) => updates(message as ShortMessageRecord)) as ShortMessageRecord; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ShortMessageRecord create() => ShortMessageRecord._();
  ShortMessageRecord createEmptyInstance() => create();
  static $pb.PbList<ShortMessageRecord> createRepeated() => $pb.PbList<ShortMessageRecord>();
  @$core.pragma('dart2js:noInline')
  static ShortMessageRecord getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShortMessageRecord>(create);
  static ShortMessageRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get senderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set senderId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSenderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSenderId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sent => $_getI64(2);
  @$pb.TagNumber(3)
  set sent($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSent() => $_has(2);
  @$pb.TagNumber(3)
  void clearSent() => clearField(3);

  @$pb.TagNumber(4)
  ShortMessageRecord_Direction get direction => $_getN(3);
  @$pb.TagNumber(4)
  set direction(ShortMessageRecord_Direction v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDirection() => $_has(3);
  @$pb.TagNumber(4)
  void clearDirection() => clearField(4);

  @$pb.TagNumber(5)
  ShortMessageRecord_DeliveryStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(ShortMessageRecord_DeliveryStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get message => $_getN(5);
  @$pb.TagNumber(6)
  set message($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => clearField(6);
}

enum OutgoingShortMessage_Recipient {
  identityKey, 
  groupId, 
  notSet
}

class OutgoingShortMessage extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, OutgoingShortMessage_Recipient> _OutgoingShortMessage_RecipientByTag = {
    1 : OutgoingShortMessage_Recipient.identityKey,
    2 : OutgoingShortMessage_Recipient.groupId,
    0 : OutgoingShortMessage_Recipient.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'OutgoingShortMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'identityKey', protoName: 'identityKey')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'groupId', protoName: 'groupId')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'remainingRecipients', protoName: 'remainingRecipients')
    ..aOM<ShortMessage>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message', subBuilder: ShortMessage.create)
    ..aInt64(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'lastFailed', protoName: 'lastFailed')
    ..hasRequiredFields = false
  ;

  OutgoingShortMessage._() : super();
  factory OutgoingShortMessage({
    $core.String? identityKey,
    $core.String? groupId,
    $core.Iterable<$core.String>? remainingRecipients,
    ShortMessage? message,
    $fixnum.Int64? lastFailed,
  }) {
    final _result = create();
    if (identityKey != null) {
      _result.identityKey = identityKey;
    }
    if (groupId != null) {
      _result.groupId = groupId;
    }
    if (remainingRecipients != null) {
      _result.remainingRecipients.addAll(remainingRecipients);
    }
    if (message != null) {
      _result.message = message;
    }
    if (lastFailed != null) {
      _result.lastFailed = lastFailed;
    }
    return _result;
  }
  factory OutgoingShortMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OutgoingShortMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OutgoingShortMessage clone() => OutgoingShortMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OutgoingShortMessage copyWith(void Function(OutgoingShortMessage) updates) => super.copyWith((message) => updates(message as OutgoingShortMessage)) as OutgoingShortMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static OutgoingShortMessage create() => OutgoingShortMessage._();
  OutgoingShortMessage createEmptyInstance() => create();
  static $pb.PbList<OutgoingShortMessage> createRepeated() => $pb.PbList<OutgoingShortMessage>();
  @$core.pragma('dart2js:noInline')
  static OutgoingShortMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OutgoingShortMessage>(create);
  static OutgoingShortMessage? _defaultInstance;

  OutgoingShortMessage_Recipient whichRecipient() => _OutgoingShortMessage_RecipientByTag[$_whichOneof(0)]!;
  void clearRecipient() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get identityKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set identityKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIdentityKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentityKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get remainingRecipients => $_getList(2);

  @$pb.TagNumber(4)
  ShortMessage get message => $_getN(3);
  @$pb.TagNumber(4)
  set message(ShortMessage v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => clearField(4);
  @$pb.TagNumber(4)
  ShortMessage ensureMessage() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get lastFailed => $_getI64(4);
  @$pb.TagNumber(5)
  set lastFailed($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLastFailed() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastFailed() => clearField(5);
}

enum TransferMessage_Content {
  shortMessage, 
  notSet
}

class TransferMessage extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TransferMessage_Content> _TransferMessage_ContentByTag = {
    1 : TransferMessage_Content.shortMessage,
    0 : TransferMessage_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TransferMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..oo(0, [1])
    ..aOM<ShortMessage>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'shortMessage', protoName: 'shortMessage', subBuilder: ShortMessage.create)
    ..hasRequiredFields = false
  ;

  TransferMessage._() : super();
  factory TransferMessage({
    ShortMessage? shortMessage,
  }) {
    final _result = create();
    if (shortMessage != null) {
      _result.shortMessage = shortMessage;
    }
    return _result;
  }
  factory TransferMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferMessage clone() => TransferMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferMessage copyWith(void Function(TransferMessage) updates) => super.copyWith((message) => updates(message as TransferMessage)) as TransferMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TransferMessage create() => TransferMessage._();
  TransferMessage createEmptyInstance() => create();
  static $pb.PbList<TransferMessage> createRepeated() => $pb.PbList<TransferMessage>();
  @$core.pragma('dart2js:noInline')
  static TransferMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferMessage>(create);
  static TransferMessage? _defaultInstance;

  TransferMessage_Content whichContent() => _TransferMessage_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ShortMessage get shortMessage => $_getN(0);
  @$pb.TagNumber(1)
  set shortMessage(ShortMessage v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasShortMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearShortMessage() => clearField(1);
  @$pb.TagNumber(1)
  ShortMessage ensureShortMessage() => $_ensure(0);
}

