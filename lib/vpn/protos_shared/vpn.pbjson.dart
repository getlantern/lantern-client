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
@$core.Deprecated('Use appDataDescriptor instead')
const AppData$json = const {
  '1': 'AppData',
  '2': const [
    const {'1': 'packageName', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'icon', '3': 3, '4': 1, '5': 12, '10': 'icon'},
    const {'1': 'allowedAccess', '3': 4, '4': 1, '5': 8, '10': 'allowedAccess'},
  ],
};

/// Descriptor for `AppData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appDataDescriptor = $convert.base64Decode('CgdBcHBEYXRhEiAKC3BhY2thZ2VOYW1lGAEgASgJUgtwYWNrYWdlTmFtZRISCgRuYW1lGAIgASgJUgRuYW1lEhIKBGljb24YAyABKAxSBGljb24SJAoNYWxsb3dlZEFjY2VzcxgEIAEoCFINYWxsb3dlZEFjY2Vzcw==');
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
@$core.Deprecated('Use planDescriptor instead')
const Plan$json = const {
  '1': 'Plan',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'bestValue', '3': 3, '4': 1, '5': 8, '10': 'bestValue'},
    const {'1': 'usdPrice', '3': 4, '4': 1, '5': 3, '10': 'usdPrice'},
    const {'1': 'price', '3': 5, '4': 3, '5': 11, '6': '.Plan.PriceEntry', '10': 'price'},
    const {'1': 'totalCostBilledOneTime', '3': 6, '4': 1, '5': 9, '10': 'totalCostBilledOneTime'},
    const {'1': 'oneMonthCost', '3': 7, '4': 1, '5': 9, '10': 'oneMonthCost'},
    const {'1': 'totalCost', '3': 8, '4': 1, '5': 9, '10': 'totalCost'},
    const {'1': 'formattedBonus', '3': 9, '4': 1, '5': 9, '10': 'formattedBonus'},
  ],
  '3': const [Plan_PriceEntry$json],
};

@$core.Deprecated('Use planDescriptor instead')
const Plan_PriceEntry$json = const {
  '1': 'PriceEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `Plan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List planDescriptor = $convert.base64Decode('CgRQbGFuEg4KAmlkGAEgASgJUgJpZBIgCgtkZXNjcmlwdGlvbhgCIAEoCVILZGVzY3JpcHRpb24SHAoJYmVzdFZhbHVlGAMgASgIUgliZXN0VmFsdWUSGgoIdXNkUHJpY2UYBCABKANSCHVzZFByaWNlEiYKBXByaWNlGAUgAygLMhAuUGxhbi5QcmljZUVudHJ5UgVwcmljZRI2ChZ0b3RhbENvc3RCaWxsZWRPbmVUaW1lGAYgASgJUhZ0b3RhbENvc3RCaWxsZWRPbmVUaW1lEiIKDG9uZU1vbnRoQ29zdBgHIAEoCVIMb25lTW9udGhDb3N0EhwKCXRvdGFsQ29zdBgIIAEoCVIJdG90YWxDb3N0EiYKDmZvcm1hdHRlZEJvbnVzGAkgASgJUg5mb3JtYXR0ZWRCb251cxo4CgpQcmljZUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgDUgV2YWx1ZToCOAE=');
@$core.Deprecated('Use plansDescriptor instead')
const Plans$json = const {
  '1': 'Plans',
  '2': const [
    const {'1': 'plans', '3': 1, '4': 3, '5': 11, '6': '.Plan', '10': 'plans'},
  ],
};

/// Descriptor for `Plans`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List plansDescriptor = $convert.base64Decode('CgVQbGFucxIbCgVwbGFucxgBIAMoCzIFLlBsYW5SBXBsYW5z');
@$core.Deprecated('Use providersDescriptor instead')
const Providers$json = const {
  '1': 'Providers',
  '2': const [
    const {'1': 'providers', '3': 1, '4': 3, '5': 9, '10': 'providers'},
  ],
};

/// Descriptor for `Providers`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List providersDescriptor = $convert.base64Decode('CglQcm92aWRlcnMSHAoJcHJvdmlkZXJzGAEgAygJUglwcm92aWRlcnM=');
