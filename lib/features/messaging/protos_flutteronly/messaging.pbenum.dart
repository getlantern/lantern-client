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

import 'package:protobuf/protobuf.dart' as $pb;

class MessageDirection extends $pb.ProtobufEnum {
  static const MessageDirection OUT = MessageDirection._(0, _omitEnumNames ? '' : 'OUT');
  static const MessageDirection IN = MessageDirection._(1, _omitEnumNames ? '' : 'IN');

  static const $core.List<MessageDirection> values = <MessageDirection> [
    OUT,
    IN,
  ];

  static final $core.Map<$core.int, MessageDirection> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageDirection? valueOf($core.int value) => _byValue[value];

  const MessageDirection._(super.v, super.n);
}

class ContactType extends $pb.ProtobufEnum {
  static const ContactType DIRECT = ContactType._(0, _omitEnumNames ? '' : 'DIRECT');
  static const ContactType GROUP = ContactType._(1, _omitEnumNames ? '' : 'GROUP');

  static const $core.List<ContactType> values = <ContactType> [
    DIRECT,
    GROUP,
  ];

  static final $core.Map<$core.int, ContactType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ContactType? valueOf($core.int value) => _byValue[value];

  const ContactType._(super.v, super.n);
}

class ContactSource extends $pb.ProtobufEnum {
  static const ContactSource UNKNOWN = ContactSource._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const ContactSource INTRODUCTION = ContactSource._(1, _omitEnumNames ? '' : 'INTRODUCTION');
  static const ContactSource APP1 = ContactSource._(2, _omitEnumNames ? '' : 'APP1');
  static const ContactSource APP2 = ContactSource._(3, _omitEnumNames ? '' : 'APP2');
  static const ContactSource APP3 = ContactSource._(4, _omitEnumNames ? '' : 'APP3');
  static const ContactSource APP4 = ContactSource._(5, _omitEnumNames ? '' : 'APP4');
  static const ContactSource APP5 = ContactSource._(6, _omitEnumNames ? '' : 'APP5');
  static const ContactSource UNSOLICITED = ContactSource._(7, _omitEnumNames ? '' : 'UNSOLICITED');

  static const $core.List<ContactSource> values = <ContactSource> [
    UNKNOWN,
    INTRODUCTION,
    APP1,
    APP2,
    APP3,
    APP4,
    APP5,
    UNSOLICITED,
  ];

  static final $core.Map<$core.int, ContactSource> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ContactSource? valueOf($core.int value) => _byValue[value];

  const ContactSource._(super.v, super.n);
}

/// How well do we know a contact. Lower numbers equate to a lower verification level.
class VerificationLevel extends $pb.ProtobufEnum {
  static const VerificationLevel UNACCEPTED = VerificationLevel._(0, _omitEnumNames ? '' : 'UNACCEPTED');
  static const VerificationLevel UNVERIFIED = VerificationLevel._(1, _omitEnumNames ? '' : 'UNVERIFIED');
  static const VerificationLevel VERIFIED = VerificationLevel._(2, _omitEnumNames ? '' : 'VERIFIED');

  static const $core.List<VerificationLevel> values = <VerificationLevel> [
    UNACCEPTED,
    UNVERIFIED,
    VERIFIED,
  ];

  static final $core.Map<$core.int, VerificationLevel> _byValue = $pb.ProtobufEnum.initByValue(values);
  static VerificationLevel? valueOf($core.int value) => _byValue[value];

  const VerificationLevel._(super.v, super.n);
}

class StoredAttachment_Status extends $pb.ProtobufEnum {
  static const StoredAttachment_Status PENDING = StoredAttachment_Status._(0, _omitEnumNames ? '' : 'PENDING');
  static const StoredAttachment_Status PENDING_UPLOAD = StoredAttachment_Status._(1, _omitEnumNames ? '' : 'PENDING_UPLOAD');
  static const StoredAttachment_Status DONE = StoredAttachment_Status._(2, _omitEnumNames ? '' : 'DONE');
  static const StoredAttachment_Status FAILED = StoredAttachment_Status._(3, _omitEnumNames ? '' : 'FAILED');

