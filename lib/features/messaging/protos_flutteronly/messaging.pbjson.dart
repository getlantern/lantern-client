//
//  Generated code. Do not modify.
//  source: protos_flutteronly/messaging.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use messageDirectionDescriptor instead')
const MessageDirection$json = {
  '1': 'MessageDirection',
  '2': [
    {'1': 'OUT', '2': 0},
    {'1': 'IN', '2': 1},
  ],
};

/// Descriptor for `MessageDirection`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageDirectionDescriptor = $convert.base64Decode(
    'ChBNZXNzYWdlRGlyZWN0aW9uEgcKA09VVBAAEgYKAklOEAE=');

@$core.Deprecated('Use contactTypeDescriptor instead')
const ContactType$json = {
  '1': 'ContactType',
  '2': [
    {'1': 'DIRECT', '2': 0},
    {'1': 'GROUP', '2': 1},
  ],
};

/// Descriptor for `ContactType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List contactTypeDescriptor = $convert.base64Decode(
    'CgtDb250YWN0VHlwZRIKCgZESVJFQ1QQABIJCgVHUk9VUBAB');

@$core.Deprecated('Use contactSourceDescriptor instead')
const ContactSource$json = {
  '1': 'ContactSource',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'INTRODUCTION', '2': 1},
    {'1': 'APP1', '2': 2},
    {'1': 'APP2', '2': 3},
    {'1': 'APP3', '2': 4},
    {'1': 'APP4', '2': 5},
    {'1': 'APP5', '2': 6},
    {'1': 'UNSOLICITED', '2': 7},
  ],
};

/// Descriptor for `ContactSource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List contactSourceDescriptor = $convert.base64Decode(
    'Cg1Db250YWN0U291cmNlEgsKB1VOS05PV04QABIQCgxJTlRST0RVQ1RJT04QARIICgRBUFAxEA'
    'ISCAoEQVBQMhADEggKBEFQUDMQBBIICgRBUFA0EAUSCAoEQVBQNRAGEg8KC1VOU09MSUNJVEVE'
    'EAc=');

@$core.Deprecated('Use verificationLevelDescriptor instead')
const VerificationLevel$json = {
  '1': 'VerificationLevel',
  '2': [
    {'1': 'UNACCEPTED', '2': 0},
    {'1': 'UNVERIFIED', '2': 1},
    {'1': 'VERIFIED', '2': 2},
  ],
};

/// Descriptor for `VerificationLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List verificationLevelDescriptor = $convert.base64Decode(
    'ChFWZXJpZmljYXRpb25MZXZlbBIOCgpVTkFDQ0VQVEVEEAASDgoKVU5WRVJJRklFRBABEgwKCF'
    'ZFUklGSUVEEAI=');

@$core.Deprecated('Use contactIdDescriptor instead')
const ContactId$json = {
  '1': 'ContactId',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.model.ContactType', '10': 'type'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `ContactId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactIdDescriptor = $convert.base64Decode(
    'CglDb250YWN0SWQSJgoEdHlwZRgBIAEoDjISLm1vZGVsLkNvbnRhY3RUeXBlUgR0eXBlEg4KAm'
    'lkGAIgASgJUgJpZA==');

@$core.Deprecated('Use chatNumberDescriptor instead')
const ChatNumber$json = {
  '1': 'ChatNumber',
  '2': [
    {'1': 'number', '3': 1, '4': 1, '5': 9, '10': 'number'},
    {'1': 'shortNumber', '3': 2, '4': 1, '5': 9, '10': 'shortNumber'},
    {'1': 'domain', '3': 3, '4': 1, '5': 9, '10': 'domain'},
  ],
};

/// Descriptor for `ChatNumber`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatNumberDescriptor = $convert.base64Decode(
    'CgpDaGF0TnVtYmVyEhYKBm51bWJlchgBIAEoCVIGbnVtYmVyEiAKC3Nob3J0TnVtYmVyGAIgAS'
    'gJUgtzaG9ydE51bWJlchIWCgZkb21haW4YAyABKAlSBmRvbWFpbg==');

@$core.Deprecated('Use datumDescriptor instead')
const Datum$json = {
  '1': 'Datum',
  '2': [
    {'1': 'string', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'string'},
    {'1': 'float', '3': 2, '4': 1, '5': 1, '9': 0, '10': 'float'},
    {'1': 'int', '3': 3, '4': 1, '5': 3, '9': 0, '10': 'int'},
    {'1': 'bool', '3': 4, '4': 1, '5': 8, '9': 0, '10': 'bool'},
    {'1': 'bytes', '3': 5, '4': 1, '5': 12, '9': 0, '10': 'bytes'},
  ],
  '8': [
    {'1': 'value'},
  ],
};

/// Descriptor for `Datum`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List datumDescriptor = $convert.base64Decode(
    'CgVEYXR1bRIYCgZzdHJpbmcYASABKAlIAFIGc3RyaW5nEhYKBWZsb2F0GAIgASgBSABSBWZsb2'
    'F0EhIKA2ludBgDIAEoA0gAUgNpbnQSFAoEYm9vbBgEIAEoCEgAUgRib29sEhYKBWJ5dGVzGAUg'
    'ASgMSABSBWJ5dGVzQgcKBXZhbHVl');

