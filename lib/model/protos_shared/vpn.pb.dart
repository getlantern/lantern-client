///
//  Generated code. Do not modify.
//  source: protos_shared/vpn.proto
//
// @dart = 2.7
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class ServerInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ServerInfo', createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'city')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'country')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'countryCode', protoName: 'countryCode')
    ..hasRequiredFields = false
  ;

  ServerInfo._() : super();
  factory ServerInfo({
    $core.String city,
    $core.String country,
    $core.String countryCode,
  }) {
    final _result = create();
    if (city != null) {
      _result.city = city;
    }
    if (country != null) {
      _result.country = country;
    }
    if (countryCode != null) {
      _result.countryCode = countryCode;
    }
    return _result;
  }
  factory ServerInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ServerInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ServerInfo clone() => ServerInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ServerInfo copyWith(void Function(ServerInfo) updates) => super.copyWith((message) => updates(message as ServerInfo)) as ServerInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ServerInfo create() => ServerInfo._();
  ServerInfo createEmptyInstance() => create();
  static $pb.PbList<ServerInfo> createRepeated() => $pb.PbList<ServerInfo>();
  @$core.pragma('dart2js:noInline')
  static ServerInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerInfo>(create);
  static ServerInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get city => $_getSZ(0);
  @$pb.TagNumber(1)
  set city($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCity() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get country => $_getSZ(1);
  @$pb.TagNumber(2)
  set country($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCountry() => $_has(1);
  @$pb.TagNumber(2)
  void clearCountry() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get countryCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set countryCode($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCountryCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCountryCode() => clearField(3);
}

class Bandwidth extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Bandwidth', createEmptyInstance: create)
    ..aInt64(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'percent')
    ..aInt64(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'remaining')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'allowed')
    ..aInt64(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ttlSeconds', protoName: 'ttlSeconds')
    ..hasRequiredFields = false
  ;

  Bandwidth._() : super();
  factory Bandwidth({
    $fixnum.Int64 percent,
    $fixnum.Int64 remaining,
    $fixnum.Int64 allowed,
    $fixnum.Int64 ttlSeconds,
  }) {
    final _result = create();
    if (percent != null) {
      _result.percent = percent;
    }
    if (remaining != null) {
      _result.remaining = remaining;
    }
    if (allowed != null) {
      _result.allowed = allowed;
    }
    if (ttlSeconds != null) {
      _result.ttlSeconds = ttlSeconds;
    }
    return _result;
  }
  factory Bandwidth.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Bandwidth.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Bandwidth clone() => Bandwidth()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Bandwidth copyWith(void Function(Bandwidth) updates) => super.copyWith((message) => updates(message as Bandwidth)) as Bandwidth; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Bandwidth create() => Bandwidth._();
  Bandwidth createEmptyInstance() => create();
  static $pb.PbList<Bandwidth> createRepeated() => $pb.PbList<Bandwidth>();
  @$core.pragma('dart2js:noInline')
  static Bandwidth getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Bandwidth>(create);
  static Bandwidth _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get percent => $_getI64(0);
  @$pb.TagNumber(1)
  set percent($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPercent() => $_has(0);
  @$pb.TagNumber(1)
  void clearPercent() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get remaining => $_getI64(1);
  @$pb.TagNumber(2)
  set remaining($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemaining() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemaining() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get allowed => $_getI64(2);
  @$pb.TagNumber(3)
  set allowed($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAllowed() => $_has(2);
  @$pb.TagNumber(3)
  void clearAllowed() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get ttlSeconds => $_getI64(3);
  @$pb.TagNumber(4)
  set ttlSeconds($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTtlSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearTtlSeconds() => clearField(4);
}

