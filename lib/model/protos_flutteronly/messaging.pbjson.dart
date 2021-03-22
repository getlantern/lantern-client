///
//  Generated code. Do not modify.
//  source: protos_flutteronly/messaging.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use contactDescriptor instead')
const Contact$json = const {
  '1': 'Contact',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'displayName', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `Contact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactDescriptor = $convert.base64Decode('CgdDb250YWN0Eg4KAmlkGAEgASgJUgJpZBIgCgtkaXNwbGF5TmFtZRgCIAEoCVILZGlzcGxheU5hbWU=');
@$core.Deprecated('Use groupDescriptor instead')
const Group$json = const {
  '1': 'Group',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'memberIds', '3': 2, '4': 3, '5': 9, '10': 'memberIds'},
    const {'1': 'displayName', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `Group`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupDescriptor = $convert.base64Decode('CgVHcm91cBIOCgJpZBgBIAEoCVICaWQSHAoJbWVtYmVySWRzGAIgAygJUgltZW1iZXJJZHMSIAoLZGlzcGxheU5hbWUYAyABKAlSC2Rpc3BsYXlOYW1l');
@$core.Deprecated('Use conversationDescriptor instead')
const Conversation$json = const {
  '1': 'Conversation',
  '2': const [
    const {'1': 'contactId', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'contactId'},
    const {'1': 'groupId', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'groupId'},
    const {'1': 'mostRecentMessageTime', '3': 3, '4': 1, '5': 3, '10': 'mostRecentMessageTime'},
    const {'1': 'mostRecentMessageText', '3': 4, '4': 1, '5': 9, '10': 'mostRecentMessageText'},
  ],
  '8': const [
    const {'1': 'party'},
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode('CgxDb252ZXJzYXRpb24SHgoJY29udGFjdElkGAEgASgJSABSCWNvbnRhY3RJZBIaCgdncm91cElkGAIgASgJSABSB2dyb3VwSWQSNAoVbW9zdFJlY2VudE1lc3NhZ2VUaW1lGAMgASgDUhVtb3N0UmVjZW50TWVzc2FnZVRpbWUSNAoVbW9zdFJlY2VudE1lc3NhZ2VUZXh0GAQgASgJUhVtb3N0UmVjZW50TWVzc2FnZVRleHRCBwoFcGFydHk=');
@$core.Deprecated('Use shortMessageDescriptor instead')
const ShortMessage$json = const {
  '1': 'ShortMessage',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    const {'1': 'sent', '3': 2, '4': 1, '5': 3, '10': 'sent'},
    const {'1': 'text', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'text'},
    const {'1': 'oggVoice', '3': 4, '4': 1, '5': 12, '9': 0, '10': 'oggVoice'},
  ],
  '8': const [
    const {'1': 'body'},
  ],
};

/// Descriptor for `ShortMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shortMessageDescriptor = $convert.base64Decode('CgxTaG9ydE1lc3NhZ2USDgoCaWQYASABKAxSAmlkEhIKBHNlbnQYAiABKANSBHNlbnQSFAoEdGV4dBgDIAEoCUgAUgR0ZXh0EhwKCG9nZ1ZvaWNlGAQgASgMSABSCG9nZ1ZvaWNlQgYKBGJvZHk=');
@$core.Deprecated('Use shortMessageRecordDescriptor instead')
const ShortMessageRecord$json = const {
  '1': 'ShortMessageRecord',
  '2': const [
    const {'1': 'senderId', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'sent', '3': 3, '4': 1, '5': 3, '10': 'sent'},
    const {'1': 'direction', '3': 4, '4': 1, '5': 14, '6': '.model.ShortMessageRecord.Direction', '10': 'direction'},
    const {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.model.ShortMessageRecord.DeliveryStatus', '10': 'status'},
    const {'1': 'message', '3': 6, '4': 1, '5': 12, '10': 'message'},
  ],
  '4': const [ShortMessageRecord_Direction$json, ShortMessageRecord_DeliveryStatus$json],
};

@$core.Deprecated('Use shortMessageRecordDescriptor instead')
const ShortMessageRecord_Direction$json = const {
  '1': 'Direction',
  '2': const [
    const {'1': 'OUT', '2': 0},
    const {'1': 'IN', '2': 1},
  ],
};

@$core.Deprecated('Use shortMessageRecordDescriptor instead')
const ShortMessageRecord_DeliveryStatus$json = const {
  '1': 'DeliveryStatus',
  '2': const [
    const {'1': 'UNSENT', '2': 0},
    const {'1': 'FAILING', '2': 1},
    const {'1': 'PARTIALLY_FAILED', '2': 2},
    const {'1': 'COMPLETELY_FAILED', '2': 3},
    const {'1': 'SENT', '2': 4},
  ],
};

/// Descriptor for `ShortMessageRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shortMessageRecordDescriptor = $convert.base64Decode('ChJTaG9ydE1lc3NhZ2VSZWNvcmQSGgoIc2VuZGVySWQYASABKAlSCHNlbmRlcklkEg4KAmlkGAIgASgJUgJpZBISCgRzZW50GAMgASgDUgRzZW50EkEKCWRpcmVjdGlvbhgEIAEoDjIjLm1vZGVsLlNob3J0TWVzc2FnZVJlY29yZC5EaXJlY3Rpb25SCWRpcmVjdGlvbhJACgZzdGF0dXMYBSABKA4yKC5tb2RlbC5TaG9ydE1lc3NhZ2VSZWNvcmQuRGVsaXZlcnlTdGF0dXNSBnN0YXR1cxIYCgdtZXNzYWdlGAYgASgMUgdtZXNzYWdlIhwKCURpcmVjdGlvbhIHCgNPVVQQABIGCgJJThABImAKDkRlbGl2ZXJ5U3RhdHVzEgoKBlVOU0VOVBAAEgsKB0ZBSUxJTkcQARIUChBQQVJUSUFMTFlfRkFJTEVEEAISFQoRQ09NUExFVEVMWV9GQUlMRUQQAxIICgRTRU5UEAQ=');
@$core.Deprecated('Use outgoingShortMessageDescriptor instead')
const OutgoingShortMessage$json = const {
  '1': 'OutgoingShortMessage',
  '2': const [
    const {'1': 'contactId', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'contactId'},
    const {'1': 'groupId', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'groupId'},
    const {'1': 'remainingRecipients', '3': 3, '4': 3, '5': 9, '10': 'remainingRecipients'},
    const {'1': 'message', '3': 4, '4': 1, '5': 11, '6': '.model.ShortMessage', '10': 'message'},
    const {'1': 'lastFailed', '3': 5, '4': 1, '5': 3, '10': 'lastFailed'},
  ],
  '8': const [
    const {'1': 'recipient'},
  ],
};

/// Descriptor for `OutgoingShortMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outgoingShortMessageDescriptor = $convert.base64Decode('ChRPdXRnb2luZ1Nob3J0TWVzc2FnZRIeCgljb250YWN0SWQYASABKAlIAFIJY29udGFjdElkEhoKB2dyb3VwSWQYAiABKAlIAFIHZ3JvdXBJZBIwChNyZW1haW5pbmdSZWNpcGllbnRzGAMgAygJUhNyZW1haW5pbmdSZWNpcGllbnRzEi0KB21lc3NhZ2UYBCABKAsyEy5tb2RlbC5TaG9ydE1lc3NhZ2VSB21lc3NhZ2USHgoKbGFzdEZhaWxlZBgFIAEoA1IKbGFzdEZhaWxlZEILCglyZWNpcGllbnQ=');
@$core.Deprecated('Use transferMessageDescriptor instead')
const TransferMessage$json = const {
  '1': 'TransferMessage',
  '2': const [
    const {'1': 'shortMessage', '3': 1, '4': 1, '5': 11, '6': '.model.ShortMessage', '9': 0, '10': 'shortMessage'},
  ],
  '8': const [
    const {'1': 'content'},
  ],
};

/// Descriptor for `TransferMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferMessageDescriptor = $convert.base64Decode('Cg9UcmFuc2Zlck1lc3NhZ2USOQoMc2hvcnRNZXNzYWdlGAEgASgLMhMubW9kZWwuU2hvcnRNZXNzYWdlSABSDHNob3J0TWVzc2FnZUIJCgdjb250ZW50');
