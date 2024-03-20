//
//  Generated code. Do not modify.
//  source: protos_shared/vpn.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use serverInfoDescriptor instead')
const ServerInfo$json = {
  '1': 'ServerInfo',
  '2': [
    {'1': 'city', '3': 1, '4': 1, '5': 9, '10': 'city'},
    {'1': 'country', '3': 2, '4': 1, '5': 9, '10': 'country'},
    {'1': 'countryCode', '3': 3, '4': 1, '5': 9, '10': 'countryCode'},
  ],
};

/// Descriptor for `ServerInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverInfoDescriptor = $convert.base64Decode(
    'CgpTZXJ2ZXJJbmZvEhIKBGNpdHkYASABKAlSBGNpdHkSGAoHY291bnRyeRgCIAEoCVIHY291bn'
    'RyeRIgCgtjb3VudHJ5Q29kZRgDIAEoCVILY291bnRyeUNvZGU=');

@$core.Deprecated('Use bandwidthDescriptor instead')
const Bandwidth$json = {
  '1': 'Bandwidth',
  '2': [
    {'1': 'percent', '3': 1, '4': 1, '5': 3, '10': 'percent'},
    {'1': 'remaining', '3': 2, '4': 1, '5': 3, '10': 'remaining'},
    {'1': 'allowed', '3': 3, '4': 1, '5': 3, '10': 'allowed'},
    {'1': 'ttlSeconds', '3': 4, '4': 1, '5': 3, '10': 'ttlSeconds'},
  ],
};

/// Descriptor for `Bandwidth`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bandwidthDescriptor = $convert.base64Decode(
    'CglCYW5kd2lkdGgSGAoHcGVyY2VudBgBIAEoA1IHcGVyY2VudBIcCglyZW1haW5pbmcYAiABKA'
    'NSCXJlbWFpbmluZxIYCgdhbGxvd2VkGAMgASgDUgdhbGxvd2VkEh4KCnR0bFNlY29uZHMYBCAB'
    'KANSCnR0bFNlY29uZHM=');

@$core.Deprecated('Use appDataDescriptor instead')
const AppData$json = {
  '1': 'AppData',
  '2': [
    {'1': 'packageName', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'icon', '3': 3, '4': 1, '5': 12, '10': 'icon'},
    {'1': 'allowedAccess', '3': 4, '4': 1, '5': 8, '10': 'allowedAccess'},
  ],
};

/// Descriptor for `AppData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appDataDescriptor = $convert.base64Decode(
    'CgdBcHBEYXRhEiAKC3BhY2thZ2VOYW1lGAEgASgJUgtwYWNrYWdlTmFtZRISCgRuYW1lGAIgAS'
    'gJUgRuYW1lEhIKBGljb24YAyABKAxSBGljb24SJAoNYWxsb3dlZEFjY2VzcxgEIAEoCFINYWxs'
    'b3dlZEFjY2Vzcw==');

@$core.Deprecated('Use deviceDescriptor instead')
const Device$json = {
  '1': 'Device',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'created', '3': 3, '4': 1, '5': 3, '10': 'created'},
  ],
};

/// Descriptor for `Device`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceDescriptor = $convert.base64Decode(
    'CgZEZXZpY2USDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSGAoHY3JlYXRlZB'
    'gDIAEoA1IHY3JlYXRlZA==');

@$core.Deprecated('Use devicesDescriptor instead')
const Devices$json = {
  '1': 'Devices',
  '2': [
    {'1': 'devices', '3': 1, '4': 3, '5': 11, '6': '.Device', '10': 'devices'},
  ],
};

/// Descriptor for `Devices`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List devicesDescriptor = $convert.base64Decode(
    'CgdEZXZpY2VzEiEKB2RldmljZXMYASADKAsyBy5EZXZpY2VSB2RldmljZXM=');

@$core.Deprecated('Use planDescriptor instead')
const Plan$json = {
  '1': 'Plan',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'bestValue', '3': 3, '4': 1, '5': 8, '10': 'bestValue'},
    {'1': 'usdPrice', '3': 4, '4': 1, '5': 3, '10': 'usdPrice'},
    {'1': 'price', '3': 5, '4': 3, '5': 11, '6': '.Plan.PriceEntry', '10': 'price'},
    {'1': 'expectedMonthlyPrice', '3': 6, '4': 3, '5': 11, '6': '.Plan.ExpectedMonthlyPriceEntry', '10': 'expectedMonthlyPrice'},
    {'1': 'totalCostBilledOneTime', '3': 7, '4': 1, '5': 9, '10': 'totalCostBilledOneTime'},
    {'1': 'oneMonthCost', '3': 8, '4': 1, '5': 9, '10': 'oneMonthCost'},
    {'1': 'totalCost', '3': 9, '4': 1, '5': 9, '10': 'totalCost'},
    {'1': 'formattedBonus', '3': 10, '4': 1, '5': 9, '10': 'formattedBonus'},
    {'1': 'renewalText', '3': 11, '4': 1, '5': 9, '10': 'renewalText'},
  ],
  '3': [Plan_PriceEntry$json, Plan_ExpectedMonthlyPriceEntry$json],
};

