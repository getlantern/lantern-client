///
//  Generated code. Do not modify.
//  source: protos_flutteronly/messaging.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use messageDirectionDescriptor instead')
const MessageDirection$json = const {
  '1': 'MessageDirection',
  '2': const [
    const {'1': 'OUT', '2': 0},
    const {'1': 'IN', '2': 1},
  ],
};

/// Descriptor for `MessageDirection`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageDirectionDescriptor = $convert.base64Decode('ChBNZXNzYWdlRGlyZWN0aW9uEgcKA09VVBAAEgYKAklOEAE=');
@$core.Deprecated('Use contactDescriptor instead')
const Contact$json = const {
  '1': 'Contact',
  '2': const [
    const {'1': 'type', '3': 2, '4': 1, '5': 14, '6': '.model.Contact.Type', '10': 'type'},
    const {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'memberIds', '3': 4, '4': 3, '5': 9, '10': 'memberIds'},
    const {'1': 'displayName', '3': 5, '4': 1, '5': 9, '10': 'displayName'},
    const {'1': 'createdTime', '3': 6, '4': 1, '5': 3, '10': 'createdTime'},
    const {'1': 'mostRecentMessageTs', '3': 7, '4': 1, '5': 3, '10': 'mostRecentMessageTs'},
    const {'1': 'mostRecentMessageDirection', '3': 8, '4': 1, '5': 14, '6': '.model.MessageDirection', '10': 'mostRecentMessageDirection'},
    const {'1': 'mostRecentMessageText', '3': 9, '4': 1, '5': 9, '10': 'mostRecentMessageText'},
  ],
  '4': const [Contact_Type$json],
};

@$core.Deprecated('Use contactDescriptor instead')
const Contact_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'DIRECT', '2': 0},
    const {'1': 'GROUP', '2': 1},
  ],
};

/// Descriptor for `Contact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactDescriptor = $convert.base64Decode('CgdDb250YWN0EicKBHR5cGUYAiABKA4yEy5tb2RlbC5Db250YWN0LlR5cGVSBHR5cGUSDgoCaWQYAyABKAlSAmlkEhwKCW1lbWJlcklkcxgEIAMoCVIJbWVtYmVySWRzEiAKC2Rpc3BsYXlOYW1lGAUgASgJUgtkaXNwbGF5TmFtZRIgCgtjcmVhdGVkVGltZRgGIAEoA1ILY3JlYXRlZFRpbWUSMAoTbW9zdFJlY2VudE1lc3NhZ2VUcxgHIAEoA1ITbW9zdFJlY2VudE1lc3NhZ2VUcxJXChptb3N0UmVjZW50TWVzc2FnZURpcmVjdGlvbhgIIAEoDjIXLm1vZGVsLk1lc3NhZ2VEaXJlY3Rpb25SGm1vc3RSZWNlbnRNZXNzYWdlRGlyZWN0aW9uEjQKFW1vc3RSZWNlbnRNZXNzYWdlVGV4dBgJIAEoCVIVbW9zdFJlY2VudE1lc3NhZ2VUZXh0Ih0KBFR5cGUSCgoGRElSRUNUEAASCQoFR1JPVVAQAQ==');
@$core.Deprecated('Use shortMessageDescriptor instead')
const ShortMessage$json = const {
  '1': 'ShortMessage',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    const {'1': 'replyToSenderId', '3': 2, '4': 1, '5': 12, '10': 'replyToSenderId'},
    const {'1': 'replyToId', '3': 3, '4': 1, '5': 12, '10': 'replyToId'},
    const {'1': 'text', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'text'},
    const {'1': 'oggVoice', '3': 5, '4': 1, '5': 12, '9': 0, '10': 'oggVoice'},
  ],
  '8': const [
    const {'1': 'body'},
  ],
};

/// Descriptor for `ShortMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shortMessageDescriptor = $convert.base64Decode('CgxTaG9ydE1lc3NhZ2USDgoCaWQYASABKAxSAmlkEigKD3JlcGx5VG9TZW5kZXJJZBgCIAEoDFIPcmVwbHlUb1NlbmRlcklkEhwKCXJlcGx5VG9JZBgDIAEoDFIJcmVwbHlUb0lkEhQKBHRleHQYBCABKAlIAFIEdGV4dBIcCghvZ2dWb2ljZRgFIAEoDEgAUghvZ2dWb2ljZUIGCgRib2R5');
@$core.Deprecated('Use shortMessageRecordDescriptor instead')
const ShortMessageRecord$json = const {
  '1': 'ShortMessageRecord',
  '2': const [
    const {'1': 'senderId', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'ts', '3': 3, '4': 1, '5': 3, '10': 'ts'},
    const {'1': 'replyToSenderId', '3': 4, '4': 1, '5': 9, '10': 'replyToSenderId'},
    const {'1': 'replyToId', '3': 5, '4': 1, '5': 9, '10': 'replyToId'},
    const {'1': 'direction', '3': 6, '4': 1, '5': 14, '6': '.model.MessageDirection', '10': 'direction'},
    const {'1': 'status', '3': 7, '4': 1, '5': 14, '6': '.model.ShortMessageRecord.DeliveryStatus', '10': 'status'},
    const {'1': 'message', '3': 8, '4': 1, '5': 12, '10': 'message'},
  ],
  '4': const [ShortMessageRecord_DeliveryStatus$json],
};