@$core.Deprecated('Use contactDescriptor instead')
const Contact$json = {
  '1': 'Contact',
  '2': [
    {'1': 'contactId', '3': 1, '4': 1, '5': 11, '6': '.model.ContactId', '10': 'contactId'},
    {'1': 'applicationIds', '3': 14, '4': 3, '5': 11, '6': '.model.Contact.ApplicationIdsEntry', '10': 'applicationIds'},
    {'1': 'memberIds', '3': 2, '4': 3, '5': 9, '10': 'memberIds'},
    {'1': 'displayName', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'source', '3': 13, '4': 1, '5': 14, '6': '.model.ContactSource', '10': 'source'},
    {'1': 'createdTs', '3': 4, '4': 1, '5': 3, '10': 'createdTs'},
    {'1': 'mostRecentMessageTs', '3': 5, '4': 1, '5': 3, '10': 'mostRecentMessageTs'},
    {'1': 'mostRecentMessageDirection', '3': 6, '4': 1, '5': 14, '6': '.model.MessageDirection', '10': 'mostRecentMessageDirection'},
    {'1': 'mostRecentMessageText', '3': 7, '4': 1, '5': 9, '10': 'mostRecentMessageText'},
    {'1': 'mostRecentAttachmentMimeType', '3': 8, '4': 1, '5': 9, '10': 'mostRecentAttachmentMimeType'},
    {'1': 'messagesDisappearAfterSeconds', '3': 9, '4': 1, '5': 5, '10': 'messagesDisappearAfterSeconds'},
    {'1': 'firstReceivedMessageTs', '3': 10, '4': 1, '5': 3, '10': 'firstReceivedMessageTs'},
    {'1': 'hasReceivedMessage', '3': 11, '4': 1, '5': 8, '10': 'hasReceivedMessage'},
    {'1': 'mostRecentHelloTs', '3': 12, '4': 1, '5': 3, '10': 'mostRecentHelloTs'},
    {'1': 'verificationLevel', '3': 15, '4': 1, '5': 14, '6': '.model.VerificationLevel', '10': 'verificationLevel'},
    {'1': 'numericFingerprint', '3': 16, '4': 1, '5': 9, '10': 'numericFingerprint'},
    {'1': 'blocked', '3': 17, '4': 1, '5': 8, '10': 'blocked'},
    {'1': 'applicationData', '3': 18, '4': 3, '5': 11, '6': '.model.Contact.ApplicationDataEntry', '10': 'applicationData'},
    {'1': 'chatNumber', '3': 19, '4': 1, '5': 11, '6': '.model.ChatNumber', '10': 'chatNumber'},
    {'1': 'isMe', '3': 20, '4': 1, '5': 8, '10': 'isMe'},
    {'1': 'numUnviewedMessages', '3': 21, '4': 1, '5': 5, '10': 'numUnviewedMessages'},
  ],
  '3': [Contact_ApplicationIdsEntry$json, Contact_ApplicationDataEntry$json],
};

@$core.Deprecated('Use contactDescriptor instead')
const Contact_ApplicationIdsEntry$json = {
  '1': 'ApplicationIdsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use contactDescriptor instead')