@$core.Deprecated('Use planDescriptor instead')
const Plan_PriceEntry$json = {
  '1': 'PriceEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use planDescriptor instead')
const Plan_ExpectedMonthlyPriceEntry$json = {
  '1': 'ExpectedMonthlyPriceEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Plan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List planDescriptor = $convert.base64Decode(
    'CgRQbGFuEg4KAmlkGAEgASgJUgJpZBIgCgtkZXNjcmlwdGlvbhgCIAEoCVILZGVzY3JpcHRpb2'
    '4SHAoJYmVzdFZhbHVlGAMgASgIUgliZXN0VmFsdWUSGgoIdXNkUHJpY2UYBCABKANSCHVzZFBy'
    'aWNlEiYKBXByaWNlGAUgAygLMhAuUGxhbi5QcmljZUVudHJ5UgVwcmljZRJTChRleHBlY3RlZE'
    '1vbnRobHlQcmljZRgGIAMoCzIfLlBsYW4uRXhwZWN0ZWRNb250aGx5UHJpY2VFbnRyeVIUZXhw'
    'ZWN0ZWRNb250aGx5UHJpY2USNgoWdG90YWxDb3N0QmlsbGVkT25lVGltZRgHIAEoCVIWdG90YW'
    'xDb3N0QmlsbGVkT25lVGltZRIiCgxvbmVNb250aENvc3QYCCABKAlSDG9uZU1vbnRoQ29zdBIc'
    'Cgl0b3RhbENvc3QYCSABKAlSCXRvdGFsQ29zdBImCg5mb3JtYXR0ZWRCb251cxgKIAEoCVIOZm'
    '9ybWF0dGVkQm9udXMSIAoLcmVuZXdhbFRleHQYCyABKAlSC3JlbmV3YWxUZXh0GjgKClByaWNl'
    'RW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKANSBXZhbHVlOgI4ARpHChlFeH'
    'BlY3RlZE1vbnRobHlQcmljZUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgD'
    'UgV2YWx1ZToCOAE=');

@$core.Deprecated('Use paymentProvidersDescriptor instead')
const PaymentProviders$json = {
  '1': 'PaymentProviders',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'logoUrls', '3': 2, '4': 3, '5': 9, '10': 'logoUrls'},
  ],
};

/// Descriptor for `PaymentProviders`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentProvidersDescriptor = $convert.base64Decode(
    'ChBQYXltZW50UHJvdmlkZXJzEhIKBG5hbWUYASABKAlSBG5hbWUSGgoIbG9nb1VybHMYAiADKA'
    'lSCGxvZ29Vcmxz');

@$core.Deprecated('Use paymentMethodDescriptor instead')
const PaymentMethod$json = {
  '1': 'PaymentMethod',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 9, '10': 'method'},
    {'1': 'providers', '3': 2, '4': 3, '5': 11, '6': '.PaymentProviders', '10': 'providers'},
  ],
};

