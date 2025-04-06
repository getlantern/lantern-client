//
//  Generated code. Do not modify.
//  source: protos_shared/vpn.proto
//
// @dart = 3.3

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
    {'1': 'mibUsed', '3': 2, '4': 1, '5': 3, '10': 'mibUsed'},
    {'1': 'mibAllowed', '3': 3, '4': 1, '5': 3, '10': 'mibAllowed'},
    {'1': 'ttlSeconds', '3': 4, '4': 1, '5': 3, '10': 'ttlSeconds'},
  ],
};

/// Descriptor for `Bandwidth`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bandwidthDescriptor = $convert.base64Decode(
    'CglCYW5kd2lkdGgSGAoHcGVyY2VudBgBIAEoA1IHcGVyY2VudBIYCgdtaWJVc2VkGAIgASgDUg'
    'dtaWJVc2VkEh4KCm1pYkFsbG93ZWQYAyABKANSCm1pYkFsbG93ZWQSHgoKdHRsU2Vjb25kcxgE'
    'IAEoA1IKdHRsU2Vjb25kcw==');

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

@$core.Deprecated('Use appsDataDescriptor instead')
const AppsData$json = {
  '1': 'AppsData',
  '2': [
    {'1': 'appsList', '3': 1, '4': 3, '5': 11, '6': '.AppData', '10': 'appsList'},
  ],
};

/// Descriptor for `AppsData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appsDataDescriptor = $convert.base64Decode(
    'CghBcHBzRGF0YRIkCghhcHBzTGlzdBgBIAMoCzIILkFwcERhdGFSCGFwcHNMaXN0');

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

@$core.Deprecated('Use plansDescriptor instead')
const Plans$json = {
  '1': 'Plans',
  '2': [
    {'1': 'plan', '3': 1, '4': 3, '5': 11, '6': '.Plan', '10': 'plan'},
  ],
};

/// Descriptor for `Plans`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List plansDescriptor = $convert.base64Decode(
    'CgVQbGFucxIZCgRwbGFuGAEgAygLMgUuUGxhblIEcGxhbg==');

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
    {'1': 'renewalBonusExpected', '3': 13, '4': 3, '5': 11, '6': '.Plan.RenewalBonusExpectedEntry', '10': 'renewalBonusExpected'},
  ],
  '3': [Plan_PriceEntry$json, Plan_ExpectedMonthlyPriceEntry$json, Plan_RenewalBonusExpectedEntry$json],
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

@$core.Deprecated('Use planDescriptor instead')
const Plan_RenewalBonusExpectedEntry$json = {
  '1': 'RenewalBonusExpectedEntry',
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
    '9ybWF0dGVkQm9udXMSIAoLcmVuZXdhbFRleHQYCyABKAlSC3JlbmV3YWxUZXh0ElMKFHJlbmV3'
    'YWxCb251c0V4cGVjdGVkGA0gAygLMh8uUGxhbi5SZW5ld2FsQm9udXNFeHBlY3RlZEVudHJ5Uh'
    'RyZW5ld2FsQm9udXNFeHBlY3RlZBo4CgpQcmljZUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQK'
    'BXZhbHVlGAIgASgDUgV2YWx1ZToCOAEaRwoZRXhwZWN0ZWRNb250aGx5UHJpY2VFbnRyeRIQCg'
    'NrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoA1IFdmFsdWU6AjgBGkcKGVJlbmV3YWxCb251'
    'c0V4cGVjdGVkRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKANSBXZhbHVlOg'
    'I4AQ==');

@$core.Deprecated('Use paymentProvidersDescriptor instead')
const PaymentProviders$json = {
  '1': 'PaymentProviders',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'logoUrls', '3': 3, '4': 3, '5': 9, '10': 'logoUrls'},
    {'1': 'data', '3': 4, '4': 3, '5': 11, '6': '.PaymentProviders.DataEntry', '10': 'data'},
  ],
  '3': [PaymentProviders_DataEntry$json],
};