const Contact_ApplicationDataEntry$json = {
  '1': 'ApplicationDataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.model.Datum', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Contact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactDescriptor = $convert.base64Decode(
    'CgdDb250YWN0Ei4KCWNvbnRhY3RJZBgBIAEoCzIQLm1vZGVsLkNvbnRhY3RJZFIJY29udGFjdE'
    'lkEkoKDmFwcGxpY2F0aW9uSWRzGA4gAygLMiIubW9kZWwuQ29udGFjdC5BcHBsaWNhdGlvbklk'
    'c0VudHJ5Ug5hcHBsaWNhdGlvbklkcxIcCgltZW1iZXJJZHMYAiADKAlSCW1lbWJlcklkcxIgCg'
    'tkaXNwbGF5TmFtZRgDIAEoCVILZGlzcGxheU5hbWUSLAoGc291cmNlGA0gASgOMhQubW9kZWwu'
    'Q29udGFjdFNvdXJjZVIGc291cmNlEhwKCWNyZWF0ZWRUcxgEIAEoA1IJY3JlYXRlZFRzEjAKE2'
    '1vc3RSZWNlbnRNZXNzYWdlVHMYBSABKANSE21vc3RSZWNlbnRNZXNzYWdlVHMSVwoabW9zdFJl'
    'Y2VudE1lc3NhZ2VEaXJlY3Rpb24YBiABKA4yFy5tb2RlbC5NZXNzYWdlRGlyZWN0aW9uUhptb3'
    'N0UmVjZW50TWVzc2FnZURpcmVjdGlvbhI0ChVtb3N0UmVjZW50TWVzc2FnZVRleHQYByABKAlS'
    'FW1vc3RSZWNlbnRNZXNzYWdlVGV4dBJCChxtb3N0UmVjZW50QXR0YWNobWVudE1pbWVUeXBlGA'
    'ggASgJUhxtb3N0UmVjZW50QXR0YWNobWVudE1pbWVUeXBlEkQKHW1lc3NhZ2VzRGlzYXBwZWFy'
    'QWZ0ZXJTZWNvbmRzGAkgASgFUh1tZXNzYWdlc0Rpc2FwcGVhckFmdGVyU2Vjb25kcxI2ChZmaX'
    'JzdFJlY2VpdmVkTWVzc2FnZVRzGAogASgDUhZmaXJzdFJlY2VpdmVkTWVzc2FnZVRzEi4KEmhh'
    'c1JlY2VpdmVkTWVzc2FnZRgLIAEoCFISaGFzUmVjZWl2ZWRNZXNzYWdlEiwKEW1vc3RSZWNlbn'
    'RIZWxsb1RzGAwgASgDUhFtb3N0UmVjZW50SGVsbG9UcxJGChF2ZXJpZmljYXRpb25MZXZlbBgP'
    'IAEoDjIYLm1vZGVsLlZlcmlmaWNhdGlvbkxldmVsUhF2ZXJpZmljYXRpb25MZXZlbBIuChJudW'
    '1lcmljRmluZ2VycHJpbnQYECABKAlSEm51bWVyaWNGaW5nZXJwcmludBIYCgdibG9ja2VkGBEg'
    'ASgIUgdibG9ja2VkEk0KD2FwcGxpY2F0aW9uRGF0YRgSIAMoCzIjLm1vZGVsLkNvbnRhY3QuQX'
    'BwbGljYXRpb25EYXRhRW50cnlSD2FwcGxpY2F0aW9uRGF0YRIxCgpjaGF0TnVtYmVyGBMgASgL'
    'MhEubW9kZWwuQ2hhdE51bWJlclIKY2hhdE51bWJlchISCgRpc01lGBQgASgIUgRpc01lEjAKE2'
    '51bVVudmlld2VkTWVzc2FnZXMYFSABKAVSE251bVVudmlld2VkTWVzc2FnZXMaQQoTQXBwbGlj'
    'YXRpb25JZHNFbnRyeRIQCgNrZXkYASABKAVSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6Aj'
    'gBGlAKFEFwcGxpY2F0aW9uRGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiIKBXZhbHVlGAIg'
    'ASgLMgwubW9kZWwuRGF0dW1SBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use provisionalContactDescriptor instead')
const ProvisionalContact$json = {
  '1': 'ProvisionalContact',
  '2': [
    {'1': 'contactId', '3': 1, '4': 1, '5': 9, '10': 'contactId'},
    {'1': 'expiresAt', '3': 2, '4': 1, '5': 3, '10': 'expiresAt'},
    {'1': 'source', '3': 3, '4': 1, '5': 14, '6': '.model.ContactSource', '10': 'source'},
    {'1': 'verificationLevel', '3': 4, '4': 1, '5': 14, '6': '.model.VerificationLevel', '10': 'verificationLevel'},
  ],
};

/// Descriptor for `ProvisionalContact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List provisionalContactDescriptor = $convert.base64Decode(
    'ChJQcm92aXNpb25hbENvbnRhY3QSHAoJY29udGFjdElkGAEgASgJUgljb250YWN0SWQSHAoJZX'
    'hwaXJlc0F0GAIgASgDUglleHBpcmVzQXQSLAoGc291cmNlGAMgASgOMhQubW9kZWwuQ29udGFj'
    'dFNvdXJjZVIGc291cmNlEkYKEXZlcmlmaWNhdGlvbkxldmVsGAQgASgOMhgubW9kZWwuVmVyaW'
    'ZpY2F0aW9uTGV2ZWxSEXZlcmlmaWNhdGlvbkxldmVs');

@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment$json = {
  '1': 'Attachment',
  '2': [
    {'1': 'mimeType', '3': 1, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'keyMaterial', '3': 2, '4': 1, '5': 12, '10': 'keyMaterial'},
    {'1': 'digest', '3': 3, '4': 1, '5': 12, '10': 'digest'},
    {'1': 'plaintextLength', '3': 4, '4': 1, '5': 3, '10': 'plaintextLength'},
    {'1': 'metadata', '3': 5, '4': 3, '5': 11, '6': '.model.Attachment.MetadataEntry', '10': 'metadata'},
    {'1': 'downloadUrl', '3': 6, '4': 1, '5': 9, '10': 'downloadUrl'},
  ],
  '3': [Attachment_MetadataEntry$json],
};

@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Attachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentDescriptor = $convert.base64Decode(
    'CgpBdHRhY2htZW50EhoKCG1pbWVUeXBlGAEgASgJUghtaW1lVHlwZRIgCgtrZXlNYXRlcmlhbB'
    'gCIAEoDFILa2V5TWF0ZXJpYWwSFgoGZGlnZXN0GAMgASgMUgZkaWdlc3QSKAoPcGxhaW50ZXh0'
    'TGVuZ3RoGAQgASgDUg9wbGFpbnRleHRMZW5ndGgSOwoIbWV0YWRhdGEYBSADKAsyHy5tb2RlbC'
    '5BdHRhY2htZW50Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhEiAKC2Rvd25sb2FkVXJsGAYgASgJ'
    'Ugtkb3dubG9hZFVybBo7Cg1NZXRhZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbH'
    'VlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use storedAttachmentDescriptor instead')
