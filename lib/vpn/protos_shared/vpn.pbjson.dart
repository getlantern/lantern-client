///
//  Generated code. Do not modify.
//  source: protos_shared/vpn.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use serverInfoDescriptor instead')
const ServerInfo$json = const {
  '1': 'ServerInfo',
  '2': const [
    const {'1': 'city', '3': 1, '4': 1, '5': 9, '10': 'city'},
    const {'1': 'country', '3': 2, '4': 1, '5': 9, '10': 'country'},
    const {'1': 'countryCode', '3': 3, '4': 1, '5': 9, '10': 'countryCode'},
  ],
};

/// Descriptor for `ServerInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverInfoDescriptor = $convert.base64Decode('CgpTZXJ2ZXJJbmZvEhIKBGNpdHkYASABKAlSBGNpdHkSGAoHY291bnRyeRgCIAEoCVIHY291bnRyeRIgCgtjb3VudHJ5Q29kZRgDIAEoCVILY291bnRyeUNvZGU=');
@$core.Deprecated('Use appDataDescriptor instead')
const AppData$json = const {
  '1': 'AppData',
  '2': const [
    const {'1': 'packageName', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
    const {'1': 'iconRes', '3': 2, '4': 1, '5': 3, '10': 'iconRes'},
    const {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `AppData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appDataDescriptor = $convert.base64Decode('CgdBcHBEYXRhEiAKC3BhY2thZ2VOYW1lGAEgASgJUgtwYWNrYWdlTmFtZRIYCgdpY29uUmVzGAIgASgDUgdpY29uUmVzEhIKBG5hbWUYAyABKAlSBG5hbWU=');
@$core.Deprecated('Use excludedAppsDescriptor instead')
const ExcludedApps$json = const {
  '1': 'ExcludedApps',
  '2': const [
    const {'1': 'excludedApps', '3': 1, '4': 3, '5': 11, '6': '.ExcludedApps.ExcludedAppsEntry', '10': 'excludedApps'},
  ],
  '3': const [ExcludedApps_ExcludedAppsEntry$json],
};

@$core.Deprecated('Use excludedAppsDescriptor instead')
const ExcludedApps_ExcludedAppsEntry$json = const {
  '1': 'ExcludedAppsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 8, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `ExcludedApps`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List excludedAppsDescriptor = $convert.base64Decode('CgxFeGNsdWRlZEFwcHMSQwoMZXhjbHVkZWRBcHBzGAEgAygLMh8uRXhjbHVkZWRBcHBzLkV4Y2x1ZGVkQXBwc0VudHJ5UgxleGNsdWRlZEFwcHMaPwoRRXhjbHVkZWRBcHBzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAhSBXZhbHVlOgI4AQ==');
@$core.Deprecated('Use appsDataDescriptor instead')
const AppsData$json = const {
  '1': 'AppsData',
  '2': const [
    const {'1': 'appsList', '3': 1, '4': 3, '5': 11, '6': '.AppData', '10': 'appsList'},
    const {'1': 'excludedApps', '3': 2, '4': 1, '5': 11, '6': '.ExcludedApps', '9': 0, '10': 'excludedApps', '17': true},
  ],
  '8': const [
    const {'1': '_excludedApps'},
  ],
};

/// Descriptor for `AppsData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appsDataDescriptor = $convert.base64Decode('CghBcHBzRGF0YRIkCghhcHBzTGlzdBgBIAMoCzIILkFwcERhdGFSCGFwcHNMaXN0EjYKDGV4Y2x1ZGVkQXBwcxgCIAEoCzINLkV4Y2x1ZGVkQXBwc0gAUgxleGNsdWRlZEFwcHOIAQFCDwoNX2V4Y2x1ZGVkQXBwcw==');
@$core.Deprecated('Use bandwidthDescriptor instead')
const Bandwidth$json = const {
  '1': 'Bandwidth',
  '2': const [
    const {'1': 'percent', '3': 1, '4': 1, '5': 3, '10': 'percent'},
    const {'1': 'remaining', '3': 2, '4': 1, '5': 3, '10': 'remaining'},
    const {'1': 'allowed', '3': 3, '4': 1, '5': 3, '10': 'allowed'},
    const {'1': 'ttlSeconds', '3': 4, '4': 1, '5': 3, '10': 'ttlSeconds'},
  ],
};

/// Descriptor for `Bandwidth`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bandwidthDescriptor = $convert.base64Decode('CglCYW5kd2lkdGgSGAoHcGVyY2VudBgBIAEoA1IHcGVyY2VudBIcCglyZW1haW5pbmcYAiABKANSCXJlbWFpbmluZxIYCgdhbGxvd2VkGAMgASgDUgdhbGxvd2VkEh4KCnR0bFNlY29uZHMYBCABKANSCnR0bFNlY29uZHM=');
@$core.Deprecated('Use deviceDescriptor instead')
const Device$json = const {
  '1': 'Device',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'created', '3': 3, '4': 1, '5': 3, '10': 'created'},
  ],
};

/// Descriptor for `Device`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceDescriptor = $convert.base64Decode('CgZEZXZpY2USDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSGAoHY3JlYXRlZBgDIAEoA1IHY3JlYXRlZA==');
@$core.Deprecated('Use devicesDescriptor instead')
const Devices$json = const {
  '1': 'Devices',
  '2': const [
    const {'1': 'devices', '3': 1, '4': 3, '5': 11, '6': '.Device', '10': 'devices'},
  ],
};

/// Descriptor for `Devices`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List devicesDescriptor = $convert.base64Decode('CgdEZXZpY2VzEiEKB2RldmljZXMYASADKAsyBy5EZXZpY2VSB2RldmljZXM=');