/// Descriptor for `PaymentMethod`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentMethodDescriptor = $convert.base64Decode(
    'Cg1QYXltZW50TWV0aG9kEhYKBm1ldGhvZBgBIAEoCVIGbWV0aG9kEi8KCXByb3ZpZGVycxgCIA'
    'MoCzIRLlBheW1lbnRQcm92aWRlcnNSCXByb3ZpZGVycw==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'userId', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '10': 'email'},
    {'1': 'telephone', '3': 3, '4': 1, '5': 9, '10': 'telephone'},
    {'1': 'userStatus', '3': 4, '4': 1, '5': 9, '10': 'userStatus'},
    {'1': 'locale', '3': 5, '4': 1, '5': 9, '10': 'locale'},
    {'1': 'expiration', '3': 6, '4': 1, '5': 3, '10': 'expiration'},
    {'1': 'devices', '3': 7, '4': 3, '5': 11, '6': '.Device', '10': 'devices'},
    {'1': 'code', '3': 8, '4': 1, '5': 9, '10': 'code'},
    {'1': 'expireAt', '3': 9, '4': 1, '5': 3, '10': 'expireAt'},
    {'1': 'referral', '3': 10, '4': 1, '5': 9, '10': 'referral'},
    {'1': 'token', '3': 11, '4': 1, '5': 9, '10': 'token'},
    {'1': 'yinbiEnabled', '3': 12, '4': 1, '5': 8, '10': 'yinbiEnabled'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEhYKBnVzZXJJZBgBIAEoA1IGdXNlcklkEhQKBWVtYWlsGAIgASgJUgVlbWFpbBIcCg'
    'l0ZWxlcGhvbmUYAyABKAlSCXRlbGVwaG9uZRIeCgp1c2VyU3RhdHVzGAQgASgJUgp1c2VyU3Rh'
    'dHVzEhYKBmxvY2FsZRgFIAEoCVIGbG9jYWxlEh4KCmV4cGlyYXRpb24YBiABKANSCmV4cGlyYX'
    'Rpb24SIQoHZGV2aWNlcxgHIAMoCzIHLkRldmljZVIHZGV2aWNlcxISCgRjb2RlGAggASgJUgRj'
    'b2RlEhoKCGV4cGlyZUF0GAkgASgDUghleHBpcmVBdBIaCghyZWZlcnJhbBgKIAEoCVIIcmVmZX'
    'JyYWwSFAoFdG9rZW4YCyABKAlSBXRva2VuEiIKDHlpbmJpRW5hYmxlZBgMIAEoCFIMeWluYmlF'
    'bmFibGVk');

@$core.Deprecated('Use baseResponseDescriptor instead')
const BaseResponse$json = {
  '1': 'BaseResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'errorId', '3': 3, '4': 1, '5': 9, '10': 'errorId'},
  ],
};

/// Descriptor for `BaseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baseResponseDescriptor = $convert.base64Decode(
    'CgxCYXNlUmVzcG9uc2USFgoGc3RhdHVzGAEgASgJUgZzdGF0dXMSFAoFZXJyb3IYAiABKAlSBW'
    'Vycm9yEhgKB2Vycm9ySWQYAyABKAlSB2Vycm9ySWQ=');

@$core.Deprecated('Use paymentMethodsResponseDescriptor instead')
const PaymentMethodsResponse$json = {
  '1': 'PaymentMethodsResponse',
  '2': [
    {'1': 'providers', '3': 1, '4': 3, '5': 11, '6': '.PaymentMethodsResponse.ProvidersEntry', '10': 'providers'},
  ],
  '3': [PaymentMethodsResponse_ProvidersEntry$json],
};

@$core.Deprecated('Use paymentMethodsResponseDescriptor instead')
const PaymentMethodsResponse_ProvidersEntry$json = {
  '1': 'ProvidersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.ListValue', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `PaymentMethodsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentMethodsResponseDescriptor = $convert.base64Decode(
    'ChZQYXltZW50TWV0aG9kc1Jlc3BvbnNlEkQKCXByb3ZpZGVycxgBIAMoCzImLlBheW1lbnRNZX'
    'Rob2RzUmVzcG9uc2UuUHJvdmlkZXJzRW50cnlSCXByb3ZpZGVycxpYCg5Qcm92aWRlcnNFbnRy'
    'eRIQCgNrZXkYASABKAlSA2tleRIwCgV2YWx1ZRgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5MaX'
    'N0VmFsdWVSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use paymentRedirectRequestDescriptor instead')
const PaymentRedirectRequest$json = {
  '1': 'PaymentRedirectRequest',
  '2': [
    {'1': 'plan', '3': 1, '4': 1, '5': 9, '10': 'plan'},
    {'1': 'provider', '3': 2, '4': 1, '5': 9, '10': 'provider'},
    {'1': 'currency', '3': 3, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '10': 'email'},
    {'1': 'deviceName', '3': 5, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'countryCode', '3': 6, '4': 1, '5': 9, '10': 'countryCode'},
  ],
};

/// Descriptor for `PaymentRedirectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentRedirectRequestDescriptor = $convert.base64Decode(
    'ChZQYXltZW50UmVkaXJlY3RSZXF1ZXN0EhIKBHBsYW4YASABKAlSBHBsYW4SGgoIcHJvdmlkZX'
    'IYAiABKAlSCHByb3ZpZGVyEhoKCGN1cnJlbmN5GAMgASgJUghjdXJyZW5jeRIUCgVlbWFpbBgE'
    'IAEoCVIFZW1haWwSHgoKZGV2aWNlTmFtZRgFIAEoCVIKZGV2aWNlTmFtZRIgCgtjb3VudHJ5Q2'
    '9kZRgGIAEoCVILY291bnRyeUNvZGU=');