const StoredAttachment$json = {
  '1': 'StoredAttachment',
  '2': [
    {'1': 'guid', '3': 1, '4': 1, '5': 9, '10': 'guid'},
    {'1': 'attachment', '3': 2, '4': 1, '5': 11, '6': '.model.Attachment', '10': 'attachment'},
    {'1': 'plainTextFilePath', '3': 5, '4': 1, '5': 9, '10': 'plainTextFilePath'},
    {'1': 'encryptedFilePath', '3': 3, '4': 1, '5': 9, '10': 'encryptedFilePath'},
    {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.model.StoredAttachment.Status', '10': 'status'},
    {'1': 'thumbnail', '3': 6, '4': 1, '5': 11, '6': '.model.StoredAttachment', '10': 'thumbnail'},
  ],
  '4': [StoredAttachment_Status$json],
};

@$core.Deprecated('Use storedAttachmentDescriptor instead')
const StoredAttachment_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'PENDING', '2': 0},
    {'1': 'PENDING_UPLOAD', '2': 1},
    {'1': 'DONE', '2': 2},
    {'1': 'FAILED', '2': 3},
  ],
};

/// Descriptor for `StoredAttachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storedAttachmentDescriptor = $convert.base64Decode(
    'ChBTdG9yZWRBdHRhY2htZW50EhIKBGd1aWQYASABKAlSBGd1aWQSMQoKYXR0YWNobWVudBgCIA'
    'EoCzIRLm1vZGVsLkF0dGFjaG1lbnRSCmF0dGFjaG1lbnQSLAoRcGxhaW5UZXh0RmlsZVBhdGgY'
    'BSABKAlSEXBsYWluVGV4dEZpbGVQYXRoEiwKEWVuY3J5cHRlZEZpbGVQYXRoGAMgASgJUhFlbm'
    'NyeXB0ZWRGaWxlUGF0aBI2CgZzdGF0dXMYBCABKA4yHi5tb2RlbC5TdG9yZWRBdHRhY2htZW50'
    'LlN0YXR1c1IGc3RhdHVzEjUKCXRodW1ibmFpbBgGIAEoCzIXLm1vZGVsLlN0b3JlZEF0dGFjaG'
    '1lbnRSCXRodW1ibmFpbCI/CgZTdGF0dXMSCwoHUEVORElORxAAEhIKDlBFTkRJTkdfVVBMT0FE'
    'EAESCAoERE9ORRACEgoKBkZBSUxFRBAD');

@$core.Deprecated('Use attachmentWithThumbnailDescriptor instead')
const AttachmentWithThumbnail$json = {
  '1': 'AttachmentWithThumbnail',
  '2': [
    {'1': 'attachment', '3': 1, '4': 1, '5': 11, '6': '.model.Attachment', '10': 'attachment'},
    {'1': 'thumbnail', '3': 2, '4': 1, '5': 11, '6': '.model.Attachment', '10': 'thumbnail'},
  ],
};

/// Descriptor for `AttachmentWithThumbnail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentWithThumbnailDescriptor = $convert.base64Decode(
    'ChdBdHRhY2htZW50V2l0aFRodW1ibmFpbBIxCgphdHRhY2htZW50GAEgASgLMhEubW9kZWwuQX'
    'R0YWNobWVudFIKYXR0YWNobWVudBIvCgl0aHVtYm5haWwYAiABKAsyES5tb2RlbC5BdHRhY2ht'
    'ZW50Ugl0aHVtYm5haWw=');

@$core.Deprecated('Use introductionDescriptor instead')
const Introduction$json = {
  '1': 'Introduction',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    {'1': 'displayName', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'verificationLevel', '3': 3, '4': 1, '5': 14, '6': '.model.VerificationLevel', '10': 'verificationLevel'},
  ],
};

/// Descriptor for `Introduction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List introductionDescriptor = $convert.base64Decode(
    'CgxJbnRyb2R1Y3Rpb24SDgoCaWQYASABKAxSAmlkEiAKC2Rpc3BsYXlOYW1lGAIgASgJUgtkaX'
    'NwbGF5TmFtZRJGChF2ZXJpZmljYXRpb25MZXZlbBgDIAEoDjIYLm1vZGVsLlZlcmlmaWNhdGlv'
    'bkxldmVsUhF2ZXJpZmljYXRpb25MZXZlbA==');

