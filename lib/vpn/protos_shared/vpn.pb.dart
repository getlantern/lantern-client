//
//  Generated code. Do not modify.
//  source: protos_shared/vpn.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class ServerInfo extends $pb.GeneratedMessage {
  factory ServerInfo({
    $core.String? city,
    $core.String? country,
    $core.String? countryCode,
  }) {
    final $result = create();
    if (city != null) {
      $result.city = city;
    }
    if (country != null) {
      $result.country = country;
    }
    if (countryCode != null) {
      $result.countryCode = countryCode;
    }
    return $result;
  }
  ServerInfo._() : super();
  factory ServerInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ServerInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ServerInfo', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'city')
    ..aOS(2, _omitFieldNames ? '' : 'country')
    ..aOS(3, _omitFieldNames ? '' : 'countryCode', protoName: 'countryCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ServerInfo clone() => ServerInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ServerInfo copyWith(void Function(ServerInfo) updates) => super.copyWith((message) => updates(message as ServerInfo)) as ServerInfo;

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
  factory Bandwidth({
    $fixnum.Int64? percent,
    $fixnum.Int64? remaining,
    $fixnum.Int64? allowed,
    $fixnum.Int64? ttlSeconds,
  }) {
    final $result = create();
    if (percent != null) {
      $result.percent = percent;
    }
    if (remaining != null) {
      $result.remaining = remaining;
    }
    if (allowed != null) {
      $result.allowed = allowed;
    }
    if (ttlSeconds != null) {
      $result.ttlSeconds = ttlSeconds;
    }
    return $result;
  }
  Bandwidth._() : super();
  factory Bandwidth.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Bandwidth.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Bandwidth', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'percent')
    ..aInt64(2, _omitFieldNames ? '' : 'remaining')
    ..aInt64(3, _omitFieldNames ? '' : 'allowed')
    ..aInt64(4, _omitFieldNames ? '' : 'ttlSeconds', protoName: 'ttlSeconds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Bandwidth clone() => Bandwidth()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Bandwidth copyWith(void Function(Bandwidth) updates) => super.copyWith((message) => updates(message as Bandwidth)) as Bandwidth;

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
  factory AppData({
    $core.String? packageName,
    $core.String? name,
    $core.List<$core.int>? icon,
    $core.bool? allowedAccess,
  }) {
    final $result = create();
    if (packageName != null) {
      $result.packageName = packageName;
    }
    if (name != null) {
      $result.name = name;
    }
    if (icon != null) {
      $result.icon = icon;
    }
    if (allowedAccess != null) {
      $result.allowedAccess = allowedAccess;
    }
    return $result;
  }
  AppData._() : super();
  factory AppData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AppData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AppData', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'packageName', protoName: 'packageName')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'icon', $pb.PbFieldType.OY)
    ..aOB(4, _omitFieldNames ? '' : 'allowedAccess', protoName: 'allowedAccess')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AppData clone() => AppData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AppData copyWith(void Function(AppData) updates) => super.copyWith((message) => updates(message as AppData)) as AppData;

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
  factory Device({
    $core.String? id,
    $core.String? name,
    $fixnum.Int64? created,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (created != null) {
      $result.created = created;
    }
    return $result;
  }
  Device._() : super();
  factory Device.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Device.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Device', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aInt64(3, _omitFieldNames ? '' : 'created')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Device clone() => Device()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Device copyWith(void Function(Device) updates) => super.copyWith((message) => updates(message as Device)) as Device;

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
  factory Devices({
    $core.Iterable<Device>? devices,
  }) {
    final $result = create();
    if (devices != null) {
      $result.devices.addAll(devices);
    }
    return $result;
  }
  Devices._() : super();
  factory Devices.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Devices.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Devices', createEmptyInstance: create)
    ..pc<Device>(1, _omitFieldNames ? '' : 'devices', $pb.PbFieldType.PM, subBuilder: Device.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Devices clone() => Devices()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Devices copyWith(void Function(Devices) updates) => super.copyWith((message) => updates(message as Devices)) as Devices;

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
  factory Plan({
    $core.String? id,
    $core.String? description,
    $core.bool? bestValue,
    $fixnum.Int64? usdPrice,
    $core.Map<$core.String, $fixnum.Int64>? price,
    $core.Map<$core.String, $fixnum.Int64>? expectedMonthlyPrice,
    $core.String? totalCostBilledOneTime,
    $core.String? oneMonthCost,
    $core.String? totalCost,
    $core.String? formattedBonus,
    $core.String? renewalText,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (description != null) {
      $result.description = description;
    }
    if (bestValue != null) {
      $result.bestValue = bestValue;
    }
    if (usdPrice != null) {
      $result.usdPrice = usdPrice;
    }
    if (price != null) {
      $result.price.addAll(price);
    }
    if (expectedMonthlyPrice != null) {
      $result.expectedMonthlyPrice.addAll(expectedMonthlyPrice);
    }
    if (totalCostBilledOneTime != null) {
      $result.totalCostBilledOneTime = totalCostBilledOneTime;
    }
    if (oneMonthCost != null) {
      $result.oneMonthCost = oneMonthCost;
    }
    if (totalCost != null) {
      $result.totalCost = totalCost;
    }
    if (formattedBonus != null) {
      $result.formattedBonus = formattedBonus;
    }
    if (renewalText != null) {
      $result.renewalText = renewalText;
    }
    return $result;
  }
  Plan._() : super();
  factory Plan.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Plan.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Plan', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOB(3, _omitFieldNames ? '' : 'bestValue', protoName: 'bestValue')
    ..aInt64(4, _omitFieldNames ? '' : 'usdPrice', protoName: 'usdPrice')
    ..m<$core.String, $fixnum.Int64>(5, _omitFieldNames ? '' : 'price', entryClassName: 'Plan.PriceEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O6)
    ..m<$core.String, $fixnum.Int64>(6, _omitFieldNames ? '' : 'expectedMonthlyPrice', protoName: 'expectedMonthlyPrice', entryClassName: 'Plan.ExpectedMonthlyPriceEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O6)
    ..aOS(7, _omitFieldNames ? '' : 'totalCostBilledOneTime', protoName: 'totalCostBilledOneTime')
    ..aOS(8, _omitFieldNames ? '' : 'oneMonthCost', protoName: 'oneMonthCost')
    ..aOS(9, _omitFieldNames ? '' : 'totalCost', protoName: 'totalCost')
    ..aOS(10, _omitFieldNames ? '' : 'formattedBonus', protoName: 'formattedBonus')
    ..aOS(11, _omitFieldNames ? '' : 'renewalText', protoName: 'renewalText')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Plan clone() => Plan()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Plan copyWith(void Function(Plan) updates) => super.copyWith((message) => updates(message as Plan)) as Plan;

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
  $core.Map<$core.String, $fixnum.Int64> get expectedMonthlyPrice => $_getMap(5);

  @$pb.TagNumber(7)
  $core.String get totalCostBilledOneTime => $_getSZ(6);
  @$pb.TagNumber(7)
  set totalCostBilledOneTime($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalCostBilledOneTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalCostBilledOneTime() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get oneMonthCost => $_getSZ(7);
  @$pb.TagNumber(8)
  set oneMonthCost($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasOneMonthCost() => $_has(7);
  @$pb.TagNumber(8)
  void clearOneMonthCost() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get totalCost => $_getSZ(8);
  @$pb.TagNumber(9)
  set totalCost($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasTotalCost() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalCost() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get formattedBonus => $_getSZ(9);
  @$pb.TagNumber(10)
  set formattedBonus($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasFormattedBonus() => $_has(9);
  @$pb.TagNumber(10)
  void clearFormattedBonus() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get renewalText => $_getSZ(10);
  @$pb.TagNumber(11)
  set renewalText($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasRenewalText() => $_has(10);
  @$pb.TagNumber(11)
  void clearRenewalText() => clearField(11);
}

class PaymentProviders extends $pb.GeneratedMessage {
  factory PaymentProviders({
    $core.String? name,
    $core.Iterable<$core.String>? logoUrls,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (logoUrls != null) {
      $result.logoUrls.addAll(logoUrls);
    }
    return $result;
  }
  PaymentProviders._() : super();
  factory PaymentProviders.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentProviders.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentProviders', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pPS(3, _omitFieldNames ? '' : 'logoUrls', protoName: 'logoUrls')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentProviders clone() => PaymentProviders()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentProviders copyWith(void Function(PaymentProviders) updates) => super.copyWith((message) => updates(message as PaymentProviders)) as PaymentProviders;

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

  @$pb.TagNumber(3)
  $core.List<$core.String> get logoUrls => $_getList(1);
}

class PaymentMethod extends $pb.GeneratedMessage {
  factory PaymentMethod({
    $core.String? method,
    $core.Iterable<PaymentProviders>? providers,
  }) {
    final $result = create();
    if (method != null) {
      $result.method = method;
    }
    if (providers != null) {
      $result.providers.addAll(providers);
    }
    return $result;
  }
  PaymentMethod._() : super();
  factory PaymentMethod.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentMethod.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentMethod', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'method')
    ..pc<PaymentProviders>(2, _omitFieldNames ? '' : 'providers', $pb.PbFieldType.PM, subBuilder: PaymentProviders.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentMethod clone() => PaymentMethod()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentMethod copyWith(void Function(PaymentMethod) updates) => super.copyWith((message) => updates(message as PaymentMethod)) as PaymentMethod;

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

class User extends $pb.GeneratedMessage {
  factory User({
    $fixnum.Int64? userId,
    $core.String? email,
    $core.String? telephone,
    $core.String? userStatus,
    $core.String? userLevel,
    $core.String? locale,
    $fixnum.Int64? expiration,
    $core.Iterable<Device>? devices,
    $core.String? code,
    $fixnum.Int64? expireAt,
    $core.String? referral,
    $core.String? token,
    $core.bool? yinbiEnabled,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (email != null) {
      $result.email = email;
    }
    if (telephone != null) {
      $result.telephone = telephone;
    }
    if (userStatus != null) {
      $result.userStatus = userStatus;
    }
    if (userLevel != null) {
      $result.userLevel = userLevel;
    }
    if (locale != null) {
      $result.locale = locale;
    }
    if (expiration != null) {
      $result.expiration = expiration;
    }
    if (devices != null) {
      $result.devices.addAll(devices);
    }
    if (code != null) {
      $result.code = code;
    }
    if (expireAt != null) {
      $result.expireAt = expireAt;
    }
    if (referral != null) {
      $result.referral = referral;
    }
    if (token != null) {
      $result.token = token;
    }
    if (yinbiEnabled != null) {
      $result.yinbiEnabled = yinbiEnabled;
    }
    return $result;
  }
  User._() : super();
  factory User.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory User.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'User', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId', protoName: 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'email')
    ..aOS(3, _omitFieldNames ? '' : 'telephone')
    ..aOS(4, _omitFieldNames ? '' : 'userStatus', protoName: 'userStatus')
    ..aOS(5, _omitFieldNames ? '' : 'userLevel', protoName: 'userLevel')
    ..aOS(6, _omitFieldNames ? '' : 'locale')
    ..aInt64(7, _omitFieldNames ? '' : 'expiration')
    ..pc<Device>(8, _omitFieldNames ? '' : 'devices', $pb.PbFieldType.PM, subBuilder: Device.create)
    ..aOS(9, _omitFieldNames ? '' : 'code')
    ..aInt64(10, _omitFieldNames ? '' : 'expireAt', protoName: 'expireAt')
    ..aOS(11, _omitFieldNames ? '' : 'referral')
    ..aOS(12, _omitFieldNames ? '' : 'token')
    ..aOB(13, _omitFieldNames ? '' : 'yinbiEnabled', protoName: 'yinbiEnabled')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  User clone() => User()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  User copyWith(void Function(User) updates) => super.copyWith((message) => updates(message as User)) as User;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  User createEmptyInstance() => create();
  static $pb.PbList<User> createRepeated() => $pb.PbList<User>();
  @$core.pragma('dart2js:noInline')
  static User getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get email => $_getSZ(1);
  @$pb.TagNumber(2)
  set email($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearEmail() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get telephone => $_getSZ(2);
  @$pb.TagNumber(3)
  set telephone($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTelephone() => $_has(2);
  @$pb.TagNumber(3)
  void clearTelephone() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get userStatus => $_getSZ(3);
  @$pb.TagNumber(4)
  set userStatus($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUserStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserStatus() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get userLevel => $_getSZ(4);
  @$pb.TagNumber(5)
  set userLevel($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUserLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserLevel() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get locale => $_getSZ(5);
  @$pb.TagNumber(6)
  set locale($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLocale() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocale() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get expiration => $_getI64(6);
  @$pb.TagNumber(7)
  set expiration($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasExpiration() => $_has(6);
  @$pb.TagNumber(7)
  void clearExpiration() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<Device> get devices => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get code => $_getSZ(8);
  @$pb.TagNumber(9)
  set code($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasCode() => $_has(8);
  @$pb.TagNumber(9)
  void clearCode() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get expireAt => $_getI64(9);
  @$pb.TagNumber(10)
  set expireAt($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasExpireAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearExpireAt() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get referral => $_getSZ(10);
  @$pb.TagNumber(11)
  set referral($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasReferral() => $_has(10);
  @$pb.TagNumber(11)
  void clearReferral() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get token => $_getSZ(11);
  @$pb.TagNumber(12)
  set token($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasToken() => $_has(11);
  @$pb.TagNumber(12)
  void clearToken() => clearField(12);

  @$pb.TagNumber(13)
  $core.bool get yinbiEnabled => $_getBF(12);
  @$pb.TagNumber(13)
  set yinbiEnabled($core.bool v) { $_setBool(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasYinbiEnabled() => $_has(12);
  @$pb.TagNumber(13)
  void clearYinbiEnabled() => clearField(13);
}

/// API
class BaseResponse extends $pb.GeneratedMessage {
  factory BaseResponse({
    $core.String? status,
    $core.String? error,
    $core.String? errorId,
  }) {
    final $result = create();
    if (status != null) {
      $result.status = status;
    }
    if (error != null) {
      $result.error = error;
    }
    if (errorId != null) {
      $result.errorId = errorId;
    }
    return $result;
  }
  BaseResponse._() : super();
  factory BaseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BaseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BaseResponse', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'errorId', protoName: 'errorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BaseResponse clone() => BaseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BaseResponse copyWith(void Function(BaseResponse) updates) => super.copyWith((message) => updates(message as BaseResponse)) as BaseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BaseResponse create() => BaseResponse._();
  BaseResponse createEmptyInstance() => create();
  static $pb.PbList<BaseResponse> createRepeated() => $pb.PbList<BaseResponse>();
  @$core.pragma('dart2js:noInline')
  static BaseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BaseResponse>(create);
  static BaseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get errorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasErrorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorId() => clearField(3);
}

class PaymentRedirectRequest extends $pb.GeneratedMessage {
  factory PaymentRedirectRequest({
    $core.String? plan,
    $core.String? provider,
    $core.String? currency,
    $core.String? email,
    $core.String? deviceName,
    $core.String? countryCode,
    $core.String? locale,
  }) {
    final $result = create();
    if (plan != null) {
      $result.plan = plan;
    }
    if (provider != null) {
      $result.provider = provider;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (email != null) {
      $result.email = email;
    }
    if (deviceName != null) {
      $result.deviceName = deviceName;
    }
    if (countryCode != null) {
      $result.countryCode = countryCode;
    }
    if (locale != null) {
      $result.locale = locale;
    }
    return $result;
  }
  PaymentRedirectRequest._() : super();
  factory PaymentRedirectRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentRedirectRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentRedirectRequest', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'plan')
    ..aOS(2, _omitFieldNames ? '' : 'provider')
    ..aOS(3, _omitFieldNames ? '' : 'currency')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'deviceName', protoName: 'deviceName')
    ..aOS(6, _omitFieldNames ? '' : 'countryCode', protoName: 'countryCode')
    ..aOS(7, _omitFieldNames ? '' : 'locale')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentRedirectRequest clone() => PaymentRedirectRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentRedirectRequest copyWith(void Function(PaymentRedirectRequest) updates) => super.copyWith((message) => updates(message as PaymentRedirectRequest)) as PaymentRedirectRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PaymentRedirectRequest create() => PaymentRedirectRequest._();
  PaymentRedirectRequest createEmptyInstance() => create();
  static $pb.PbList<PaymentRedirectRequest> createRepeated() => $pb.PbList<PaymentRedirectRequest>();
  @$core.pragma('dart2js:noInline')
  static PaymentRedirectRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentRedirectRequest>(create);
  static PaymentRedirectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plan => $_getSZ(0);
  @$pb.TagNumber(1)
  set plan($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get provider => $_getSZ(1);
  @$pb.TagNumber(2)
  set provider($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProvider() => $_has(1);
  @$pb.TagNumber(2)
  void clearProvider() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get currency => $_getSZ(2);
  @$pb.TagNumber(3)
  set currency($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCurrency() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrency() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get deviceName => $_getSZ(4);
  @$pb.TagNumber(5)
  set deviceName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDeviceName() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceName() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get countryCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set countryCode($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCountryCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCountryCode() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get locale => $_getSZ(6);
  @$pb.TagNumber(7)
  set locale($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLocale() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocale() => clearField(7);
}

class RedeemResellerCodeRequest extends $pb.GeneratedMessage {
  factory RedeemResellerCodeRequest({
    $core.String? email,
    $core.String? resellerCode,
    $core.String? deviceName,
    $core.String? currency,
    $core.String? idempotencyKey,
    $core.String? provider,
  }) {
    final $result = create();
    if (email != null) {
      $result.email = email;
    }
    if (resellerCode != null) {
      $result.resellerCode = resellerCode;
    }
    if (deviceName != null) {
      $result.deviceName = deviceName;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (provider != null) {
      $result.provider = provider;
    }
    return $result;
  }
  RedeemResellerCodeRequest._() : super();
  factory RedeemResellerCodeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RedeemResellerCodeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RedeemResellerCodeRequest', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'email')
    ..aOS(2, _omitFieldNames ? '' : 'resellerCode', protoName: 'resellerCode')
    ..aOS(3, _omitFieldNames ? '' : 'deviceName', protoName: 'deviceName')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..aOS(5, _omitFieldNames ? '' : 'idempotencyKey', protoName: 'idempotencyKey')
    ..aOS(6, _omitFieldNames ? '' : 'provider')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RedeemResellerCodeRequest clone() => RedeemResellerCodeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RedeemResellerCodeRequest copyWith(void Function(RedeemResellerCodeRequest) updates) => super.copyWith((message) => updates(message as RedeemResellerCodeRequest)) as RedeemResellerCodeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RedeemResellerCodeRequest create() => RedeemResellerCodeRequest._();
  RedeemResellerCodeRequest createEmptyInstance() => create();
  static $pb.PbList<RedeemResellerCodeRequest> createRepeated() => $pb.PbList<RedeemResellerCodeRequest>();
  @$core.pragma('dart2js:noInline')
  static RedeemResellerCodeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RedeemResellerCodeRequest>(create);
  static RedeemResellerCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get email => $_getSZ(0);
  @$pb.TagNumber(1)
  set email($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEmail() => $_has(0);
  @$pb.TagNumber(1)
  void clearEmail() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get resellerCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set resellerCode($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasResellerCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearResellerCode() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceName => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get idempotencyKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set idempotencyKey($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIdempotencyKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearIdempotencyKey() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get provider => $_getSZ(5);
  @$pb.TagNumber(6)
  set provider($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasProvider() => $_has(5);
  @$pb.TagNumber(6)
  void clearProvider() => clearField(6);
}

class PaymentRedirectResponse extends $pb.GeneratedMessage {
  factory PaymentRedirectResponse({
    $core.String? status,
    $core.String? error,
    $core.String? errorId,
    $core.String? redirect,
  }) {
    final $result = create();
    if (status != null) {
      $result.status = status;
    }
    if (error != null) {
      $result.error = error;
    }
    if (errorId != null) {
      $result.errorId = errorId;
    }
    if (redirect != null) {
      $result.redirect = redirect;
    }
    return $result;
  }
  PaymentRedirectResponse._() : super();
  factory PaymentRedirectResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentRedirectResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentRedirectResponse', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'errorId', protoName: 'errorId')
    ..aOS(4, _omitFieldNames ? '' : 'redirect')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentRedirectResponse clone() => PaymentRedirectResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentRedirectResponse copyWith(void Function(PaymentRedirectResponse) updates) => super.copyWith((message) => updates(message as PaymentRedirectResponse)) as PaymentRedirectResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PaymentRedirectResponse create() => PaymentRedirectResponse._();
  PaymentRedirectResponse createEmptyInstance() => create();
  static $pb.PbList<PaymentRedirectResponse> createRepeated() => $pb.PbList<PaymentRedirectResponse>();
  @$core.pragma('dart2js:noInline')
  static PaymentRedirectResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentRedirectResponse>(create);
  static PaymentRedirectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get errorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasErrorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get redirect => $_getSZ(3);
  @$pb.TagNumber(4)
  set redirect($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRedirect() => $_has(3);
  @$pb.TagNumber(4)
  void clearRedirect() => clearField(4);
}

class LinkResponse extends $pb.GeneratedMessage {
  factory LinkResponse({
    $fixnum.Int64? userID,
    $core.String? token,
    $core.String? status,
    $core.String? error,
    $core.String? errorId,
  }) {
    final $result = create();
    if (userID != null) {
      $result.userID = userID;
    }
    if (token != null) {
      $result.token = token;
    }
    if (status != null) {
      $result.status = status;
    }
    if (error != null) {
      $result.error = error;
    }
    if (errorId != null) {
      $result.errorId = errorId;
    }
    return $result;
  }
  LinkResponse._() : super();
  factory LinkResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LinkResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkResponse', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userID', protoName: 'userID')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..aOS(5, _omitFieldNames ? '' : 'errorId', protoName: 'errorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LinkResponse clone() => LinkResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LinkResponse copyWith(void Function(LinkResponse) updates) => super.copyWith((message) => updates(message as LinkResponse)) as LinkResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkResponse create() => LinkResponse._();
  LinkResponse createEmptyInstance() => create();
  static $pb.PbList<LinkResponse> createRepeated() => $pb.PbList<LinkResponse>();
  @$core.pragma('dart2js:noInline')
  static LinkResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkResponse>(create);
  static LinkResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userID => $_getI64(0);
  @$pb.TagNumber(1)
  set userID($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserID() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserID() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get errorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set errorId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasErrorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearErrorId() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