  static const $core.List<StoredAttachment_Status> values = <StoredAttachment_Status> [
    PENDING,
    PENDING_UPLOAD,
    DONE,
    FAILED,
  ];

  static final $core.Map<$core.int, StoredAttachment_Status> _byValue = $pb.ProtobufEnum.initByValue(values);
  static StoredAttachment_Status? valueOf($core.int value) => _byValue[value];

  const StoredAttachment_Status._(super.v, super.n);
}

class IntroductionDetails_IntroductionStatus extends $pb.ProtobufEnum {
  static const IntroductionDetails_IntroductionStatus PENDING = IntroductionDetails_IntroductionStatus._(0, _omitEnumNames ? '' : 'PENDING');
  static const IntroductionDetails_IntroductionStatus ACCEPTED = IntroductionDetails_IntroductionStatus._(1, _omitEnumNames ? '' : 'ACCEPTED');

  static const $core.List<IntroductionDetails_IntroductionStatus> values = <IntroductionDetails_IntroductionStatus> [
    PENDING,
    ACCEPTED,
  ];

  static final $core.Map<$core.int, IntroductionDetails_IntroductionStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static IntroductionDetails_IntroductionStatus? valueOf($core.int value) => _byValue[value];

  const IntroductionDetails_IntroductionStatus._(super.v, super.n);
}

class StoredMessage_DeliveryStatus extends $pb.ProtobufEnum {
  static const StoredMessage_DeliveryStatus SENDING = StoredMessage_DeliveryStatus._(0, _omitEnumNames ? '' : 'SENDING');
  static const StoredMessage_DeliveryStatus PARTIALLY_SENT = StoredMessage_DeliveryStatus._(1, _omitEnumNames ? '' : 'PARTIALLY_SENT');
  static const StoredMessage_DeliveryStatus COMPLETELY_SENT = StoredMessage_DeliveryStatus._(2, _omitEnumNames ? '' : 'COMPLETELY_SENT');
  static const StoredMessage_DeliveryStatus PARTIALLY_FAILED = StoredMessage_DeliveryStatus._(3, _omitEnumNames ? '' : 'PARTIALLY_FAILED');
  static const StoredMessage_DeliveryStatus COMPLETELY_FAILED = StoredMessage_DeliveryStatus._(4, _omitEnumNames ? '' : 'COMPLETELY_FAILED');

  static const $core.List<StoredMessage_DeliveryStatus> values = <StoredMessage_DeliveryStatus> [
    SENDING,
    PARTIALLY_SENT,
    COMPLETELY_SENT,
    PARTIALLY_FAILED,
    COMPLETELY_FAILED,
  ];

  static final $core.Map<$core.int, StoredMessage_DeliveryStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static StoredMessage_DeliveryStatus? valueOf($core.int value) => _byValue[value];

  const StoredMessage_DeliveryStatus._(super.v, super.n);
}

class OutboundMessage_SubDeliveryStatus extends $pb.ProtobufEnum {
  static const OutboundMessage_SubDeliveryStatus SENDING = OutboundMessage_SubDeliveryStatus._(0, _omitEnumNames ? '' : 'SENDING');
  static const OutboundMessage_SubDeliveryStatus SENT = OutboundMessage_SubDeliveryStatus._(1, _omitEnumNames ? '' : 'SENT');

  static const $core.List<OutboundMessage_SubDeliveryStatus> values = <OutboundMessage_SubDeliveryStatus> [
    SENDING,
    SENT,
  ];

  static final $core.Map<$core.int, OutboundMessage_SubDeliveryStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static OutboundMessage_SubDeliveryStatus? valueOf($core.int value) => _byValue[value];

  const OutboundMessage_SubDeliveryStatus._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
