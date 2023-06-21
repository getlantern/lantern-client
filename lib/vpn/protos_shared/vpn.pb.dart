///
//  Generated code. Do not modify.
//  source: protos_shared/vpn.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

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
    $core.String? city,
    $core.String? country,
    $core.String? countryCode,
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
  static ServerInfo? _defaultInstance;

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
    $fixnum.Int64? percent,
    $fixnum.Int64? remaining,
    $fixnum.Int64? allowed,
    $fixnum.Int64? ttlSeconds,
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
  static Bandwidth? _defaultInstance;

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

class AppData extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AppData', createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'packageName', protoName: 'packageName')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'icon', $pb.PbFieldType.OY)
    ..aOB(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'allowedAccess', protoName: 'allowedAccess')
    ..hasRequiredFields = false
  ;

  AppData._() : super();
  factory AppData({
    $core.String? packageName,
    $core.String? name,
    $core.List<$core.int>? icon,
    $core.bool? allowedAccess,
  }) {
    final _result = create();
    if (packageName != null) {
      _result.packageName = packageName;
    }
    if (name != null) {
      _result.name = name;
    }
    if (icon != null) {
      _result.icon = icon;
    }
    if (allowedAccess != null) {
      _result.allowedAccess = allowedAccess;
    }
    return _result;
  }
  factory AppData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AppData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AppData clone() => AppData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AppData copyWith(void Function(AppData) updates) => super.copyWith((message) => updates(message as AppData)) as AppData; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AppData create() => AppData._();
  AppData createEmptyInstance() => create();
  static $pb.PbList<AppData> createRepeated() => $pb.PbList<AppData>();
  @$core.pragma('dart2js:noInline')
  static AppData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AppData>(create);
  static AppData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get packageName => $_getSZ(0);
  @$pb.TagNumber(1)
  set packageName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPackageName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackageName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get icon => $_getN(2);
  @$pb.TagNumber(3)
  set icon($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIcon() => $_has(2);
  @$pb.TagNumber(3)
  void clearIcon() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get allowedAccess => $_getBF(3);
  @$pb.TagNumber(4)
  set allowedAccess($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAllowedAccess() => $_has(3);
  @$pb.TagNumber(4)
  void clearAllowedAccess() => clearField(4);
}

class Device extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Device', createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'created')
    ..hasRequiredFields = false
  ;

  Device._() : super();
  factory Device({
    $core.String? id,
    $core.String? name,
    $fixnum.Int64? created,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    if (created != null) {
      _result.created = created;
    }
    return _result;
  }
  factory Device.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Device.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Device clone() => Device()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Device copyWith(void Function(Device) updates) => super.copyWith((message) => updates(message as Device)) as Device; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Device create() => Device._();
  Device createEmptyInstance() => create();
  static $pb.PbList<Device> createRepeated() => $pb.PbList<Device>();
  @$core.pragma('dart2js:noInline')
  static Device getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Device>(create);
  static Device? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get created => $_getI64(2);
  @$pb.TagNumber(3)
  set created($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCreated() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreated() => clearField(3);
}

class Devices extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Devices', createEmptyInstance: create)
    ..pc<Device>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'devices', $pb.PbFieldType.PM, subBuilder: Device.create)
    ..hasRequiredFields = false
  ;

  Devices._() : super();
  factory Devices({
    $core.Iterable<Device>? devices,
  }) {
    final _result = create();
    if (devices != null) {
      _result.devices.addAll(devices);
    }
    return _result;
  }
  factory Devices.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Devices.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Devices clone() => Devices()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Devices copyWith(void Function(Devices) updates) => super.copyWith((message) => updates(message as Devices)) as Devices; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Devices create() => Devices._();
  Devices createEmptyInstance() => create();
  static $pb.PbList<Devices> createRepeated() => $pb.PbList<Devices>();
  @$core.pragma('dart2js:noInline')
  static Devices getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Devices>(create);
  static Devices? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Device> get devices => $_getList(0);
}