@$core.Deprecated('Use paymentProvidersDescriptor instead')
const PaymentProviders_DataEntry$json = {
  '1': 'DataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `PaymentProviders`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentProvidersDescriptor = $convert.base64Decode(
    'ChBQYXltZW50UHJvdmlkZXJzEhIKBG5hbWUYASABKAlSBG5hbWUSGgoIbG9nb1VybHMYAyADKA'
    'lSCGxvZ29VcmxzEi8KBGRhdGEYBCADKAsyGy5QYXltZW50UHJvdmlkZXJzLkRhdGFFbnRyeVIE'
    'ZGF0YRo3CglEYXRhRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbH'
    'VlOgI4AQ==');

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
    {'1': 'userLevel', '3': 5, '4': 1, '5': 9, '10': 'userLevel'},
    {'1': 'locale', '3': 6, '4': 1, '5': 9, '10': 'locale'},
    {'1': 'expiration', '3': 7, '4': 1, '5': 3, '10': 'expiration'},
    {'1': 'devices', '3': 8, '4': 3, '5': 11, '6': '.Device', '10': 'devices'},
    {'1': 'code', '3': 9, '4': 1, '5': 9, '10': 'code'},
    {'1': 'expireAt', '3': 10, '4': 1, '5': 3, '10': 'expireAt'},
    {'1': 'referral', '3': 11, '4': 1, '5': 9, '10': 'referral'},
    {'1': 'token', '3': 12, '4': 1, '5': 9, '10': 'token'},
    {'1': 'yinbiEnabled', '3': 13, '4': 1, '5': 8, '10': 'yinbiEnabled'},
    {'1': 'inviters', '3': 14, '4': 3, '5': 9, '10': 'inviters'},
    {'1': 'invitees', '3': 15, '4': 3, '5': 9, '10': 'invitees'},
    {'1': 'purchases', '3': 16, '4': 3, '5': 11, '6': '.Purchase', '10': 'purchases'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEhYKBnVzZXJJZBgBIAEoA1IGdXNlcklkEhQKBWVtYWlsGAIgASgJUgVlbWFpbBIcCg'
    'l0ZWxlcGhvbmUYAyABKAlSCXRlbGVwaG9uZRIeCgp1c2VyU3RhdHVzGAQgASgJUgp1c2VyU3Rh'
    'dHVzEhwKCXVzZXJMZXZlbBgFIAEoCVIJdXNlckxldmVsEhYKBmxvY2FsZRgGIAEoCVIGbG9jYW'
    'xlEh4KCmV4cGlyYXRpb24YByABKANSCmV4cGlyYXRpb24SIQoHZGV2aWNlcxgIIAMoCzIHLkRl'
    'dmljZVIHZGV2aWNlcxISCgRjb2RlGAkgASgJUgRjb2RlEhoKCGV4cGlyZUF0GAogASgDUghleH'
    'BpcmVBdBIaCghyZWZlcnJhbBgLIAEoCVIIcmVmZXJyYWwSFAoFdG9rZW4YDCABKAlSBXRva2Vu'
    'EiIKDHlpbmJpRW5hYmxlZBgNIAEoCFIMeWluYmlFbmFibGVkEhoKCGludml0ZXJzGA4gAygJUg'
    'hpbnZpdGVycxIaCghpbnZpdGVlcxgPIAMoCVIIaW52aXRlZXMSJwoJcHVyY2hhc2VzGBAgAygL'
    'MgkuUHVyY2hhc2VSCXB1cmNoYXNlcw==');

@$core.Deprecated('Use purchaseDescriptor instead')
const Purchase$json = {
  '1': 'Purchase',
  '2': [
    {'1': 'plan', '3': 1, '4': 1, '5': 9, '10': 'plan'},
  ],
};