@$core.Deprecated('Use introductionDetailsDescriptor instead')
const IntroductionDetails$json = {
  '1': 'IntroductionDetails',
  '2': [
    {'1': 'to', '3': 1, '4': 1, '5': 11, '6': '.model.ContactId', '10': 'to'},
    {'1': 'displayName', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'originalDisplayName', '3': 3, '4': 1, '5': 9, '10': 'originalDisplayName'},
    {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.model.IntroductionDetails.IntroductionStatus', '10': 'status'},
    {'1': 'verificationLevel', '3': 5, '4': 1, '5': 14, '6': '.model.VerificationLevel', '10': 'verificationLevel'},
    {'1': 'constrainedVerificationLevel', '3': 6, '4': 1, '5': 14, '6': '.model.VerificationLevel', '10': 'constrainedVerificationLevel'},
  ],
  '4': [IntroductionDetails_IntroductionStatus$json],
};

@$core.Deprecated('Use introductionDetailsDescriptor instead')
const IntroductionDetails_IntroductionStatus$json = {
  '1': 'IntroductionStatus',
  '2': [
    {'1': 'PENDING', '2': 0},
    {'1': 'ACCEPTED', '2': 1},
  ],
};

/// Descriptor for `IntroductionDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List introductionDetailsDescriptor = $convert.base64Decode(
    'ChNJbnRyb2R1Y3Rpb25EZXRhaWxzEiAKAnRvGAEgASgLMhAubW9kZWwuQ29udGFjdElkUgJ0bx'
    'IgCgtkaXNwbGF5TmFtZRgCIAEoCVILZGlzcGxheU5hbWUSMAoTb3JpZ2luYWxEaXNwbGF5TmFt'
    'ZRgDIAEoCVITb3JpZ2luYWxEaXNwbGF5TmFtZRJFCgZzdGF0dXMYBCABKA4yLS5tb2RlbC5Jbn'
    'Ryb2R1Y3Rpb25EZXRhaWxzLkludHJvZHVjdGlvblN0YXR1c1IGc3RhdHVzEkYKEXZlcmlmaWNh'
    'dGlvbkxldmVsGAUgASgOMhgubW9kZWwuVmVyaWZpY2F0aW9uTGV2ZWxSEXZlcmlmaWNhdGlvbk'
    'xldmVsElwKHGNvbnN0cmFpbmVkVmVyaWZpY2F0aW9uTGV2ZWwYBiABKA4yGC5tb2RlbC5WZXJp'
    'ZmljYXRpb25MZXZlbFIcY29uc3RyYWluZWRWZXJpZmljYXRpb25MZXZlbCIvChJJbnRyb2R1Y3'
    'Rpb25TdGF0dXMSCwoHUEVORElORxAAEgwKCEFDQ0VQVEVEEAE=');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    {'1': 'replyToSenderId', '3': 2, '4': 1, '5': 12, '10': 'replyToSenderId'},
    {'1': 'replyToId', '3': 3, '4': 1, '5': 12, '10': 'replyToId'},
    {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
    {'1': 'attachments', '3': 5, '4': 3, '5': 11, '6': '.model.Message.AttachmentsEntry', '10': 'attachments'},
    {'1': 'disappearAfterSeconds', '3': 6, '4': 1, '5': 5, '10': 'disappearAfterSeconds'},
    {'1': 'introduction', '3': 7, '4': 1, '5': 11, '6': '.model.Introduction', '10': 'introduction'},
  ],
  '3': [Message_AttachmentsEntry$json],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_AttachmentsEntry$json = {
  '1': 'AttachmentsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.model.AttachmentWithThumbnail', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEg4KAmlkGAEgASgMUgJpZBIoCg9yZXBseVRvU2VuZGVySWQYAiABKAxSD3JlcG'
    'x5VG9TZW5kZXJJZBIcCglyZXBseVRvSWQYAyABKAxSCXJlcGx5VG9JZBISCgR0ZXh0GAQgASgJ'
    'UgR0ZXh0EkEKC2F0dGFjaG1lbnRzGAUgAygLMh8ubW9kZWwuTWVzc2FnZS5BdHRhY2htZW50c0'
    'VudHJ5UgthdHRhY2htZW50cxI0ChVkaXNhcHBlYXJBZnRlclNlY29uZHMYBiABKAVSFWRpc2Fw'
    'cGVhckFmdGVyU2Vjb25kcxI3CgxpbnRyb2R1Y3Rpb24YByABKAsyEy5tb2RlbC5JbnRyb2R1Y3'
    'Rpb25SDGludHJvZHVjdGlvbhpeChBBdHRhY2htZW50c0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5'
    'EjQKBXZhbHVlGAIgASgLMh4ubW9kZWwuQXR0YWNobWVudFdpdGhUaHVtYm5haWxSBXZhbHVlOg'
    'I4AQ==');

@$core.Deprecated('Use storedMessageDescriptor instead')
const StoredMessage$json = {
  '1': 'StoredMessage',
  '2': [
    {'1': 'contactId', '3': 1, '4': 1, '5': 11, '6': '.model.ContactId', '10': 'contactId'},
    {'1': 'senderId', '3': 2, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'ts', '3': 4, '4': 1, '5': 3, '10': 'ts'},
    {'1': 'replyToSenderId', '3': 5, '4': 1, '5': 9, '10': 'replyToSenderId'},
    {'1': 'replyToId', '3': 6, '4': 1, '5': 9, '10': 'replyToId'},
    {'1': 'text', '3': 7, '4': 1, '5': 9, '10': 'text'},
    {'1': 'disappearAfterSeconds', '3': 8, '4': 1, '5': 5, '10': 'disappearAfterSeconds'},
    {'1': 'attachments', '3': 9, '4': 3, '5': 11, '6': '.model.StoredMessage.AttachmentsEntry', '10': 'attachments'},
    {'1': 'thumbnails', '3': 15, '4': 3, '5': 11, '6': '.model.StoredMessage.ThumbnailsEntry', '10': 'thumbnails'},
    {'1': 'direction', '3': 10, '4': 1, '5': 14, '6': '.model.MessageDirection', '10': 'direction'},
    {'1': 'reactions', '3': 11, '4': 3, '5': 11, '6': '.model.StoredMessage.ReactionsEntry', '10': 'reactions'},
    {'1': 'status', '3': 12, '4': 1, '5': 14, '6': '.model.StoredMessage.DeliveryStatus', '10': 'status'},
    {'1': 'firstViewedAt', '3': 13, '4': 1, '5': 3, '10': 'firstViewedAt'},
    {'1': 'disappearAt', '3': 14, '4': 1, '5': 3, '10': 'disappearAt'},
    {'1': 'remotelyDeletedAt', '3': 16, '4': 1, '5': 3, '10': 'remotelyDeletedAt'},
    {'1': 'remotelyDeletedBy', '3': 17, '4': 1, '5': 11, '6': '.model.ContactId', '10': 'remotelyDeletedBy'},
    {'1': 'introduction', '3': 18, '4': 1, '5': 11, '6': '.model.IntroductionDetails', '10': 'introduction'},
  ],
  '3': [StoredMessage_AttachmentsEntry$json, StoredMessage_ThumbnailsEntry$json, StoredMessage_ReactionsEntry$json],
  '4': [StoredMessage_DeliveryStatus$json],
};

