///
//  Generated code. Do not modify.
//  source: protos_flutteronly/messaging.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class Contact_Type extends $pb.ProtobufEnum {
  static const Contact_Type DIRECT = Contact_Type._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'DIRECT');
  static const Contact_Type GROUP = Contact_Type._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'GROUP');

  static const $core.List<Contact_Type> values = <Contact_Type> [
    DIRECT,
    GROUP,
  ];

  static final $core.Map<$core.int, Contact_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Contact_Type? valueOf($core.int value) => _byValue[value];

  const Contact_Type._($core.int v, $core.String n) : super(v, n);
}

class ShortMessageRecord_Direction extends $pb.ProtobufEnum {
  static const ShortMessageRecord_Direction OUT = ShortMessageRecord_Direction._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'OUT');
  static const ShortMessageRecord_Direction IN = ShortMessageRecord_Direction._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'IN');

  static const $core.List<ShortMessageRecord_Direction> values = <ShortMessageRecord_Direction> [
    OUT,
    IN,
  ];

  static final $core.Map<$core.int, ShortMessageRecord_Direction> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ShortMessageRecord_Direction? valueOf($core.int value) => _byValue[value];

  const ShortMessageRecord_Direction._($core.int v, $core.String n) : super(v, n);
}

class ShortMessageRecord_DeliveryStatus extends $pb.ProtobufEnum {
  static const ShortMessageRecord_DeliveryStatus SENDING = ShortMessageRecord_DeliveryStatus._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SENDING');
  static const ShortMessageRecord_DeliveryStatus PARTIALLY_SENT = ShortMessageRecord_DeliveryStatus._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'PARTIALLY_SENT');
  static const ShortMessageRecord_DeliveryStatus COMPLETELY_SENT = ShortMessageRecord_DeliveryStatus._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'COMPLETELY_SENT');

  static const $core.List<ShortMessageRecord_DeliveryStatus> values = <ShortMessageRecord_DeliveryStatus> [
    SENDING,
    PARTIALLY_SENT,
    COMPLETELY_SENT,
  ];

  static final $core.Map<$core.int, ShortMessageRecord_DeliveryStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ShortMessageRecord_DeliveryStatus? valueOf($core.int value) => _byValue[value];

  const ShortMessageRecord_DeliveryStatus._($core.int v, $core.String n) : super(v, n);
}

class OutgoingShortMessage_SubDeliveryStatus extends $pb.ProtobufEnum {
  static const OutgoingShortMessage_SubDeliveryStatus SENDING = OutgoingShortMessage_SubDeliveryStatus._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SENDING');
  static const OutgoingShortMessage_SubDeliveryStatus SENT = OutgoingShortMessage_SubDeliveryStatus._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SENT');

  static const $core.List<OutgoingShortMessage_SubDeliveryStatus> values = <OutgoingShortMessage_SubDeliveryStatus> [
    SENDING,
    SENT,
  ];

  static final $core.Map<$core.int, OutgoingShortMessage_SubDeliveryStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static OutgoingShortMessage_SubDeliveryStatus? valueOf($core.int value) => _byValue[value];

  const OutgoingShortMessage_SubDeliveryStatus._($core.int v, $core.String n) : super(v, n);
}