class Plan extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Plan', createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'description')
    ..aOB(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'bestValue', protoName: 'bestValue')
    ..aInt64(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'usdPrice', protoName: 'usdPrice')
    ..m<$core.String, $fixnum.Int64>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'price', entryClassName: 'Plan.PriceEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O6)
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'totalCostBilledOneTime', protoName: 'totalCostBilledOneTime')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'oneMonthCost', protoName: 'oneMonthCost')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'totalCost', protoName: 'totalCost')
    ..aOS(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'formattedBonus', protoName: 'formattedBonus')
    ..aOS(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'renewalText', protoName: 'renewalText')
    ..hasRequiredFields = false
  ;

  Plan._() : super();
  factory Plan({
    $core.String? id,
    $core.String? description,
    $core.bool? bestValue,
    $fixnum.Int64? usdPrice,
    $core.Map<$core.String, $fixnum.Int64>? price,
    $core.String? totalCostBilledOneTime,
    $core.String? oneMonthCost,
    $core.String? totalCost,
    $core.String? formattedBonus,
    $core.String? renewalText,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (description != null) {
      _result.description = description;
    }
    if (bestValue != null) {
      _result.bestValue = bestValue;
    }
    if (usdPrice != null) {
      _result.usdPrice = usdPrice;
    }
    if (price != null) {
      _result.price.addAll(price);
    }
    if (totalCostBilledOneTime != null) {
      _result.totalCostBilledOneTime = totalCostBilledOneTime;
    }
    if (oneMonthCost != null) {
      _result.oneMonthCost = oneMonthCost;
    }
    if (totalCost != null) {
      _result.totalCost = totalCost;
    }
    if (formattedBonus != null) {
      _result.formattedBonus = formattedBonus;
    }
    if (renewalText != null) {
      _result.renewalText = renewalText;
    }
    return _result;
  }
  factory Plan.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Plan.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Plan clone() => Plan()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Plan copyWith(void Function(Plan) updates) => super.copyWith((message) => updates(message as Plan)) as Plan; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Plan create() => Plan._();
  Plan createEmptyInstance() => create();
  static $pb.PbList<Plan> createRepeated() => $pb.PbList<Plan>();
  @$core.pragma('dart2js:noInline')
  static Plan getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Plan>(create);
  static Plan? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get bestValue => $_getBF(2);
  @$pb.TagNumber(3)
  set bestValue($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBestValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearBestValue() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get usdPrice => $_getI64(3);
  @$pb.TagNumber(4)
  set usdPrice($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUsdPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsdPrice() => clearField(4);

  @$pb.TagNumber(5)
  $core.Map<$core.String, $fixnum.Int64> get price => $_getMap(4);

  @$pb.TagNumber(6)
  $core.String get totalCostBilledOneTime => $_getSZ(5);
  @$pb.TagNumber(6)
  set totalCostBilledOneTime($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTotalCostBilledOneTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalCostBilledOneTime() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get oneMonthCost => $_getSZ(6);
  @$pb.TagNumber(7)
  set oneMonthCost($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasOneMonthCost() => $_has(6);
  @$pb.TagNumber(7)
  void clearOneMonthCost() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get totalCost => $_getSZ(7);
  @$pb.TagNumber(8)
  set totalCost($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalCost() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalCost() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get formattedBonus => $_getSZ(8);
  @$pb.TagNumber(9)
  set formattedBonus($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasFormattedBonus() => $_has(8);
  @$pb.TagNumber(9)
  void clearFormattedBonus() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get renewalText => $_getSZ(9);
  @$pb.TagNumber(10)
  set renewalText($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasRenewalText() => $_has(9);
  @$pb.TagNumber(10)
  void clearRenewalText() => clearField(10);
}

class PaymentProviders extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PaymentProviders', createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..hasRequiredFields = false
  ;

  PaymentProviders._() : super();
  factory PaymentProviders({
    $core.String? name,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory PaymentProviders.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentProviders.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentProviders clone() => PaymentProviders()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentProviders copyWith(void Function(PaymentProviders) updates) => super.copyWith((message) => updates(message as PaymentProviders)) as PaymentProviders; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PaymentProviders create() => PaymentProviders._();
  PaymentProviders createEmptyInstance() => create();
  static $pb.PbList<PaymentProviders> createRepeated() => $pb.PbList<PaymentProviders>();
  @$core.pragma('dart2js:noInline')
  static PaymentProviders getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentProviders>(create);
  static PaymentProviders? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);
}

class PaymentMethod extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PaymentMethod', createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'method')
    ..pc<PaymentProviders>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'providers', $pb.PbFieldType.PM, subBuilder: PaymentProviders.create)
    ..hasRequiredFields = false
  ;

  PaymentMethod._() : super();
  factory PaymentMethod({
    $core.String? method,
    $core.Iterable<PaymentProviders>? providers,
  }) {
    final _result = create();
    if (method != null) {
      _result.method = method;
    }
    if (providers != null) {
      _result.providers.addAll(providers);
    }
    return _result;
  }
  factory PaymentMethod.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentMethod.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentMethod clone() => PaymentMethod()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentMethod copyWith(void Function(PaymentMethod) updates) => super.copyWith((message) => updates(message as PaymentMethod)) as PaymentMethod; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PaymentMethod create() => PaymentMethod._();
  PaymentMethod createEmptyInstance() => create();
  static $pb.PbList<PaymentMethod> createRepeated() => $pb.PbList<PaymentMethod>();
  @$core.pragma('dart2js:noInline')
  static PaymentMethod getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentMethod>(create);
  static PaymentMethod? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get method => $_getSZ(0);
  @$pb.TagNumber(1)
  set method($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<PaymentProviders> get providers => $_getList(1);
}