@$core.Deprecated('Use storedMessageDescriptor instead')
const StoredMessage_AttachmentsEntry$json = {
  '1': 'AttachmentsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.model.StoredAttachment', '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use storedMessageDescriptor instead')
const StoredMessage_ThumbnailsEntry$json = {
  '1': 'ThumbnailsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use storedMessageDescriptor instead')
const StoredMessage_ReactionsEntry$json = {
  '1': 'ReactionsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.model.Reaction', '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use storedMessageDescriptor instead')
const StoredMessage_DeliveryStatus$json = {
  '1': 'DeliveryStatus',
  '2': [
    {'1': 'SENDING', '2': 0},
    {'1': 'PARTIALLY_SENT', '2': 1},
    {'1': 'COMPLETELY_SENT', '2': 2},
    {'1': 'PARTIALLY_FAILED', '2': 3},
    {'1': 'COMPLETELY_FAILED', '2': 4},
  ],
};

/// Descriptor for `StoredMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storedMessageDescriptor = $convert.base64Decode(
    'Cg1TdG9yZWRNZXNzYWdlEi4KCWNvbnRhY3RJZBgBIAEoCzIQLm1vZGVsLkNvbnRhY3RJZFIJY2'
    '9udGFjdElkEhoKCHNlbmRlcklkGAIgASgJUghzZW5kZXJJZBIOCgJpZBgDIAEoCVICaWQSDgoC'
    'dHMYBCABKANSAnRzEigKD3JlcGx5VG9TZW5kZXJJZBgFIAEoCVIPcmVwbHlUb1NlbmRlcklkEh'
    'wKCXJlcGx5VG9JZBgGIAEoCVIJcmVwbHlUb0lkEhIKBHRleHQYByABKAlSBHRleHQSNAoVZGlz'
    'YXBwZWFyQWZ0ZXJTZWNvbmRzGAggASgFUhVkaXNhcHBlYXJBZnRlclNlY29uZHMSRwoLYXR0YW'
    'NobWVudHMYCSADKAsyJS5tb2RlbC5TdG9yZWRNZXNzYWdlLkF0dGFjaG1lbnRzRW50cnlSC2F0'
    'dGFjaG1lbnRzEkQKCnRodW1ibmFpbHMYDyADKAsyJC5tb2RlbC5TdG9yZWRNZXNzYWdlLlRodW'
    '1ibmFpbHNFbnRyeVIKdGh1bWJuYWlscxI1CglkaXJlY3Rpb24YCiABKA4yFy5tb2RlbC5NZXNz'
    'YWdlRGlyZWN0aW9uUglkaXJlY3Rpb24SQQoJcmVhY3Rpb25zGAsgAygLMiMubW9kZWwuU3Rvcm'
    'VkTWVzc2FnZS5SZWFjdGlvbnNFbnRyeVIJcmVhY3Rpb25zEjsKBnN0YXR1cxgMIAEoDjIjLm1v'
    'ZGVsLlN0b3JlZE1lc3NhZ2UuRGVsaXZlcnlTdGF0dXNSBnN0YXR1cxIkCg1maXJzdFZpZXdlZE'
    'F0GA0gASgDUg1maXJzdFZpZXdlZEF0EiAKC2Rpc2FwcGVhckF0GA4gASgDUgtkaXNhcHBlYXJB'
    'dBIsChFyZW1vdGVseURlbGV0ZWRBdBgQIAEoA1IRcmVtb3RlbHlEZWxldGVkQXQSPgoRcmVtb3'
    'RlbHlEZWxldGVkQnkYESABKAsyEC5tb2RlbC5Db250YWN0SWRSEXJlbW90ZWx5RGVsZXRlZEJ5'
    'Ej4KDGludHJvZHVjdGlvbhgSIAEoCzIaLm1vZGVsLkludHJvZHVjdGlvbkRldGFpbHNSDGludH'
    'JvZHVjdGlvbhpXChBBdHRhY2htZW50c0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5Ei0KBXZhbHVl'
    'GAIgASgLMhcubW9kZWwuU3RvcmVkQXR0YWNobWVudFIFdmFsdWU6AjgBGj0KD1RodW1ibmFpbH'
    'NFbnRyeRIQCgNrZXkYASABKAVSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGk0KDlJl'
    'YWN0aW9uc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiUKBXZhbHVlGAIgASgLMg8ubW9kZWwuUm'
    'VhY3Rpb25SBXZhbHVlOgI4ASJzCg5EZWxpdmVyeVN0YXR1cxILCgdTRU5ESU5HEAASEgoOUEFS'
    'VElBTExZX1NFTlQQARITCg9DT01QTEVURUxZX1NFTlQQAhIUChBQQVJUSUFMTFlfRkFJTEVEEA'
    'MSFQoRQ09NUExFVEVMWV9GQUlMRUQQBA==');

