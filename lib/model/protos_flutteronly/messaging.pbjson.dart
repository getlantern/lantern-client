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
@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment$json = const {
  '1': 'Attachment',
  '2': const [
    const {'1': 'mimeType', '3': 1, '4': 1, '5': 9, '10': 'mimeType'},
    const {'1': 'keyMaterial', '3': 2, '4': 1, '5': 12, '10': 'keyMaterial'},
    const {'1': 'digest', '3': 3, '4': 1, '5': 12, '10': 'digest'},
    const {'1': 'plaintextLength', '3': 4, '4': 1, '5': 3, '10': 'plaintextLength'},
    const {'1': 'metadata', '3': 5, '4': 3, '5': 11, '6': '.model.Attachment.MetadataEntry', '10': 'metadata'},
    const {'1': 'downloadUrl', '3': 6, '4': 1, '5': 9, '10': 'downloadUrl'},
  ],
  '3': const [Attachment_MetadataEntry$json],
};

@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment_MetadataEntry$json = const {
  '1': 'MetadataEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `Attachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentDescriptor = $convert.base64Decode('CgpBdHRhY2htZW50EhoKCG1pbWVUeXBlGAEgASgJUghtaW1lVHlwZRIgCgtrZXlNYXRlcmlhbBgCIAEoDFILa2V5TWF0ZXJpYWwSFgoGZGlnZXN0GAMgASgMUgZkaWdlc3QSKAoPcGxhaW50ZXh0TGVuZ3RoGAQgASgDUg9wbGFpbnRleHRMZW5ndGgSOwoIbWV0YWRhdGEYBSADKAsyHy5tb2RlbC5BdHRhY2htZW50Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhEiAKC2Rvd25sb2FkVXJsGAYgASgJUgtkb3dubG9hZFVybBo7Cg1NZXRhZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');
@$core.Deprecated('Use storedAttachmentDescriptor instead')
const StoredAttachment$json = const {
  '1': 'StoredAttachment',
  '2': const [
    const {'1': 'guid', '3': 1, '4': 1, '5': 9, '10': 'guid'},
    const {'1': 'attachment', '3': 2, '4': 1, '5': 11, '6': '.model.Attachment', '10': 'attachment'},
    const {'1': 'filePath', '3': 3, '4': 1, '5': 9, '10': 'filePath'},
    const {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.model.StoredAttachment.Status', '10': 'status'},
  ],
  '4': const [StoredAttachment_Status$json],
};

@$core.Deprecated('Use storedAttachmentDescriptor instead')
const StoredAttachment_Status$json = const {
  '1': 'Status',
  '2': const [
    const {'1': 'PENDING', '2': 0},
    const {'1': 'DONE', '2': 1},
    const {'1': 'FAILED', '2': 2},
  ],
};

/// Descriptor for `StoredAttachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storedAttachmentDescriptor = $convert.base64Decode('ChBTdG9yZWRBdHRhY2htZW50EhIKBGd1aWQYASABKAlSBGd1aWQSMQoKYXR0YWNobWVudBgCIAEoCzIRLm1vZGVsLkF0dGFjaG1lbnRSCmF0dGFjaG1lbnQSGgoIZmlsZVBhdGgYAyABKAlSCGZpbGVQYXRoEjYKBnN0YXR1cxgEIAEoDjIeLm1vZGVsLlN0b3JlZEF0dGFjaG1lbnQuU3RhdHVzUgZzdGF0dXMiKwoGU3RhdHVzEgsKB1BFTkRJTkcQABIICgRET05FEAESCgoGRkFJTEVEEAI=');
@$core.Deprecated('Use messageDescriptor instead')
const Message$json = const {
  '1': 'Message',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    const {'1': 'replyToSenderId', '3': 2, '4': 1, '5': 12, '10': 'replyToSenderId'},
    const {'1': 'replyToId', '3': 3, '4': 1, '5': 12, '10': 'replyToId'},
    const {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
    const {'1': 'attachments', '3': 5, '4': 3, '5': 11, '6': '.model.Message.AttachmentsEntry', '10': 'attachments'},
  ],
  '3': const [Message_AttachmentsEntry$json],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_AttachmentsEntry$json = const {
  '1': 'AttachmentsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.model.Attachment', '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode('CgdNZXNzYWdlEg4KAmlkGAEgASgMUgJpZBIoCg9yZXBseVRvU2VuZGVySWQYAiABKAxSD3JlcGx5VG9TZW5kZXJJZBIcCglyZXBseVRvSWQYAyABKAxSCXJlcGx5VG9JZBISCgR0ZXh0GAQgASgJUgR0ZXh0EkEKC2F0dGFjaG1lbnRzGAUgAygLMh8ubW9kZWwuTWVzc2FnZS5BdHRhY2htZW50c0VudHJ5UgthdHRhY2htZW50cxpRChBBdHRhY2htZW50c0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5EicKBXZhbHVlGAIgASgLMhEubW9kZWwuQXR0YWNobWVudFIFdmFsdWU6AjgB');
@$core.Deprecated('Use storedMessageDescriptor instead')
const StoredMessage$json = const {
  '1': 'StoredMessage',
  '2': const [
    const {'1': 'senderId', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'ts', '3': 3, '4': 1, '5': 3, '10': 'ts'},
    const {'1': 'replyToSenderId', '3': 4, '4': 1, '5': 9, '10': 'replyToSenderId'},
    const {'1': 'replyToId', '3': 5, '4': 1, '5': 9, '10': 'replyToId'},
    const {'1': 'text', '3': 6, '4': 1, '5': 9, '10': 'text'},
    const {'1': 'attachments', '3': 7, '4': 3, '5': 11, '6': '.model.StoredMessage.AttachmentsEntry', '10': 'attachments'},
    const {'1': 'direction', '3': 8, '4': 1, '5': 14, '6': '.model.MessageDirection', '10': 'direction'},
    const {'1': 'status', '3': 9, '4': 1, '5': 14, '6': '.model.StoredMessage.DeliveryStatus', '10': 'status'},
  ],
  '3': const [StoredMessage_AttachmentsEntry$json],
  '4': const [StoredMessage_DeliveryStatus$json],
};

@$core.Deprecated('Use storedMessageDescriptor instead')
const StoredMessage_AttachmentsEntry$json = const {
  '1': 'AttachmentsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.model.StoredAttachment', '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use storedMessageDescriptor instead')
const StoredMessage_DeliveryStatus$json = const {
  '1': 'DeliveryStatus',
  '2': const [
    const {'1': 'SENDING', '2': 0},
    const {'1': 'PARTIALLY_SENT', '2': 1},
    const {'1': 'COMPLETELY_SENT', '2': 2},
    const {'1': 'PARTIALLY_FAILED', '2': 3},
    const {'1': 'COMPLETELY_FAILED', '2': 4},
  ],
};

/// Descriptor for `StoredMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storedMessageDescriptor = $convert.base64Decode('Cg1TdG9yZWRNZXNzYWdlEhoKCHNlbmRlcklkGAEgASgJUghzZW5kZXJJZBIOCgJpZBgCIAEoCVICaWQSDgoCdHMYAyABKANSAnRzEigKD3JlcGx5VG9TZW5kZXJJZBgEIAEoCVIPcmVwbHlUb1NlbmRlcklkEhwKCXJlcGx5VG9JZBgFIAEoCVIJcmVwbHlUb0lkEhIKBHRleHQYBiABKAlSBHRleHQSRwoLYXR0YWNobWVudHMYByADKAsyJS5tb2RlbC5TdG9yZWRNZXNzYWdlLkF0dGFjaG1lbnRzRW50cnlSC2F0dGFjaG1lbnRzEjUKCWRpcmVjdGlvbhgIIAEoDjIXLm1vZGVsLk1lc3NhZ2VEaXJlY3Rpb25SCWRpcmVjdGlvbhI7CgZzdGF0dXMYCSABKA4yIy5tb2RlbC5TdG9yZWRNZXNzYWdlLkRlbGl2ZXJ5U3RhdHVzUgZzdGF0dXMaVwoQQXR0YWNobWVudHNFbnRyeRIQCgNrZXkYASABKAVSA2tleRItCgV2YWx1ZRgCIAEoCzIXLm1vZGVsLlN0b3JlZEF0dGFjaG1lbnRSBXZhbHVlOgI4ASJzCg5EZWxpdmVyeVN0YXR1cxILCgdTRU5ESU5HEAASEgoOUEFSVElBTExZX1NFTlQQARITCg9DT01QTEVURUxZX1NFTlQQAhIUChBQQVJUSUFMTFlfRkFJTEVEEAMSFQoRQ09NUExFVEVMWV9GQUlMRUQQBA==');
@$core.Deprecated('Use outboundMessageDescriptor instead')
const OutboundMessage$json = const {
  '1': 'OutboundMessage',
  '2': const [
    const {'1': 'senderId', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'sent', '3': 3, '4': 1, '5': 3, '10': 'sent'},
    const {'1': 'recipientId', '3': 4, '4': 1, '5': 9, '10': 'recipientId'},
    const {'1': 'subDeliveryStatuses', '3': 5, '4': 3, '5': 11, '6': '.model.OutboundMessage.SubDeliveryStatusesEntry', '10': 'subDeliveryStatuses'},
  ],
  '3': const [OutboundMessage_SubDeliveryStatusesEntry$json],
  '4': const [OutboundMessage_SubDeliveryStatus$json],
};

@$core.Deprecated('Use outboundMessageDescriptor instead')
const OutboundMessage_SubDeliveryStatusesEntry$json = const {
  '1': 'SubDeliveryStatusesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 14, '6': '.model.OutboundMessage.SubDeliveryStatus', '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use outboundMessageDescriptor instead')
const OutboundMessage_SubDeliveryStatus$json = const {
  '1': 'SubDeliveryStatus',
  '2': const [
    const {'1': 'SENDING', '2': 0},
    const {'1': 'SENT', '2': 1},
  ],
};

/// Descriptor for `OutboundMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outboundMessageDescriptor = $convert.base64Decode('Cg9PdXRib3VuZE1lc3NhZ2USGgoIc2VuZGVySWQYASABKAlSCHNlbmRlcklkEg4KAmlkGAIgASgJUgJpZBISCgRzZW50GAMgASgDUgRzZW50EiAKC3JlY2lwaWVudElkGAQgASgJUgtyZWNpcGllbnRJZBJhChNzdWJEZWxpdmVyeVN0YXR1c2VzGAUgAygLMi8ubW9kZWwuT3V0Ym91bmRNZXNzYWdlLlN1YkRlbGl2ZXJ5U3RhdHVzZXNFbnRyeVITc3ViRGVsaXZlcnlTdGF0dXNlcxpwChhTdWJEZWxpdmVyeVN0YXR1c2VzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSPgoFdmFsdWUYAiABKA4yKC5tb2RlbC5PdXRib3VuZE1lc3NhZ2UuU3ViRGVsaXZlcnlTdGF0dXNSBXZhbHVlOgI4ASIqChFTdWJEZWxpdmVyeVN0YXR1cxILCgdTRU5ESU5HEAASCAoEU0VOVBAB');
@$core.Deprecated('Use inboundAttachmentDescriptor instead')
const InboundAttachment$json = const {
  '1': 'InboundAttachment',
  '2': const [
    const {'1': 'senderId', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    const {'1': 'messageId', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    const {'1': 'ts', '3': 3, '4': 1, '5': 3, '10': 'ts'},
    const {'1': 'attachmentId', '3': 4, '4': 1, '5': 5, '10': 'attachmentId'},
  ],
};

/// Descriptor for `InboundAttachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inboundAttachmentDescriptor = $convert.base64Decode('ChFJbmJvdW5kQXR0YWNobWVudBIaCghzZW5kZXJJZBgBIAEoCVIIc2VuZGVySWQSHAoJbWVzc2FnZUlkGAIgASgJUgltZXNzYWdlSWQSDgoCdHMYAyABKANSAnRzEiIKDGF0dGFjaG1lbnRJZBgEIAEoBVIMYXR0YWNobWVudElk');
@$core.Deprecated('Use transferMessageDescriptor instead')
const TransferMessage$json = const {
  '1': 'TransferMessage',
  '2': const [
    const {'1': 'Message', '3': 1, '4': 1, '5': 12, '9': 0, '10': 'Message'},
  ],
  '8': const [
    const {'1': 'content'},
  ],
};

/// Descriptor for `TransferMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferMessageDescriptor = $convert.base64Decode('Cg9UcmFuc2Zlck1lc3NhZ2USGgoHTWVzc2FnZRgBIAEoDEgAUgdNZXNzYWdlQgkKB2NvbnRlbnQ=');
