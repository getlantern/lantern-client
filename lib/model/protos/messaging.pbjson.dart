///
//  Generated code. Do not modify.
//  source: protos/messaging.proto
//
// @dart = 2.7
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use timestampDescriptor instead')
const Timestamp$json = const {
  '1': 'Timestamp',
  '2': const [
    const {'1': 'microsecondsSinceEpoch', '3': 1, '4': 1, '5': 4, '10': 'microsecondsSinceEpoch'},
  ],
};

/// Descriptor for `Timestamp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampDescriptor = $convert.base64Decode('CglUaW1lc3RhbXASNgoWbWljcm9zZWNvbmRzU2luY2VFcG9jaBgBIAEoBFIWbWljcm9zZWNvbmRzU2luY2VFcG9jaA==');
@$core.Deprecated('Use contactDescriptor instead')
const Contact$json = const {
  '1': 'Contact',
  '2': const [
    const {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Contact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactDescriptor = $convert.base64Decode('CgdDb250YWN0EhYKBnVzZXJJRBgBIAEoCVIGdXNlcklEEhIKBG5hbWUYAiABKAlSBG5hbWU=');
@$core.Deprecated('Use messageDescriptor instead')
const Message$json = const {
  '1': 'Message',
  '2': const [
    const {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    const {'1': 'receivedAt', '3': 2, '4': 1, '5': 11, '6': '.Timestamp', '10': 'receivedAt'},
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode('CgdNZXNzYWdlEhIKBHRleHQYASABKAlSBHRleHQSKgoKcmVjZWl2ZWRBdBgCIAEoCzIKLlRpbWVzdGFtcFIKcmVjZWl2ZWRBdA==');
@$core.Deprecated('Use conversationDescriptor instead')
const Conversation$json = const {
  '1': 'Conversation',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'userIDs', '3': 2, '4': 3, '5': 9, '10': 'userIDs'},
    const {'1': 'mostRecentMessage', '3': 3, '4': 1, '5': 9, '10': 'mostRecentMessage'},
    const {'1': 'mostRecentMessageTime', '3': 4, '4': 1, '5': 11, '6': '.Timestamp', '10': 'mostRecentMessageTime'},
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode('CgxDb252ZXJzYXRpb24SDgoCaWQYASABKAlSAmlkEhgKB3VzZXJJRHMYAiADKAlSB3VzZXJJRHMSLAoRbW9zdFJlY2VudE1lc3NhZ2UYAyABKAlSEW1vc3RSZWNlbnRNZXNzYWdlEkAKFW1vc3RSZWNlbnRNZXNzYWdlVGltZRgEIAEoCzIKLlRpbWVzdGFtcFIVbW9zdFJlY2VudE1lc3NhZ2VUaW1l');