@$core.Deprecated('Use reactionDescriptor instead')
const Reaction$json = {
  '1': 'Reaction',
  '2': [
    {'1': 'reactingToSenderId', '3': 1, '4': 1, '5': 12, '10': 'reactingToSenderId'},
    {'1': 'reactingToMessageId', '3': 2, '4': 1, '5': 12, '10': 'reactingToMessageId'},
    {'1': 'emoticon', '3': 3, '4': 1, '5': 9, '10': 'emoticon'},
  ],
};

/// Descriptor for `Reaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reactionDescriptor = $convert.base64Decode(
    'CghSZWFjdGlvbhIuChJyZWFjdGluZ1RvU2VuZGVySWQYASABKAxSEnJlYWN0aW5nVG9TZW5kZX'
    'JJZBIwChNyZWFjdGluZ1RvTWVzc2FnZUlkGAIgASgMUhNyZWFjdGluZ1RvTWVzc2FnZUlkEhoK'
    'CGVtb3RpY29uGAMgASgJUghlbW90aWNvbg==');

@$core.Deprecated('Use disappearSettingsDescriptor instead')
const DisappearSettings$json = {
  '1': 'DisappearSettings',
  '2': [
    {'1': 'messagesDisappearAfterSeconds', '3': 1, '4': 1, '5': 5, '10': 'messagesDisappearAfterSeconds'},
  ],
};

/// Descriptor for `DisappearSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disappearSettingsDescriptor = $convert.base64Decode(
    'ChFEaXNhcHBlYXJTZXR0aW5ncxJECh1tZXNzYWdlc0Rpc2FwcGVhckFmdGVyU2Vjb25kcxgBIA'
    'EoBVIdbWVzc2FnZXNEaXNhcHBlYXJBZnRlclNlY29uZHM=');

@$core.Deprecated('Use helloDescriptor instead')
const Hello$json = {
  '1': 'Hello',
  '2': [
    {'1': 'final', '3': 2, '4': 1, '5': 8, '10': 'final'},
  ],
};

/// Descriptor for `Hello`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List helloDescriptor = $convert.base64Decode(
    'CgVIZWxsbxIUCgVmaW5hbBgCIAEoCFIFZmluYWw=');

@$core.Deprecated('Use transferMessageDescriptor instead')
const TransferMessage$json = {
  '1': 'TransferMessage',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 12, '9': 0, '10': 'message'},
    {'1': 'reaction', '3': 2, '4': 1, '5': 12, '9': 0, '10': 'reaction'},
    {'1': 'deleteMessageId', '3': 3, '4': 1, '5': 12, '9': 0, '10': 'deleteMessageId'},
    {'1': 'disappearSettings', '3': 4, '4': 1, '5': 12, '9': 0, '10': 'disappearSettings'},
    {'1': 'hello', '3': 5, '4': 1, '5': 12, '9': 0, '10': 'hello'},
    {'1': 'webRTCSignal', '3': 6, '4': 1, '5': 12, '9': 0, '10': 'webRTCSignal'},
    {'1': 'sent', '3': 10000, '4': 1, '5': 3, '10': 'sent'},
  ],
  '8': [
    {'1': 'content'},
  ],
};

/// Descriptor for `TransferMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferMessageDescriptor = $convert.base64Decode(
    'Cg9UcmFuc2Zlck1lc3NhZ2USGgoHbWVzc2FnZRgBIAEoDEgAUgdtZXNzYWdlEhwKCHJlYWN0aW'
    '9uGAIgASgMSABSCHJlYWN0aW9uEioKD2RlbGV0ZU1lc3NhZ2VJZBgDIAEoDEgAUg9kZWxldGVN'
    'ZXNzYWdlSWQSLgoRZGlzYXBwZWFyU2V0dGluZ3MYBCABKAxIAFIRZGlzYXBwZWFyU2V0dGluZ3'
    'MSFgoFaGVsbG8YBSABKAxIAFIFaGVsbG8SJAoMd2ViUlRDU2lnbmFsGAYgASgMSABSDHdlYlJU'
    'Q1NpZ25hbBITCgRzZW50GJBOIAEoA1IEc2VudEIJCgdjb250ZW50');

