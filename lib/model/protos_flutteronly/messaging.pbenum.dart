///
//  Generated code. Do not modify.
//  source: protos_flutteronly/messaging.proto
//
// @dart = 2.7
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class ShortMessageRecord_Direction extends $pb.ProtobufEnum {
  static const ShortMessageRecord_Direction OUT = ShortMessageRecord_Direction._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'OUT');
  static const ShortMessageRecord_Direction IN = ShortMessageRecord_Direction._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'IN');

  static const $core.List<ShortMessageRecord_Direction> values = <ShortMessageRecord_Direction> [
    OUT,
    IN,
  ];

  static final $core.Map<$core.int, ShortMessageRecord_Direction> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ShortMessageRecord_Direction valueOf($core.int value) => _byValue[value];

  const ShortMessageRecord_Direction._($core.int v, $core.String n) : super(v, n);
}

class ShortMessageRecord_DeliveryStatus extends $pb.ProtobufEnum {
  static const ShortMessageRecord_DeliveryStatus UNSENT = ShortMessageRecord_DeliveryStatus._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'UNSENT');
  static const ShortMessageRecord_DeliveryStatus FAILING = ShortMessageRecord_DeliveryStatus._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'FAILING');
  static const ShortMessageRecord_DeliveryStatus PARTIALLY_FAILED = ShortMessageRecord_DeliveryStatus._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'PARTIALLY_FAILED');
  static const ShortMessageRecord_DeliveryStatus COMPLETELY_FAILED = ShortMessageRecord_DeliveryStatus._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'COMPLETELY_FAILED');
  static const ShortMessageRecord_DeliveryStatus SENT = ShortMessageRecord_DeliveryStatus._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SENT');

  static const $core.List<ShortMessageRecord_DeliveryStatus> values = <ShortMessageRecord_DeliveryStatus> [
    UNSENT,
    FAILING,
    PARTIALLY_FAILED,
    COMPLETELY_FAILED,
    SENT,
  ];

  static final $core.Map<$core.int, ShortMessageRecord_DeliveryStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ShortMessageRecord_DeliveryStatus valueOf($core.int value) => _byValue[value];

  const ShortMessageRecord_DeliveryStatus._($core.int v, $core.String n) : super(v, n);
}