/// Descriptor for `Purchase`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purchaseDescriptor = $convert.base64Decode(
    'CghQdXJjaGFzZRISCgRwbGFuGAEgASgJUgRwbGFu');

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
    {'1': 'locale', '3': 7, '4': 1, '5': 9, '10': 'locale'},
  ],
};

/// Descriptor for `PaymentRedirectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentRedirectRequestDescriptor = $convert.base64Decode(
    'ChZQYXltZW50UmVkaXJlY3RSZXF1ZXN0EhIKBHBsYW4YASABKAlSBHBsYW4SGgoIcHJvdmlkZX'
    'IYAiABKAlSCHByb3ZpZGVyEhoKCGN1cnJlbmN5GAMgASgJUghjdXJyZW5jeRIUCgVlbWFpbBgE'
    'IAEoCVIFZW1haWwSHgoKZGV2aWNlTmFtZRgFIAEoCVIKZGV2aWNlTmFtZRIgCgtjb3VudHJ5Q2'
    '9kZRgGIAEoCVILY291bnRyeUNvZGUSFgoGbG9jYWxlGAcgASgJUgZsb2NhbGU=');

@$core.Deprecated('Use redeemResellerCodeRequestDescriptor instead')
const RedeemResellerCodeRequest$json = {
  '1': 'RedeemResellerCodeRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
    {'1': 'resellerCode', '3': 2, '4': 1, '5': 9, '10': 'resellerCode'},
    {'1': 'deviceName', '3': 3, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'currency', '3': 4, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'idempotencyKey', '3': 5, '4': 1, '5': 9, '10': 'idempotencyKey'},
    {'1': 'provider', '3': 6, '4': 1, '5': 9, '10': 'provider'},
  ],
};

/// Descriptor for `RedeemResellerCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List redeemResellerCodeRequestDescriptor = $convert.base64Decode(
    'ChlSZWRlZW1SZXNlbGxlckNvZGVSZXF1ZXN0EhQKBWVtYWlsGAEgASgJUgVlbWFpbBIiCgxyZX'
    'NlbGxlckNvZGUYAiABKAlSDHJlc2VsbGVyQ29kZRIeCgpkZXZpY2VOYW1lGAMgASgJUgpkZXZp'
    'Y2VOYW1lEhoKCGN1cnJlbmN5GAQgASgJUghjdXJyZW5jeRImCg5pZGVtcG90ZW5jeUtleRgFIA'
    'EoCVIOaWRlbXBvdGVuY3lLZXkSGgoIcHJvdmlkZXIYBiABKAlSCHByb3ZpZGVy');

@$core.Deprecated('Use iconDescriptor instead')
const Icon$json = {
  '1': 'Icon',
  '2': [
    {'1': 'icons', '3': 1, '4': 3, '5': 9, '10': 'icons'},
  ],
};

/// Descriptor for `Icon`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iconDescriptor = $convert.base64Decode(
    'CgRJY29uEhQKBWljb25zGAEgAygJUgVpY29ucw==');

@$core.Deprecated('Use paymentMethodsResponseDescriptor instead')
const PaymentMethodsResponse$json = {
  '1': 'PaymentMethodsResponse',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 11, '6': '.BaseResponse', '10': 'base'},
    {'1': 'providers', '3': 2, '4': 3, '5': 11, '6': '.PaymentMethodsResponse.ProvidersEntry', '10': 'providers'},
    {'1': 'plans', '3': 3, '4': 3, '5': 11, '6': '.Plan', '10': 'plans'},
    {'1': 'icons', '3': 4, '4': 3, '5': 11, '6': '.PaymentMethodsResponse.IconsEntry', '10': 'icons'},
  ],
  '3': [PaymentMethodsResponse_ProvidersEntry$json, PaymentMethodsResponse_IconsEntry$json],
};

@$core.Deprecated('Use paymentMethodsResponseDescriptor instead')
const PaymentMethodsResponse_ProvidersEntry$json = {
  '1': 'ProvidersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.PaymentMethodsList', '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use paymentMethodsResponseDescriptor instead')
