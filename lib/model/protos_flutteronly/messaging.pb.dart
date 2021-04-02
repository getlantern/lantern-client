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
    ..pPS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'memberIds', protoName: 'memberIds')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'displayName', protoName: 'displayName')
    ..aInt64(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'createdTime', protoName: 'createdTime')
    ..aInt64(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mostRecentMessageTs', protoName: 'mostRecentMessageTs')
    ..e<MessageDirection>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mostRecentMessageDirection', $pb.PbFieldType.OE, protoName: 'mostRecentMessageDirection', defaultOrMaker: MessageDirection.OUT, valueOf: MessageDirection.valueOf, enumValues: MessageDirection.values)
    ..aOS(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mostRecentMessageText', protoName: 'mostRecentMessageText')
    ..hasRequiredFields = false
  ;

  Contact._() : super();
  factory Contact({
    Contact_Type? type,
    $core.String? id,
    $core.Iterable<$core.String>? memberIds,
    $core.String? displayName,
    $fixnum.Int64? createdTime,
    $fixnum.Int64? mostRecentMessageTs,
    MessageDirection? mostRecentMessageDirection,
    $core.String? mostRecentMessageText,
  }) {
    final _result = create();
    if (type != null) {
      _result.type = type;
    }
    if (id != null) {
      _result.id = id;
    }
    if (memberIds != null) {
      _result.memberIds.addAll(memberIds);
    }
    if (displayName != null) {
      _result.displayName = displayName;
    }
    if (createdTime != null) {
      _result.createdTime = createdTime;
    }
    if (mostRecentMessageTs != null) {
      _result.mostRecentMessageTs = mostRecentMessageTs;
    }
    if (mostRecentMessageDirection != null) {
      _result.mostRecentMessageDirection = mostRecentMessageDirection;
    }
    if (mostRecentMessageText != null) {
      _result.mostRecentMessageText = mostRecentMessageText;
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
  $core.List<$core.String> get memberIds => $_getList(2);

  @$pb.TagNumber(5)
  $core.String get displayName => $_getSZ(3);
  @$pb.TagNumber(5)
  set displayName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasDisplayName() => $_has(3);
  @$pb.TagNumber(5)
  void clearDisplayName() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get createdTime => $_getI64(4);
  @$pb.TagNumber(6)
  set createdTime($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreatedTime() => $_has(4);
  @$pb.TagNumber(6)
  void clearCreatedTime() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get mostRecentMessageTs => $_getI64(5);
  @$pb.TagNumber(7)
  set mostRecentMessageTs($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasMostRecentMessageTs() => $_has(5);
  @$pb.TagNumber(7)
  void clearMostRecentMessageTs() => clearField(7);

  @$pb.TagNumber(8)
  MessageDirection get mostRecentMessageDirection => $_getN(6);
  @$pb.TagNumber(8)
  set mostRecentMessageDirection(MessageDirection v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasMostRecentMessageDirection() => $_has(6);
  @$pb.TagNumber(8)
  void clearMostRecentMessageDirection() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get mostRecentMessageText => $_getSZ(7);
  @$pb.TagNumber(9)
  set mostRecentMessageText($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(9)
  $core.bool hasMostRecentMessageText() => $_has(7);
  @$pb.TagNumber(9)
  void clearMostRecentMessageText() => clearField(9);
}

class Attachment extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Attachment', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mimeType', protoName: 'mimeType')
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'keyMaterial', $pb.PbFieldType.OY, protoName: 'keyMaterial')
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'digest', $pb.PbFieldType.OY)
    ..aInt64(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'plaintextLength', protoName: 'plaintextLength')
    ..m<$core.String, $core.String>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'metadata', entryClassName: 'Attachment.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('model'))
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'downloadUrl', protoName: 'downloadUrl')
    ..hasRequiredFields = false
  ;

  Attachment._() : super();
  factory Attachment({
    $core.String? mimeType,
    $core.List<$core.int>? keyMaterial,
    $core.List<$core.int>? digest,
    $fixnum.Int64? plaintextLength,
    $core.Map<$core.String, $core.String>? metadata,
    $core.String? downloadUrl,
  }) {
    final _result = create();
    if (mimeType != null) {
      _result.mimeType = mimeType;
    }
    if (keyMaterial != null) {
      _result.keyMaterial = keyMaterial;
    }
    if (digest != null) {
      _result.digest = digest;
    }
    if (plaintextLength != null) {
      _result.plaintextLength = plaintextLength;
    }
    if (metadata != null) {
      _result.metadata.addAll(metadata);
    }
    if (downloadUrl != null) {
      _result.downloadUrl = downloadUrl;
    }
    return _result;
  }
  factory Attachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Attachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Attachment clone() => Attachment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Attachment copyWith(void Function(Attachment) updates) => super.copyWith((message) => updates(message as Attachment)) as Attachment; // ignore: deprecated_member_use
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
  void clearMimeType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get keyMaterial => $_getN(1);
  @$pb.TagNumber(2)
  set keyMaterial($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasKeyMaterial() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeyMaterial() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get digest => $_getN(2);
  @$pb.TagNumber(3)
  set digest($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDigest() => $_has(2);
  @$pb.TagNumber(3)
  void clearDigest() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get plaintextLength => $_getI64(3);
  @$pb.TagNumber(4)
  set plaintextLength($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPlaintextLength() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlaintextLength() => clearField(4);

  @$pb.TagNumber(5)
  $core.Map<$core.String, $core.String> get metadata => $_getMap(4);

  @$pb.TagNumber(6)
  $core.String get downloadUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set downloadUrl($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDownloadUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearDownloadUrl() => clearField(6);
}

class StoredAttachment extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'StoredAttachment', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'guid')
    ..aOM<Attachment>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'attachment', subBuilder: Attachment.create)
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'filePath', protoName: 'filePath')
    ..e<StoredAttachment_Status>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: StoredAttachment_Status.PENDING, valueOf: StoredAttachment_Status.valueOf, enumValues: StoredAttachment_Status.values)
    ..hasRequiredFields = false
  ;

  StoredAttachment._() : super();
  factory StoredAttachment({
    $core.String? guid,
    Attachment? attachment,
    $core.String? filePath,
    StoredAttachment_Status? status,
  }) {
    final _result = create();
    if (guid != null) {
      _result.guid = guid;
    }
    if (attachment != null) {
      _result.attachment = attachment;
    }
    if (filePath != null) {
      _result.filePath = filePath;
    }
    if (status != null) {
      _result.status = status;
    }
    return _result;
  }
  factory StoredAttachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoredAttachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoredAttachment clone() => StoredAttachment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoredAttachment copyWith(void Function(StoredAttachment) updates) => super.copyWith((message) => updates(message as StoredAttachment)) as StoredAttachment; // ignore: deprecated_member_use
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
  void clearGuid() => clearField(1);

  @$pb.TagNumber(2)
  Attachment get attachment => $_getN(1);
  @$pb.TagNumber(2)
  set attachment(Attachment v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAttachment() => $_has(1);
  @$pb.TagNumber(2)
  void clearAttachment() => clearField(2);
  @$pb.TagNumber(2)
  Attachment ensureAttachment() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get filePath => $_getSZ(2);
  @$pb.TagNumber(3)
  set filePath($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFilePath() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilePath() => clearField(3);

  @$pb.TagNumber(4)
  StoredAttachment_Status get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(StoredAttachment_Status v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);
}

class Message extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Message', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'replyToSenderId', $pb.PbFieldType.OY, protoName: 'replyToSenderId')
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'replyToId', $pb.PbFieldType.OY, protoName: 'replyToId')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'text')
    ..m<$core.int, Attachment>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'attachments', entryClassName: 'Message.AttachmentsEntry', keyFieldType: $pb.PbFieldType.O3, valueFieldType: $pb.PbFieldType.OM, valueCreator: Attachment.create, packageName: const $pb.PackageName('model'))
    ..hasRequiredFields = false
  ;

  Message._() : super();
  factory Message({
    $core.List<$core.int>? id,
    $core.List<$core.int>? replyToSenderId,
    $core.List<$core.int>? replyToId,
    $core.String? text,
    $core.Map<$core.int, Attachment>? attachments,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (replyToSenderId != null) {
      _result.replyToSenderId = replyToSenderId;
    }
    if (replyToId != null) {
      _result.replyToId = replyToId;
    }
    if (text != null) {
      _result.text = text;
    }
    if (attachments != null) {
      _result.attachments.addAll(attachments);
    }
    return _result;
  }
  factory Message.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message clone() => Message()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message copyWith(void Function(Message) updates) => super.copyWith((message) => updates(message as Message)) as Message; // ignore: deprecated_member_use
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
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get replyToSenderId => $_getN(1);
  @$pb.TagNumber(2)
  set replyToSenderId($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReplyToSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReplyToSenderId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get replyToId => $_getN(2);
  @$pb.TagNumber(3)
  set replyToId($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReplyToId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReplyToId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get text => $_getSZ(3);
  @$pb.TagNumber(4)
  set text($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => clearField(4);

  @$pb.TagNumber(5)
  $core.Map<$core.int, Attachment> get attachments => $_getMap(4);
}

class StoredMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'StoredMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'senderId', protoName: 'senderId')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ts')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'replyToSenderId', protoName: 'replyToSenderId')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'replyToId', protoName: 'replyToId')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'text')
    ..m<$core.int, StoredAttachment>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'attachments', entryClassName: 'StoredMessage.AttachmentsEntry', keyFieldType: $pb.PbFieldType.O3, valueFieldType: $pb.PbFieldType.OM, valueCreator: StoredAttachment.create, packageName: const $pb.PackageName('model'))
    ..e<MessageDirection>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'direction', $pb.PbFieldType.OE, defaultOrMaker: MessageDirection.OUT, valueOf: MessageDirection.valueOf, enumValues: MessageDirection.values)
    ..e<StoredMessage_DeliveryStatus>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: StoredMessage_DeliveryStatus.SENDING, valueOf: StoredMessage_DeliveryStatus.valueOf, enumValues: StoredMessage_DeliveryStatus.values)
    ..hasRequiredFields = false
  ;

  StoredMessage._() : super();
  factory StoredMessage({
    $core.String? senderId,
    $core.String? id,
    $fixnum.Int64? ts,
    $core.String? replyToSenderId,
    $core.String? replyToId,
    $core.String? text,
    $core.Map<$core.int, StoredAttachment>? attachments,
    MessageDirection? direction,
    StoredMessage_DeliveryStatus? status,
  }) {
    final _result = create();
    if (senderId != null) {
      _result.senderId = senderId;
    }
    if (id != null) {
      _result.id = id;
    }
    if (ts != null) {
      _result.ts = ts;
    }
    if (replyToSenderId != null) {
      _result.replyToSenderId = replyToSenderId;
    }
    if (replyToId != null) {
      _result.replyToId = replyToId;
    }
    if (text != null) {
      _result.text = text;
    }
    if (attachments != null) {
      _result.attachments.addAll(attachments);
    }
    if (direction != null) {
      _result.direction = direction;
    }
    if (status != null) {
      _result.status = status;
    }
    return _result;
  }
  factory StoredMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoredMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoredMessage clone() => StoredMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoredMessage copyWith(void Function(StoredMessage) updates) => super.copyWith((message) => updates(message as StoredMessage)) as StoredMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static StoredMessage create() => StoredMessage._();
  StoredMessage createEmptyInstance() => create();
  static $pb.PbList<StoredMessage> createRepeated() => $pb.PbList<StoredMessage>();
  @$core.pragma('dart2js:noInline')
  static StoredMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoredMessage>(create);
  static StoredMessage? _defaultInstance;

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
  $fixnum.Int64 get ts => $_getI64(2);
  @$pb.TagNumber(3)
  set ts($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTs() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get replyToSenderId => $_getSZ(3);
  @$pb.TagNumber(4)
  set replyToSenderId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReplyToSenderId() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplyToSenderId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get replyToId => $_getSZ(4);
  @$pb.TagNumber(5)
  set replyToId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReplyToId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReplyToId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get text => $_getSZ(5);
  @$pb.TagNumber(6)
  set text($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasText() => $_has(5);
  @$pb.TagNumber(6)
  void clearText() => clearField(6);

  @$pb.TagNumber(7)
  $core.Map<$core.int, StoredAttachment> get attachments => $_getMap(6);

  @$pb.TagNumber(8)
  MessageDirection get direction => $_getN(7);
  @$pb.TagNumber(8)
  set direction(MessageDirection v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasDirection() => $_has(7);
  @$pb.TagNumber(8)
  void clearDirection() => clearField(8);

  @$pb.TagNumber(9)
  StoredMessage_DeliveryStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(StoredMessage_DeliveryStatus v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => clearField(9);
}

class OutboundMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'OutboundMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'senderId', protoName: 'senderId')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sent')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recipientId', protoName: 'recipientId')
    ..m<$core.String, OutboundMessage_SubDeliveryStatus>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'subDeliveryStatuses', protoName: 'subDeliveryStatuses', entryClassName: 'OutboundMessage.SubDeliveryStatusesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OE, valueOf: OutboundMessage_SubDeliveryStatus.valueOf, enumValues: OutboundMessage_SubDeliveryStatus.values, packageName: const $pb.PackageName('model'))
    ..hasRequiredFields = false
  ;

  OutboundMessage._() : super();
  factory OutboundMessage({
    $core.String? senderId,
    $core.String? id,
    $fixnum.Int64? sent,
    $core.String? recipientId,
    $core.Map<$core.String, OutboundMessage_SubDeliveryStatus>? subDeliveryStatuses,
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
    if (recipientId != null) {
      _result.recipientId = recipientId;
    }
    if (subDeliveryStatuses != null) {
      _result.subDeliveryStatuses.addAll(subDeliveryStatuses);
    }
    return _result;
  }
  factory OutboundMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OutboundMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OutboundMessage clone() => OutboundMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OutboundMessage copyWith(void Function(OutboundMessage) updates) => super.copyWith((message) => updates(message as OutboundMessage)) as OutboundMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static OutboundMessage create() => OutboundMessage._();
  OutboundMessage createEmptyInstance() => create();
  static $pb.PbList<OutboundMessage> createRepeated() => $pb.PbList<OutboundMessage>();
  @$core.pragma('dart2js:noInline')
  static OutboundMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OutboundMessage>(create);
  static OutboundMessage? _defaultInstance;

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
  $core.String get recipientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set recipientId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRecipientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRecipientId() => clearField(4);

  @$pb.TagNumber(5)
  $core.Map<$core.String, OutboundMessage_SubDeliveryStatus> get subDeliveryStatuses => $_getMap(4);
}

class InboundAttachment extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'InboundAttachment', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'senderId', protoName: 'senderId')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'messageId', protoName: 'messageId')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ts')
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'attachmentId', $pb.PbFieldType.O3, protoName: 'attachmentId')
    ..hasRequiredFields = false
  ;

  InboundAttachment._() : super();
  factory InboundAttachment({
    $core.String? senderId,
    $core.String? messageId,
    $fixnum.Int64? ts,
    $core.int? attachmentId,
  }) {
    final _result = create();
    if (senderId != null) {
      _result.senderId = senderId;
    }
    if (messageId != null) {
      _result.messageId = messageId;
    }
    if (ts != null) {
      _result.ts = ts;
    }
    if (attachmentId != null) {
      _result.attachmentId = attachmentId;
    }
    return _result;
  }
  factory InboundAttachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InboundAttachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InboundAttachment clone() => InboundAttachment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InboundAttachment copyWith(void Function(InboundAttachment) updates) => super.copyWith((message) => updates(message as InboundAttachment)) as InboundAttachment; // ignore: deprecated_member_use
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
  void clearSenderId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get ts => $_getI64(2);
  @$pb.TagNumber(3)
  set ts($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTs() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get attachmentId => $_getIZ(3);
  @$pb.TagNumber(4)
  set attachmentId($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAttachmentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAttachmentId() => clearField(4);
}

enum TransferMessage_Content {
  message, 
  notSet
}

class TransferMessage extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TransferMessage_Content> _TransferMessage_ContentByTag = {
    1 : TransferMessage_Content.message,
    0 : TransferMessage_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TransferMessage', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'model'), createEmptyInstance: create)
    ..oo(0, [1])
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'Message', $pb.PbFieldType.OY, protoName: 'Message')
    ..hasRequiredFields = false
  ;

  TransferMessage._() : super();
  factory TransferMessage({
    $core.List<$core.int>? message,
  }) {
    final _result = create();
    if (message != null) {
      _result.message = message;
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
  $core.List<$core.int> get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
}