@$core.Deprecated('Use outboundMessageDescriptor instead')
const OutboundMessage$json = {
  '1': 'OutboundMessage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'senderId', '3': 2, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'recipientId', '3': 3, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'sent', '3': 4, '4': 1, '5': 3, '10': 'sent'},
    {'1': 'subDeliveryStatuses', '3': 5, '4': 3, '5': 11, '6': '.model.OutboundMessage.SubDeliveryStatusesEntry', '10': 'subDeliveryStatuses'},
    {'1': 'messageId', '3': 31, '4': 1, '5': 9, '9': 0, '10': 'messageId'},
    {'1': 'reaction', '3': 32, '4': 1, '5': 12, '9': 0, '10': 'reaction'},
    {'1': 'deleteMessageId', '3': 33, '4': 1, '5': 12, '9': 0, '10': 'deleteMessageId'},
    {'1': 'disappearSettings', '3': 34, '4': 1, '5': 12, '9': 0, '10': 'disappearSettings'},
    {'1': 'hello', '3': 35, '4': 1, '5': 12, '9': 0, '10': 'hello'},
  ],
  '3': [OutboundMessage_SubDeliveryStatusesEntry$json],
  '4': [OutboundMessage_SubDeliveryStatus$json],
  '8': [
    {'1': 'content'},
  ],
};

@$core.Deprecated('Use outboundMessageDescriptor instead')
const OutboundMessage_SubDeliveryStatusesEntry$json = {
  '1': 'SubDeliveryStatusesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 14, '6': '.model.OutboundMessage.SubDeliveryStatus', '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use outboundMessageDescriptor instead')
const OutboundMessage_SubDeliveryStatus$json = {
  '1': 'SubDeliveryStatus',
  '2': [
    {'1': 'SENDING', '2': 0},
    {'1': 'SENT', '2': 1},
  ],
};

/// Descriptor for `OutboundMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outboundMessageDescriptor = $convert.base64Decode(
    'Cg9PdXRib3VuZE1lc3NhZ2USDgoCaWQYASABKAlSAmlkEhoKCHNlbmRlcklkGAIgASgJUghzZW'
    '5kZXJJZBIgCgtyZWNpcGllbnRJZBgDIAEoCVILcmVjaXBpZW50SWQSEgoEc2VudBgEIAEoA1IE'
    'c2VudBJhChNzdWJEZWxpdmVyeVN0YXR1c2VzGAUgAygLMi8ubW9kZWwuT3V0Ym91bmRNZXNzYW'
    'dlLlN1YkRlbGl2ZXJ5U3RhdHVzZXNFbnRyeVITc3ViRGVsaXZlcnlTdGF0dXNlcxIeCgltZXNz'
    'YWdlSWQYHyABKAlIAFIJbWVzc2FnZUlkEhwKCHJlYWN0aW9uGCAgASgMSABSCHJlYWN0aW9uEi'
    'oKD2RlbGV0ZU1lc3NhZ2VJZBghIAEoDEgAUg9kZWxldGVNZXNzYWdlSWQSLgoRZGlzYXBwZWFy'
    'U2V0dGluZ3MYIiABKAxIAFIRZGlzYXBwZWFyU2V0dGluZ3MSFgoFaGVsbG8YIyABKAxIAFIFaG'
    'VsbG8acAoYU3ViRGVsaXZlcnlTdGF0dXNlc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5Ej4KBXZh'
    'bHVlGAIgASgOMigubW9kZWwuT3V0Ym91bmRNZXNzYWdlLlN1YkRlbGl2ZXJ5U3RhdHVzUgV2YW'
    'x1ZToCOAEiKgoRU3ViRGVsaXZlcnlTdGF0dXMSCwoHU0VORElORxAAEggKBFNFTlQQAUIJCgdj'
    'b250ZW50');

@$core.Deprecated('Use inboundAttachmentDescriptor instead')
const InboundAttachment$json = {
  '1': 'InboundAttachment',
  '2': [
    {'1': 'senderId', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'messageId', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'ts', '3': 3, '4': 1, '5': 3, '10': 'ts'},
    {'1': 'attachmentId', '3': 4, '4': 1, '5': 5, '10': 'attachmentId'},
    {'1': 'isThumbnail', '3': 5, '4': 1, '5': 8, '10': 'isThumbnail'},
  ],
};

/// Descriptor for `InboundAttachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inboundAttachmentDescriptor = $convert.base64Decode(
    'ChFJbmJvdW5kQXR0YWNobWVudBIaCghzZW5kZXJJZBgBIAEoCVIIc2VuZGVySWQSHAoJbWVzc2'
    'FnZUlkGAIgASgJUgltZXNzYWdlSWQSDgoCdHMYAyABKANSAnRzEiIKDGF0dGFjaG1lbnRJZBgE'
    'IAEoBVIMYXR0YWNobWVudElkEiAKC2lzVGh1bWJuYWlsGAUgASgIUgtpc1RodW1ibmFpbA==');

@$core.Deprecated('Use audioWaveformDescriptor instead')
const AudioWaveform$json = {
  '1': 'AudioWaveform',
  '2': [
    {'1': 'bars', '3': 1, '4': 3, '5': 5, '10': 'bars'},
  ],
};

/// Descriptor for `AudioWaveform`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List audioWaveformDescriptor = $convert.base64Decode(
    'Cg1BdWRpb1dhdmVmb3JtEhIKBGJhcnMYASADKAVSBGJhcnM=');