const PaymentMethodsResponse_IconsEntry$json = {
  '1': 'IconsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.Icon', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `PaymentMethodsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentMethodsResponseDescriptor = $convert.base64Decode(
    'ChZQYXltZW50TWV0aG9kc1Jlc3BvbnNlEiEKBGJhc2UYASABKAsyDS5CYXNlUmVzcG9uc2VSBG'
    'Jhc2USRAoJcHJvdmlkZXJzGAIgAygLMiYuUGF5bWVudE1ldGhvZHNSZXNwb25zZS5Qcm92aWRl'
    'cnNFbnRyeVIJcHJvdmlkZXJzEhsKBXBsYW5zGAMgAygLMgUuUGxhblIFcGxhbnMSOAoFaWNvbn'
    'MYBCADKAsyIi5QYXltZW50TWV0aG9kc1Jlc3BvbnNlLkljb25zRW50cnlSBWljb25zGlEKDlBy'
    'b3ZpZGVyc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EikKBXZhbHVlGAIgASgLMhMuUGF5bWVudE'
    '1ldGhvZHNMaXN0UgV2YWx1ZToCOAEaPwoKSWNvbnNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIb'
    'CgV2YWx1ZRgCIAEoCzIFLkljb25SBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use paymentMethodsListDescriptor instead')
const PaymentMethodsList$json = {
  '1': 'PaymentMethodsList',
  '2': [
    {'1': 'methods', '3': 1, '4': 3, '5': 11, '6': '.PaymentMethod', '10': 'methods'},
  ],
};

/// Descriptor for `PaymentMethodsList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentMethodsListDescriptor = $convert.base64Decode(
    'ChJQYXltZW50TWV0aG9kc0xpc3QSKAoHbWV0aG9kcxgBIAMoCzIOLlBheW1lbnRNZXRob2RSB2'
    '1ldGhvZHM=');

@$core.Deprecated('Use plansResponseDescriptor instead')
const PlansResponse$json = {
  '1': 'PlansResponse',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 11, '6': '.BaseResponse', '10': 'base'},
    {'1': 'plans', '3': 2, '4': 3, '5': 11, '6': '.Plan', '10': 'plans'},
  ],
};

/// Descriptor for `PlansResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List plansResponseDescriptor = $convert.base64Decode(
    'Cg1QbGFuc1Jlc3BvbnNlEiEKBGJhc2UYASABKAsyDS5CYXNlUmVzcG9uc2VSBGJhc2USGwoFcG'
    'xhbnMYAiADKAsyBS5QbGFuUgVwbGFucw==');

@$core.Deprecated('Use paymentRedirectResponseDescriptor instead')
const PaymentRedirectResponse$json = {
  '1': 'PaymentRedirectResponse',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 11, '6': '.BaseResponse', '10': 'base'},
    {'1': 'redirect', '3': 2, '4': 1, '5': 9, '10': 'redirect'},
  ],
};

/// Descriptor for `PaymentRedirectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentRedirectResponseDescriptor = $convert.base64Decode(
    'ChdQYXltZW50UmVkaXJlY3RSZXNwb25zZRIhCgRiYXNlGAEgASgLMg0uQmFzZVJlc3BvbnNlUg'
    'RiYXNlEhoKCHJlZGlyZWN0GAIgASgJUghyZWRpcmVjdA==');

@$core.Deprecated('Use userDataResponseDescriptor instead')
const UserDataResponse$json = {
  '1': 'UserDataResponse',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 11, '6': '.BaseResponse', '10': 'base'},
    {'1': 'user', '3': 2, '4': 1, '5': 11, '6': '.User', '10': 'user'},
  ],
};

/// Descriptor for `UserDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDataResponseDescriptor = $convert.base64Decode(
    'ChBVc2VyRGF0YVJlc3BvbnNlEiEKBGJhc2UYASABKAsyDS5CYXNlUmVzcG9uc2VSBGJhc2USGQ'
    'oEdXNlchgCIAEoCzIFLlVzZXJSBHVzZXI=');