@$core.Deprecated('Use shortMessageRecordDescriptor instead')
const ShortMessageRecord_DeliveryStatus$json = const {
  '1': 'DeliveryStatus',
  '2': const [
    const {'1': 'SENDING', '2': 0},
    const {'1': 'PARTIALLY_SENT', '2': 1},
    const {'1': 'COMPLETELY_SENT', '2': 2},
    const {'1': 'PARTIALLY_FAILED', '2': 3},
    const {'1': 'COMPLETELY_FAILED', '2': 4},
  ],
};

/// Descriptor for `ShortMessageRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shortMessageRecordDescriptor = $convert.base64Decode('ChJTaG9ydE1lc3NhZ2VSZWNvcmQSGgoIc2VuZGVySWQYASABKAlSCHNlbmRlcklkEg4KAmlkGAIgASgJUgJpZBIOCgJ0cxgDIAEoA1ICdHMSKAoPcmVwbHlUb1NlbmRlcklkGAQgASgJUg9yZXBseVRvU2VuZGVySWQSHAoJcmVwbHlUb0lkGAUgASgJUglyZXBseVRvSWQSNQoJZGlyZWN0aW9uGAYgASgOMhcubW9kZWwuTWVzc2FnZURpcmVjdGlvblIJZGlyZWN0aW9uEkAKBnN0YXR1cxgHIAEoDjIoLm1vZGVsLlNob3J0TWVzc2FnZVJlY29yZC5EZWxpdmVyeVN0YXR1c1IGc3RhdHVzEhgKB21lc3NhZ2UYCCABKAxSB21lc3NhZ2UicwoORGVsaXZlcnlTdGF0dXMSCwoHU0VORElORxAAEhIKDlBBUlRJQUxMWV9TRU5UEAESEwoPQ09NUExFVEVMWV9TRU5UEAISFAoQUEFSVElBTExZX0ZBSUxFRBADEhUKEUNPTVBMRVRFTFlfRkFJTEVEEAQ=');
@$core.Deprecated('Use outgoingShortMessageDescriptor instead')
const OutgoingShortMessage$json = const {
  '1': 'OutgoingShortMessage',
  '2': const [
    const {'1': 'senderId', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'sent', '3': 3, '4': 1, '5': 3, '10': 'sent'},
    const {'1': 'recipientId', '3': 4, '4': 1, '5': 9, '10': 'recipientId'},
    const {'1': 'subDeliveryStatuses', '3': 5, '4': 3, '5': 11, '6': '.model.OutgoingShortMessage.SubDeliveryStatusesEntry', '10': 'subDeliveryStatuses'},
  ],
  '3': const [OutgoingShortMessage_SubDeliveryStatusesEntry$json],
  '4': const [OutgoingShortMessage_SubDeliveryStatus$json],
};

@$core.Deprecated('Use outgoingShortMessageDescriptor instead')
const OutgoingShortMessage_SubDeliveryStatusesEntry$json = const {
  '1': 'SubDeliveryStatusesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 14, '6': '.model.OutgoingShortMessage.SubDeliveryStatus', '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use outgoingShortMessageDescriptor instead')
const OutgoingShortMessage_SubDeliveryStatus$json = const {
  '1': 'SubDeliveryStatus',
  '2': const [
    const {'1': 'SENDING', '2': 0},
    const {'1': 'SENT', '2': 1},
  ],
};

/// Descriptor for `OutgoingShortMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outgoingShortMessageDescriptor = $convert.base64Decode('ChRPdXRnb2luZ1Nob3J0TWVzc2FnZRIaCghzZW5kZXJJZBgBIAEoCVIIc2VuZGVySWQSDgoCaWQYAiABKAlSAmlkEhIKBHNlbnQYAyABKANSBHNlbnQSIAoLcmVjaXBpZW50SWQYBCABKAlSC3JlY2lwaWVudElkEmYKE3N1YkRlbGl2ZXJ5U3RhdHVzZXMYBSADKAsyNC5tb2RlbC5PdXRnb2luZ1Nob3J0TWVzc2FnZS5TdWJEZWxpdmVyeVN0YXR1c2VzRW50cnlSE3N1YkRlbGl2ZXJ5U3RhdHVzZXMadQoYU3ViRGVsaXZlcnlTdGF0dXNlc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EkMKBXZhbHVlGAIgASgOMi0ubW9kZWwuT3V0Z29pbmdTaG9ydE1lc3NhZ2UuU3ViRGVsaXZlcnlTdGF0dXNSBXZhbHVlOgI4ASIqChFTdWJEZWxpdmVyeVN0YXR1cxILCgdTRU5ESU5HEAASCAoEU0VOVBAB');
@$core.Deprecated('Use transferMessageDescriptor instead')
const TransferMessage$json = const {
  '1': 'TransferMessage',
  '2': const [
    const {'1': 'shortMessage', '3': 1, '4': 1, '5': 12, '9': 0, '10': 'shortMessage'},
  ],
  '8': const [
    const {'1': 'content'},
  ],
};

/// Descriptor for `TransferMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferMessageDescriptor = $convert.base64Decode('Cg9UcmFuc2Zlck1lc3NhZ2USJAoMc2hvcnRNZXNzYWdlGAEgASgMSABSDHNob3J0TWVzc2FnZUIJCgdjb250ZW50');