@$core.Deprecated('Use linkResponseDescriptor instead')
const LinkResponse$json = {
  '1': 'LinkResponse',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 11, '6': '.BaseResponse', '10': 'base'},
    {'1': 'userID', '3': 2, '4': 1, '5': 3, '10': 'userID'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `LinkResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkResponseDescriptor = $convert.base64Decode(
    'CgxMaW5rUmVzcG9uc2USIQoEYmFzZRgBIAEoCzINLkJhc2VSZXNwb25zZVIEYmFzZRIWCgZ1c2'
    'VySUQYAiABKANSBnVzZXJJRBIUCgV0b2tlbhgDIAEoCVIFdG9rZW4=');

@$core.Deprecated('Use linkCodeResponseDescriptor instead')
const LinkCodeResponse$json = {
  '1': 'LinkCodeResponse',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 11, '6': '.BaseResponse', '10': 'base'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
    {'1': 'expire_at', '3': 3, '4': 1, '5': 3, '10': 'expireAt'},
  ],
};

/// Descriptor for `LinkCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkCodeResponseDescriptor = $convert.base64Decode(
    'ChBMaW5rQ29kZVJlc3BvbnNlEiEKBGJhc2UYASABKAsyDS5CYXNlUmVzcG9uc2VSBGJhc2USEg'
    'oEY29kZRgCIAEoCVIEY29kZRIbCglleHBpcmVfYXQYAyABKANSCGV4cGlyZUF0');

@$core.Deprecated('Use linkCodeRedeemResponseDescriptor instead')
const LinkCodeRedeemResponse$json = {
  '1': 'LinkCodeRedeemResponse',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 11, '6': '.BaseResponse', '10': 'base'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'token', '3': 4, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `LinkCodeRedeemResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkCodeRedeemResponseDescriptor = $convert.base64Decode(
    'ChZMaW5rQ29kZVJlZGVlbVJlc3BvbnNlEiEKBGJhc2UYASABKAsyDS5CYXNlUmVzcG9uc2VSBG'
    'Jhc2USFgoGc3RhdHVzGAIgASgJUgZzdGF0dXMSFwoHdXNlcl9pZBgDIAEoA1IGdXNlcklkEhQK'
    'BXRva2VuGAQgASgJUgV0b2tlbg==');

@$core.Deprecated('Use proPurchaseResponseDescriptor instead')
const ProPurchaseResponse$json = {
  '1': 'ProPurchaseResponse',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 11, '6': '.BaseResponse', '10': 'base'},
    {'1': 'payment_status', '3': 2, '4': 1, '5': 9, '10': 'paymentStatus'},
    {'1': 'plan', '3': 3, '4': 1, '5': 11, '6': '.Plan', '10': 'plan'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `ProPurchaseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proPurchaseResponseDescriptor = $convert.base64Decode(
    'ChNQcm9QdXJjaGFzZVJlc3BvbnNlEiEKBGJhc2UYASABKAsyDS5CYXNlUmVzcG9uc2VSBGJhc2'
    'USJQoOcGF5bWVudF9zdGF0dXMYAiABKAlSDXBheW1lbnRTdGF0dXMSGQoEcGxhbhgDIAEoCzIF'
    'LlBsYW5SBHBsYW4SFgoGc3RhdHVzGAQgASgJUgZzdGF0dXM=');

@$core.Deprecated('Use userRecoveryDescriptor instead')
const UserRecovery$json = {
  '1': 'UserRecovery',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `UserRecovery`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userRecoveryDescriptor = $convert.base64Decode(
    'CgxVc2VyUmVjb3ZlcnkSFgoGc3RhdHVzGAEgASgJUgZzdGF0dXMSFwoHdXNlcl9pZBgCIAEoA1'
    'IGdXNlcklkEhQKBXRva2VuGAMgASgJUgV0b2tlbg==');

@$core.Deprecated('Use okResponseDescriptor instead')
const OkResponse$json = {
  '1': 'OkResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `OkResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List okResponseDescriptor = $convert.base64Decode(
    'CgpPa1Jlc3BvbnNlEhYKBnN0YXR1cxgBIAEoCVIGc3RhdHVz');

@$core.Deprecated('Use restorePurchaseRequestDescriptor instead')
const RestorePurchaseRequest$json = {
  '1': 'RestorePurchaseRequest',
  '2': [
    {'1': 'provider', '3': 1, '4': 1, '5': 9, '10': 'provider'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {'1': 'device_name', '3': 3, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '10': 'email'},
    {'1': 'code', '3': 5, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `RestorePurchaseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restorePurchaseRequestDescriptor = $convert.base64Decode(
    'ChZSZXN0b3JlUHVyY2hhc2VSZXF1ZXN0EhoKCHByb3ZpZGVyGAEgASgJUghwcm92aWRlchIUCg'
    'V0b2tlbhgCIAEoCVIFdG9rZW4SHwoLZGV2aWNlX25hbWUYAyABKAlSCmRldmljZU5hbWUSFAoF'
    'ZW1haWwYBCABKAlSBWVtYWlsEhIKBGNvZGUYBSABKAlSBGNvZGU=');

@$core.Deprecated('Use chatOptionsDescriptor instead')
const ChatOptions$json = {
  '1': 'ChatOptions',
  '2': [
    {'1': 'on_boarding_status', '3': 1, '4': 1, '5': 8, '10': 'onBoardingStatus'},
    {'1': 'accepted_terms_version', '3': 2, '4': 1, '5': 5, '10': 'acceptedTermsVersion'},
  ],
};

/// Descriptor for `ChatOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatOptionsDescriptor = $convert.base64Decode(
    'CgtDaGF0T3B0aW9ucxIsChJvbl9ib2FyZGluZ19zdGF0dXMYASABKAhSEG9uQm9hcmRpbmdTdG'
    'F0dXMSNAoWYWNjZXB0ZWRfdGVybXNfdmVyc2lvbhgCIAEoBVIUYWNjZXB0ZWRUZXJtc1ZlcnNp'
    'b24=');

@$core.Deprecated('Use configOptionsDescriptor instead')
const ConfigOptions$json = {
  '1': 'ConfigOptions',
  '2': [
    {'1': 'development_mode', '3': 1, '4': 1, '5': 8, '10': 'developmentMode'},
    {'1': 'replica_addr', '3': 2, '4': 1, '5': 9, '10': 'replicaAddr'},
    {'1': 'http_proxy_addr', '3': 3, '4': 1, '5': 9, '10': 'httpProxyAddr'},
    {'1': 'socks_proxy_addr', '3': 4, '4': 1, '5': 9, '10': 'socksProxyAddr'},
    {'1': 'auth_enabled', '3': 5, '4': 1, '5': 8, '10': 'authEnabled'},
    {'1': 'chat_enabled', '3': 6, '4': 1, '5': 8, '10': 'chatEnabled'},
    {'1': 'split_tunneling', '3': 7, '4': 1, '5': 8, '10': 'splitTunneling'},
    {'1': 'has_succeeding_proxy', '3': 8, '4': 1, '5': 8, '10': 'hasSucceedingProxy'},
    {'1': 'fetched_global_config', '3': 9, '4': 1, '5': 8, '10': 'fetchedGlobalConfig'},
    {'1': 'fetched_proxies_config', '3': 10, '4': 1, '5': 8, '10': 'fetchedProxiesConfig'},
    {'1': 'plans', '3': 11, '4': 3, '5': 11, '6': '.Plan', '10': 'plans'},
    {'1': 'payment_methods', '3': 12, '4': 1, '5': 11, '6': '.PaymentMethodsList', '10': 'paymentMethods'},
    {'1': 'devices', '3': 13, '4': 1, '5': 11, '6': '.Devices', '10': 'devices'},
    {'1': 'sdk_version', '3': 14, '4': 1, '5': 9, '10': 'sdkVersion'},
    {'1': 'app_version', '3': 15, '4': 1, '5': 9, '10': 'appVersion'},
    {'1': 'device_id', '3': 16, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'expiration_date', '3': 17, '4': 1, '5': 9, '10': 'expirationDate'},
    {'1': 'chat', '3': 18, '4': 1, '5': 11, '6': '.ChatOptions', '10': 'chat'},
    {'1': 'proxy_all', '3': 19, '4': 1, '5': 8, '10': 'proxyAll'},
    {'1': 'country', '3': 20, '4': 1, '5': 9, '10': 'country'},
    {'1': 'is_user_logged_in', '3': 21, '4': 1, '5': 8, '10': 'isUserLoggedIn'},
  ],
};

/// Descriptor for `ConfigOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configOptionsDescriptor = $convert.base64Decode(
    'Cg1Db25maWdPcHRpb25zEikKEGRldmVsb3BtZW50X21vZGUYASABKAhSD2RldmVsb3BtZW50TW'
    '9kZRIhCgxyZXBsaWNhX2FkZHIYAiABKAlSC3JlcGxpY2FBZGRyEiYKD2h0dHBfcHJveHlfYWRk'
    'chgDIAEoCVINaHR0cFByb3h5QWRkchIoChBzb2Nrc19wcm94eV9hZGRyGAQgASgJUg5zb2Nrc1'
    'Byb3h5QWRkchIhCgxhdXRoX2VuYWJsZWQYBSABKAhSC2F1dGhFbmFibGVkEiEKDGNoYXRfZW5h'
    'YmxlZBgGIAEoCFILY2hhdEVuYWJsZWQSJwoPc3BsaXRfdHVubmVsaW5nGAcgASgIUg5zcGxpdF'
    'R1bm5lbGluZxIwChRoYXNfc3VjY2VlZGluZ19wcm94eRgIIAEoCFISaGFzU3VjY2VlZGluZ1By'
    'b3h5EjIKFWZldGNoZWRfZ2xvYmFsX2NvbmZpZxgJIAEoCFITZmV0Y2hlZEdsb2JhbENvbmZpZx'
    'I0ChZmZXRjaGVkX3Byb3hpZXNfY29uZmlnGAogASgIUhRmZXRjaGVkUHJveGllc0NvbmZpZxIb'
    'CgVwbGFucxgLIAMoCzIFLlBsYW5SBXBsYW5zEjwKD3BheW1lbnRfbWV0aG9kcxgMIAEoCzITLl'
    'BheW1lbnRNZXRob2RzTGlzdFIOcGF5bWVudE1ldGhvZHMSIgoHZGV2aWNlcxgNIAEoCzIILkRl'
    'dmljZXNSB2RldmljZXMSHwoLc2RrX3ZlcnNpb24YDiABKAlSCnNka1ZlcnNpb24SHwoLYXBwX3'
    'ZlcnNpb24YDyABKAlSCmFwcFZlcnNpb24SGwoJZGV2aWNlX2lkGBAgASgJUghkZXZpY2VJZBIn'
    'Cg9leHBpcmF0aW9uX2RhdGUYESABKAlSDmV4cGlyYXRpb25EYXRlEiAKBGNoYXQYEiABKAsyDC'
    '5DaGF0T3B0aW9uc1IEY2hhdBIbCglwcm94eV9hbGwYEyABKAhSCHByb3h5QWxsEhgKB2NvdW50'
    'cnkYFCABKAlSB2NvdW50cnkSKQoRaXNfdXNlcl9sb2dnZWRfaW4YFSABKAhSDmlzVXNlckxvZ2'
    'dlZElu');

