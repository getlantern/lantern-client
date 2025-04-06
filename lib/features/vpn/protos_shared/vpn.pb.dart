//
//  Generated code. Do not modify.
//  source: protos_shared/vpn.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
  void clearCity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get country => $_getSZ(1);
  @$pb.TagNumber(2)
  set country($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCountry() => $_has(1);
  @$pb.TagNumber(2)
  void clearCountry() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get countryCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set countryCode($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCountryCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCountryCode() => $_clearField(3);
}

class Bandwidth extends $pb.GeneratedMessage {
  factory Bandwidth({
    $fixnum.Int64? percent,
    $fixnum.Int64? mibUsed,
    $fixnum.Int64? mibAllowed,
    $fixnum.Int64? ttlSeconds,
  }) {
    final $result = create();
    if (percent != null) {
      $result.percent = percent;
    }
    if (mibUsed != null) {
      $result.mibUsed = mibUsed;
    }
    if (mibAllowed != null) {
      $result.mibAllowed = mibAllowed;
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
    ..aInt64(2, _omitFieldNames ? '' : 'mibUsed', protoName: 'mibUsed')
    ..aInt64(3, _omitFieldNames ? '' : 'mibAllowed', protoName: 'mibAllowed')
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
  void clearPercent() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get mibUsed => $_getI64(1);
  @$pb.TagNumber(2)
  set mibUsed($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMibUsed() => $_has(1);
  @$pb.TagNumber(2)
  void clearMibUsed() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get mibAllowed => $_getI64(2);
  @$pb.TagNumber(3)
  set mibAllowed($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMibAllowed() => $_has(2);
  @$pb.TagNumber(3)
  void clearMibAllowed() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get ttlSeconds => $_getI64(3);
  @$pb.TagNumber(4)
  set ttlSeconds($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTtlSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearTtlSeconds() => $_clearField(4);
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
  void clearPackageName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get icon => $_getN(2);
  @$pb.TagNumber(3)
  set icon($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIcon() => $_has(2);
  @$pb.TagNumber(3)
  void clearIcon() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get allowedAccess => $_getBF(3);
  @$pb.TagNumber(4)
  set allowedAccess($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAllowedAccess() => $_has(3);
  @$pb.TagNumber(4)
  void clearAllowedAccess() => $_clearField(4);
}

class AppsData extends $pb.GeneratedMessage {
  factory AppsData({
    $core.Iterable<AppData>? appsList,
  }) {
    final $result = create();
    if (appsList != null) {
      $result.appsList.addAll(appsList);
    }
    return $result;
  }
  AppsData._() : super();
  factory AppsData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AppsData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AppsData', createEmptyInstance: create)
    ..pc<AppData>(1, _omitFieldNames ? '' : 'appsList', $pb.PbFieldType.PM, protoName: 'appsList', subBuilder: AppData.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AppsData clone() => AppsData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AppsData copyWith(void Function(AppsData) updates) => super.copyWith((message) => updates(message as AppsData)) as AppsData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppsData create() => AppsData._();
  AppsData createEmptyInstance() => create();
  static $pb.PbList<AppsData> createRepeated() => $pb.PbList<AppsData>();
  @$core.pragma('dart2js:noInline')
  static AppsData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AppsData>(create);
  static AppsData? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AppData> get appsList => $_getList(0);
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
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get created => $_getI64(2);
  @$pb.TagNumber(3)
  set created($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCreated() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreated() => $_clearField(3);
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
  $pb.PbList<Device> get devices => $_getList(0);
}

class Plans extends $pb.GeneratedMessage {
  factory Plans({
    $core.Iterable<Plan>? plan,
  }) {
    final $result = create();
    if (plan != null) {
      $result.plan.addAll(plan);
    }
    return $result;
  }
  Plans._() : super();
  factory Plans.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Plans.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Plans', createEmptyInstance: create)
    ..pc<Plan>(1, _omitFieldNames ? '' : 'plan', $pb.PbFieldType.PM, subBuilder: Plan.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Plans clone() => Plans()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Plans copyWith(void Function(Plans) updates) => super.copyWith((message) => updates(message as Plans)) as Plans;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Plans create() => Plans._();
  Plans createEmptyInstance() => create();
  static $pb.PbList<Plans> createRepeated() => $pb.PbList<Plans>();
  @$core.pragma('dart2js:noInline')
  static Plans getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Plans>(create);
  static Plans? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Plan> get plan => $_getList(0);
}

class Plan extends $pb.GeneratedMessage {
  factory Plan({
    $core.String? id,
    $core.String? description,
    $core.bool? bestValue,
    $fixnum.Int64? usdPrice,
    $pb.PbMap<$core.String, $fixnum.Int64>? price,
    $pb.PbMap<$core.String, $fixnum.Int64>? expectedMonthlyPrice,
    $core.String? totalCostBilledOneTime,
    $core.String? oneMonthCost,
    $core.String? totalCost,
    $core.String? formattedBonus,
    $core.String? renewalText,
    $pb.PbMap<$core.String, $fixnum.Int64>? renewalBonusExpected,
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
    if (renewalBonusExpected != null) {
      $result.renewalBonusExpected.addAll(renewalBonusExpected);
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
    ..m<$core.String, $fixnum.Int64>(13, _omitFieldNames ? '' : 'renewalBonusExpected', protoName: 'renewalBonusExpected', entryClassName: 'Plan.RenewalBonusExpectedEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O6)
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
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get bestValue => $_getBF(2);
  @$pb.TagNumber(3)
  set bestValue($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBestValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearBestValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get usdPrice => $_getI64(3);
  @$pb.TagNumber(4)
  set usdPrice($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUsdPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsdPrice() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $fixnum.Int64> get price => $_getMap(4);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $fixnum.Int64> get expectedMonthlyPrice => $_getMap(5);

  @$pb.TagNumber(7)
  $core.String get totalCostBilledOneTime => $_getSZ(6);
  @$pb.TagNumber(7)
  set totalCostBilledOneTime($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalCostBilledOneTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalCostBilledOneTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get oneMonthCost => $_getSZ(7);
  @$pb.TagNumber(8)
  set oneMonthCost($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasOneMonthCost() => $_has(7);
  @$pb.TagNumber(8)
  void clearOneMonthCost() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get totalCost => $_getSZ(8);
  @$pb.TagNumber(9)
  set totalCost($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasTotalCost() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalCost() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get formattedBonus => $_getSZ(9);
  @$pb.TagNumber(10)
  set formattedBonus($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasFormattedBonus() => $_has(9);
  @$pb.TagNumber(10)
  void clearFormattedBonus() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get renewalText => $_getSZ(10);
  @$pb.TagNumber(11)
  set renewalText($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasRenewalText() => $_has(10);
  @$pb.TagNumber(11)
  void clearRenewalText() => $_clearField(11);

  @$pb.TagNumber(13)
  $pb.PbMap<$core.String, $fixnum.Int64> get renewalBonusExpected => $_getMap(11);
}

class PaymentProviders extends $pb.GeneratedMessage {
  factory PaymentProviders({
    $core.String? name,
    $core.Iterable<$core.String>? logoUrls,
    $pb.PbMap<$core.String, $core.String>? data,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (logoUrls != null) {
      $result.logoUrls.addAll(logoUrls);
    }
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  PaymentProviders._() : super();
  factory PaymentProviders.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentProviders.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentProviders', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pPS(3, _omitFieldNames ? '' : 'logoUrls', protoName: 'logoUrls')
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'data', entryClassName: 'PaymentProviders.DataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS)
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
  void clearName() => $_clearField(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get logoUrls => $_getList(1);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get data => $_getMap(2);
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
  void clearMethod() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<PaymentProviders> get providers => $_getList(1);
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
    $core.Iterable<$core.String>? inviters,
    $core.Iterable<$core.String>? invitees,
    $core.Iterable<Purchase>? purchases,
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
    if (inviters != null) {
      $result.inviters.addAll(inviters);
    }
    if (invitees != null) {
      $result.invitees.addAll(invitees);
    }
    if (purchases != null) {
      $result.purchases.addAll(purchases);
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
    ..pPS(14, _omitFieldNames ? '' : 'inviters')
    ..pPS(15, _omitFieldNames ? '' : 'invitees')
    ..pc<Purchase>(16, _omitFieldNames ? '' : 'purchases', $pb.PbFieldType.PM, subBuilder: Purchase.create)
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
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get email => $_getSZ(1);
  @$pb.TagNumber(2)
  set email($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearEmail() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get telephone => $_getSZ(2);
  @$pb.TagNumber(3)
  set telephone($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTelephone() => $_has(2);
  @$pb.TagNumber(3)
  void clearTelephone() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get userStatus => $_getSZ(3);
  @$pb.TagNumber(4)
  set userStatus($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUserStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get userLevel => $_getSZ(4);
  @$pb.TagNumber(5)
  set userLevel($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUserLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get locale => $_getSZ(5);
  @$pb.TagNumber(6)
  set locale($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLocale() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocale() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get expiration => $_getI64(6);
  @$pb.TagNumber(7)
  set expiration($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasExpiration() => $_has(6);
  @$pb.TagNumber(7)
  void clearExpiration() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<Device> get devices => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get code => $_getSZ(8);
  @$pb.TagNumber(9)
  set code($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasCode() => $_has(8);
  @$pb.TagNumber(9)
  void clearCode() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get expireAt => $_getI64(9);
  @$pb.TagNumber(10)
  set expireAt($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasExpireAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearExpireAt() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get referral => $_getSZ(10);
  @$pb.TagNumber(11)
  set referral($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasReferral() => $_has(10);
  @$pb.TagNumber(11)
  void clearReferral() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get token => $_getSZ(11);
  @$pb.TagNumber(12)
  set token($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasToken() => $_has(11);
  @$pb.TagNumber(12)
  void clearToken() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get yinbiEnabled => $_getBF(12);
  @$pb.TagNumber(13)
  set yinbiEnabled($core.bool v) { $_setBool(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasYinbiEnabled() => $_has(12);
  @$pb.TagNumber(13)
  void clearYinbiEnabled() => $_clearField(13);

  @$pb.TagNumber(14)
  $pb.PbList<$core.String> get inviters => $_getList(13);

  @$pb.TagNumber(15)
  $pb.PbList<$core.String> get invitees => $_getList(14);

  @$pb.TagNumber(16)
  $pb.PbList<Purchase> get purchases => $_getList(15);
}

class Purchase extends $pb.GeneratedMessage {
  factory Purchase({
    $core.String? plan,
  }) {
    final $result = create();
    if (plan != null) {
      $result.plan = plan;
    }
    return $result;
  }
  Purchase._() : super();
  factory Purchase.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Purchase.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Purchase', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'plan')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Purchase clone() => Purchase()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Purchase copyWith(void Function(Purchase) updates) => super.copyWith((message) => updates(message as Purchase)) as Purchase;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Purchase create() => Purchase._();
  Purchase createEmptyInstance() => create();
  static $pb.PbList<Purchase> createRepeated() => $pb.PbList<Purchase>();
  @$core.pragma('dart2js:noInline')
  static Purchase getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Purchase>(create);
  static Purchase? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plan => $_getSZ(0);
  @$pb.TagNumber(1)
  set plan($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
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
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get errorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasErrorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorId() => $_clearField(3);
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
  void clearPlan() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get provider => $_getSZ(1);
  @$pb.TagNumber(2)
  set provider($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProvider() => $_has(1);
  @$pb.TagNumber(2)
  void clearProvider() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get currency => $_getSZ(2);
  @$pb.TagNumber(3)
  set currency($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCurrency() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrency() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get deviceName => $_getSZ(4);
  @$pb.TagNumber(5)
  set deviceName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDeviceName() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get countryCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set countryCode($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCountryCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCountryCode() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get locale => $_getSZ(6);
  @$pb.TagNumber(7)
  set locale($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLocale() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocale() => $_clearField(7);
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
  void clearEmail() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get resellerCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set resellerCode($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasResellerCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearResellerCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceName => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get idempotencyKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set idempotencyKey($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIdempotencyKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearIdempotencyKey() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get provider => $_getSZ(5);
  @$pb.TagNumber(6)
  set provider($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasProvider() => $_has(5);
  @$pb.TagNumber(6)
  void clearProvider() => $_clearField(6);
}

class Icon extends $pb.GeneratedMessage {
  factory Icon({
    $core.Iterable<$core.String>? icons,
  }) {
    final $result = create();
    if (icons != null) {
      $result.icons.addAll(icons);
    }
    return $result;
  }
  Icon._() : super();
  factory Icon.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Icon.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Icon', createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'icons')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Icon clone() => Icon()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Icon copyWith(void Function(Icon) updates) => super.copyWith((message) => updates(message as Icon)) as Icon;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Icon create() => Icon._();
  Icon createEmptyInstance() => create();
  static $pb.PbList<Icon> createRepeated() => $pb.PbList<Icon>();
  @$core.pragma('dart2js:noInline')
  static Icon getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Icon>(create);
  static Icon? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get icons => $_getList(0);
}

class PaymentMethodsResponse extends $pb.GeneratedMessage {
  factory PaymentMethodsResponse({
    BaseResponse? base,
    $pb.PbMap<$core.String, PaymentMethodsList>? providers,
    $core.Iterable<Plan>? plans,
    $pb.PbMap<$core.String, Icon>? icons,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (providers != null) {
      $result.providers.addAll(providers);
    }
    if (plans != null) {
      $result.plans.addAll(plans);
    }
    if (icons != null) {
      $result.icons.addAll(icons);
    }
    return $result;
  }
  PaymentMethodsResponse._() : super();
  factory PaymentMethodsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentMethodsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentMethodsResponse', createEmptyInstance: create)
    ..aOM<BaseResponse>(1, _omitFieldNames ? '' : 'base', subBuilder: BaseResponse.create)
    ..m<$core.String, PaymentMethodsList>(2, _omitFieldNames ? '' : 'providers', entryClassName: 'PaymentMethodsResponse.ProvidersEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: PaymentMethodsList.create, valueDefaultOrMaker: PaymentMethodsList.getDefault)
    ..pc<Plan>(3, _omitFieldNames ? '' : 'plans', $pb.PbFieldType.PM, subBuilder: Plan.create)
    ..m<$core.String, Icon>(4, _omitFieldNames ? '' : 'icons', entryClassName: 'PaymentMethodsResponse.IconsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: Icon.create, valueDefaultOrMaker: Icon.getDefault)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentMethodsResponse clone() => PaymentMethodsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentMethodsResponse copyWith(void Function(PaymentMethodsResponse) updates) => super.copyWith((message) => updates(message as PaymentMethodsResponse)) as PaymentMethodsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PaymentMethodsResponse create() => PaymentMethodsResponse._();
  PaymentMethodsResponse createEmptyInstance() => create();
  static $pb.PbList<PaymentMethodsResponse> createRepeated() => $pb.PbList<PaymentMethodsResponse>();
  @$core.pragma('dart2js:noInline')
  static PaymentMethodsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentMethodsResponse>(create);
  static PaymentMethodsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BaseResponse get base => $_getN(0);
  @$pb.TagNumber(1)
  set base(BaseResponse v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);
  @$pb.TagNumber(1)
  BaseResponse ensureBase() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, PaymentMethodsList> get providers => $_getMap(1);

  @$pb.TagNumber(3)
  $pb.PbList<Plan> get plans => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, Icon> get icons => $_getMap(3);
}

class PaymentMethodsList extends $pb.GeneratedMessage {
  factory PaymentMethodsList({
    $core.Iterable<PaymentMethod>? methods,
  }) {
    final $result = create();
    if (methods != null) {
      $result.methods.addAll(methods);
    }
    return $result;
  }
  PaymentMethodsList._() : super();
  factory PaymentMethodsList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentMethodsList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PaymentMethodsList', createEmptyInstance: create)
    ..pc<PaymentMethod>(1, _omitFieldNames ? '' : 'methods', $pb.PbFieldType.PM, subBuilder: PaymentMethod.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PaymentMethodsList clone() => PaymentMethodsList()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PaymentMethodsList copyWith(void Function(PaymentMethodsList) updates) => super.copyWith((message) => updates(message as PaymentMethodsList)) as PaymentMethodsList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PaymentMethodsList create() => PaymentMethodsList._();
  PaymentMethodsList createEmptyInstance() => create();
  static $pb.PbList<PaymentMethodsList> createRepeated() => $pb.PbList<PaymentMethodsList>();
  @$core.pragma('dart2js:noInline')
  static PaymentMethodsList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentMethodsList>(create);
  static PaymentMethodsList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PaymentMethod> get methods => $_getList(0);
}

class PlansResponse extends $pb.GeneratedMessage {
  factory PlansResponse({
    BaseResponse? base,
    $core.Iterable<Plan>? plans,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (plans != null) {
      $result.plans.addAll(plans);
    }
    return $result;
  }
  PlansResponse._() : super();
  factory PlansResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlansResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlansResponse', createEmptyInstance: create)
    ..aOM<BaseResponse>(1, _omitFieldNames ? '' : 'base', subBuilder: BaseResponse.create)
    ..pc<Plan>(2, _omitFieldNames ? '' : 'plans', $pb.PbFieldType.PM, subBuilder: Plan.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PlansResponse clone() => PlansResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PlansResponse copyWith(void Function(PlansResponse) updates) => super.copyWith((message) => updates(message as PlansResponse)) as PlansResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlansResponse create() => PlansResponse._();
  PlansResponse createEmptyInstance() => create();
  static $pb.PbList<PlansResponse> createRepeated() => $pb.PbList<PlansResponse>();
  @$core.pragma('dart2js:noInline')
  static PlansResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlansResponse>(create);
  static PlansResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BaseResponse get base => $_getN(0);
  @$pb.TagNumber(1)
  set base(BaseResponse v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);
  @$pb.TagNumber(1)
  BaseResponse ensureBase() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Plan> get plans => $_getList(1);
}

class PaymentRedirectResponse extends $pb.GeneratedMessage {
  factory PaymentRedirectResponse({
    BaseResponse? base,
    $core.String? redirect,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
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
    ..aOM<BaseResponse>(1, _omitFieldNames ? '' : 'base', subBuilder: BaseResponse.create)
    ..aOS(2, _omitFieldNames ? '' : 'redirect')
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
  BaseResponse get base => $_getN(0);
  @$pb.TagNumber(1)
  set base(BaseResponse v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);
  @$pb.TagNumber(1)
  BaseResponse ensureBase() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get redirect => $_getSZ(1);
  @$pb.TagNumber(2)
  set redirect($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRedirect() => $_has(1);
  @$pb.TagNumber(2)
  void clearRedirect() => $_clearField(2);
}

class UserDataResponse extends $pb.GeneratedMessage {
  factory UserDataResponse({
    BaseResponse? base,
    User? user,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (user != null) {
      $result.user = user;
    }
    return $result;
  }
  UserDataResponse._() : super();
  factory UserDataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserDataResponse', createEmptyInstance: create)
    ..aOM<BaseResponse>(1, _omitFieldNames ? '' : 'base', subBuilder: BaseResponse.create)
    ..aOM<User>(2, _omitFieldNames ? '' : 'user', subBuilder: User.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserDataResponse clone() => UserDataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserDataResponse copyWith(void Function(UserDataResponse) updates) => super.copyWith((message) => updates(message as UserDataResponse)) as UserDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserDataResponse create() => UserDataResponse._();
  UserDataResponse createEmptyInstance() => create();
  static $pb.PbList<UserDataResponse> createRepeated() => $pb.PbList<UserDataResponse>();
  @$core.pragma('dart2js:noInline')
  static UserDataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserDataResponse>(create);
  static UserDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BaseResponse get base => $_getN(0);
  @$pb.TagNumber(1)
  set base(BaseResponse v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);
  @$pb.TagNumber(1)
  BaseResponse ensureBase() => $_ensure(0);

  @$pb.TagNumber(2)
  User get user => $_getN(1);
  @$pb.TagNumber(2)
  set user(User v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUser() => $_has(1);
  @$pb.TagNumber(2)
  void clearUser() => $_clearField(2);
  @$pb.TagNumber(2)
  User ensureUser() => $_ensure(1);
}

class LinkResponse extends $pb.GeneratedMessage {
  factory LinkResponse({
    BaseResponse? base,
    $fixnum.Int64? userID,
    $core.String? token,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (userID != null) {
      $result.userID = userID;
    }
    if (token != null) {
      $result.token = token;
    }
    return $result;
  }
  LinkResponse._() : super();
  factory LinkResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LinkResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkResponse', createEmptyInstance: create)
    ..aOM<BaseResponse>(1, _omitFieldNames ? '' : 'base', subBuilder: BaseResponse.create)
    ..aInt64(2, _omitFieldNames ? '' : 'userID', protoName: 'userID')
    ..aOS(3, _omitFieldNames ? '' : 'token')
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
  BaseResponse get base => $_getN(0);
  @$pb.TagNumber(1)
  set base(BaseResponse v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);
  @$pb.TagNumber(1)
  BaseResponse ensureBase() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userID => $_getI64(1);
  @$pb.TagNumber(2)
  set userID($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserID() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserID() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => $_clearField(3);
}

class LinkCodeResponse extends $pb.GeneratedMessage {
  factory LinkCodeResponse({
    BaseResponse? base,
    $core.String? code,
    $fixnum.Int64? expireAt,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (code != null) {
      $result.code = code;
    }
    if (expireAt != null) {
      $result.expireAt = expireAt;
    }
    return $result;
  }
  LinkCodeResponse._() : super();
  factory LinkCodeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LinkCodeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkCodeResponse', createEmptyInstance: create)
    ..aOM<BaseResponse>(1, _omitFieldNames ? '' : 'base', subBuilder: BaseResponse.create)
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..aInt64(3, _omitFieldNames ? '' : 'expireAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LinkCodeResponse clone() => LinkCodeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LinkCodeResponse copyWith(void Function(LinkCodeResponse) updates) => super.copyWith((message) => updates(message as LinkCodeResponse)) as LinkCodeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkCodeResponse create() => LinkCodeResponse._();
  LinkCodeResponse createEmptyInstance() => create();
  static $pb.PbList<LinkCodeResponse> createRepeated() => $pb.PbList<LinkCodeResponse>();
  @$core.pragma('dart2js:noInline')
  static LinkCodeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkCodeResponse>(create);
  static LinkCodeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BaseResponse get base => $_getN(0);
  @$pb.TagNumber(1)
  set base(BaseResponse v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);
  @$pb.TagNumber(1)
  BaseResponse ensureBase() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expireAt => $_getI64(2);
  @$pb.TagNumber(3)
  set expireAt($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasExpireAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpireAt() => $_clearField(3);
}

class LinkCodeRedeemResponse extends $pb.GeneratedMessage {
  factory LinkCodeRedeemResponse({
    BaseResponse? base,
    $core.String? status,
    $fixnum.Int64? userId,
    $core.String? token,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (status != null) {
      $result.status = status;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (token != null) {
      $result.token = token;
    }
    return $result;
  }
  LinkCodeRedeemResponse._() : super();
  factory LinkCodeRedeemResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LinkCodeRedeemResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkCodeRedeemResponse', createEmptyInstance: create)
    ..aOM<BaseResponse>(1, _omitFieldNames ? '' : 'base', subBuilder: BaseResponse.create)
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aInt64(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LinkCodeRedeemResponse clone() => LinkCodeRedeemResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LinkCodeRedeemResponse copyWith(void Function(LinkCodeRedeemResponse) updates) => super.copyWith((message) => updates(message as LinkCodeRedeemResponse)) as LinkCodeRedeemResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkCodeRedeemResponse create() => LinkCodeRedeemResponse._();
  LinkCodeRedeemResponse createEmptyInstance() => create();
  static $pb.PbList<LinkCodeRedeemResponse> createRepeated() => $pb.PbList<LinkCodeRedeemResponse>();
  @$core.pragma('dart2js:noInline')
  static LinkCodeRedeemResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkCodeRedeemResponse>(create);
  static LinkCodeRedeemResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BaseResponse get base => $_getN(0);
  @$pb.TagNumber(1)
  set base(BaseResponse v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);
  @$pb.TagNumber(1)
  BaseResponse ensureBase() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get userId => $_getI64(2);
  @$pb.TagNumber(3)
  set userId($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get token => $_getSZ(3);
  @$pb.TagNumber(4)
  set token($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearToken() => $_clearField(4);
}

class ProPurchaseResponse extends $pb.GeneratedMessage {
  factory ProPurchaseResponse({
    BaseResponse? base,
    $core.String? paymentStatus,
    Plan? plan,
    $core.String? status,
  }) {
    final $result = create();
    if (base != null) {
      $result.base = base;
    }
    if (paymentStatus != null) {
      $result.paymentStatus = paymentStatus;
    }
    if (plan != null) {
      $result.plan = plan;
    }
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  ProPurchaseResponse._() : super();
  factory ProPurchaseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProPurchaseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProPurchaseResponse', createEmptyInstance: create)
    ..aOM<BaseResponse>(1, _omitFieldNames ? '' : 'base', subBuilder: BaseResponse.create)
    ..aOS(2, _omitFieldNames ? '' : 'paymentStatus')
    ..aOM<Plan>(3, _omitFieldNames ? '' : 'plan', subBuilder: Plan.create)
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProPurchaseResponse clone() => ProPurchaseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProPurchaseResponse copyWith(void Function(ProPurchaseResponse) updates) => super.copyWith((message) => updates(message as ProPurchaseResponse)) as ProPurchaseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProPurchaseResponse create() => ProPurchaseResponse._();
  ProPurchaseResponse createEmptyInstance() => create();
  static $pb.PbList<ProPurchaseResponse> createRepeated() => $pb.PbList<ProPurchaseResponse>();
  @$core.pragma('dart2js:noInline')
  static ProPurchaseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProPurchaseResponse>(create);
  static ProPurchaseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BaseResponse get base => $_getN(0);
  @$pb.TagNumber(1)
  set base(BaseResponse v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBase() => $_has(0);
  @$pb.TagNumber(1)
  void clearBase() => $_clearField(1);
  @$pb.TagNumber(1)
  BaseResponse ensureBase() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get paymentStatus => $_getSZ(1);
  @$pb.TagNumber(2)
  set paymentStatus($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPaymentStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearPaymentStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  Plan get plan => $_getN(2);
  @$pb.TagNumber(3)
  set plan(Plan v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPlan() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlan() => $_clearField(3);
  @$pb.TagNumber(3)
  Plan ensurePlan() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);
}

class UserRecovery extends $pb.GeneratedMessage {
  factory UserRecovery({
    $core.String? status,
    $fixnum.Int64? userId,
    $core.String? token,
  }) {
    final $result = create();
    if (status != null) {
      $result.status = status;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (token != null) {
      $result.token = token;
    }
    return $result;
  }
  UserRecovery._() : super();
  factory UserRecovery.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserRecovery.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserRecovery', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserRecovery clone() => UserRecovery()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserRecovery copyWith(void Function(UserRecovery) updates) => super.copyWith((message) => updates(message as UserRecovery)) as UserRecovery;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserRecovery create() => UserRecovery._();
  UserRecovery createEmptyInstance() => create();
  static $pb.PbList<UserRecovery> createRepeated() => $pb.PbList<UserRecovery>();
  @$core.pragma('dart2js:noInline')
  static UserRecovery getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserRecovery>(create);
  static UserRecovery? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => $_clearField(3);
}

class OkResponse extends $pb.GeneratedMessage {
  factory OkResponse({
    $core.String? status,
  }) {
    final $result = create();
    if (status != null) {
      $result.status = status;
    }
    return $result;
  }
  OkResponse._() : super();
  factory OkResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OkResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OkResponse', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OkResponse clone() => OkResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OkResponse copyWith(void Function(OkResponse) updates) => super.copyWith((message) => updates(message as OkResponse)) as OkResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OkResponse create() => OkResponse._();
  OkResponse createEmptyInstance() => create();
  static $pb.PbList<OkResponse> createRepeated() => $pb.PbList<OkResponse>();
  @$core.pragma('dart2js:noInline')
  static OkResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OkResponse>(create);
  static OkResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
}

class RestorePurchaseRequest extends $pb.GeneratedMessage {
  factory RestorePurchaseRequest({
    $core.String? provider,
    $core.String? token,
    $core.String? deviceName,
    $core.String? email,
    $core.String? code,
  }) {
    final $result = create();
    if (provider != null) {
      $result.provider = provider;
    }
    if (token != null) {
      $result.token = token;
    }
    if (deviceName != null) {
      $result.deviceName = deviceName;
    }
    if (email != null) {
      $result.email = email;
    }
    if (code != null) {
      $result.code = code;
    }
    return $result;
  }
  RestorePurchaseRequest._() : super();
  factory RestorePurchaseRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RestorePurchaseRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestorePurchaseRequest', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'provider')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..aOS(3, _omitFieldNames ? '' : 'deviceName')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RestorePurchaseRequest clone() => RestorePurchaseRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RestorePurchaseRequest copyWith(void Function(RestorePurchaseRequest) updates) => super.copyWith((message) => updates(message as RestorePurchaseRequest)) as RestorePurchaseRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestorePurchaseRequest create() => RestorePurchaseRequest._();
  RestorePurchaseRequest createEmptyInstance() => create();
  static $pb.PbList<RestorePurchaseRequest> createRepeated() => $pb.PbList<RestorePurchaseRequest>();
  @$core.pragma('dart2js:noInline')
  static RestorePurchaseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestorePurchaseRequest>(create);
  static RestorePurchaseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get provider => $_getSZ(0);
  @$pb.TagNumber(1)
  set provider($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasProvider() => $_has(0);
  @$pb.TagNumber(1)
  void clearProvider() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceName => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get code => $_getSZ(4);
  @$pb.TagNumber(5)
  set code($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearCode() => $_clearField(5);
}

class ChatOptions extends $pb.GeneratedMessage {
  factory ChatOptions({
    $core.bool? onBoardingStatus,
    $core.int? acceptedTermsVersion,
  }) {
    final $result = create();
    if (onBoardingStatus != null) {
      $result.onBoardingStatus = onBoardingStatus;
    }
    if (acceptedTermsVersion != null) {
      $result.acceptedTermsVersion = acceptedTermsVersion;
    }
    return $result;
  }
  ChatOptions._() : super();
  factory ChatOptions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatOptions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatOptions', createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'onBoardingStatus')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'acceptedTermsVersion', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatOptions clone() => ChatOptions()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatOptions copyWith(void Function(ChatOptions) updates) => super.copyWith((message) => updates(message as ChatOptions)) as ChatOptions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatOptions create() => ChatOptions._();
  ChatOptions createEmptyInstance() => create();
  static $pb.PbList<ChatOptions> createRepeated() => $pb.PbList<ChatOptions>();
  @$core.pragma('dart2js:noInline')
  static ChatOptions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatOptions>(create);
  static ChatOptions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get onBoardingStatus => $_getBF(0);
  @$pb.TagNumber(1)
  set onBoardingStatus($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOnBoardingStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearOnBoardingStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get acceptedTermsVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set acceptedTermsVersion($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAcceptedTermsVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearAcceptedTermsVersion() => $_clearField(2);
}

class ConfigOptions extends $pb.GeneratedMessage {
  factory ConfigOptions({
    $core.bool? developmentMode,
    $core.String? replicaAddr,
    $core.String? httpProxyAddr,
    $core.String? socksProxyAddr,
    $core.bool? authEnabled,
    $core.bool? chatEnabled,
    $core.bool? splitTunneling,
    $core.bool? hasSucceedingProxy,
    $core.bool? fetchedGlobalConfig,
    $core.bool? fetchedProxiesConfig,
    $core.Iterable<Plan>? plans,
    PaymentMethodsList? paymentMethods,
    Devices? devices,
    $core.String? sdkVersion,
    $core.String? appVersion,
    $core.String? deviceId,
    $core.String? expirationDate,
    ChatOptions? chat,
    $core.bool? proxyAll,
    $core.String? country,
    $core.bool? isUserLoggedIn,
  }) {
    final $result = create();
    if (developmentMode != null) {
      $result.developmentMode = developmentMode;
    }
    if (replicaAddr != null) {
      $result.replicaAddr = replicaAddr;
    }
    if (httpProxyAddr != null) {
      $result.httpProxyAddr = httpProxyAddr;
    }
    if (socksProxyAddr != null) {
      $result.socksProxyAddr = socksProxyAddr;
    }
    if (authEnabled != null) {
      $result.authEnabled = authEnabled;
    }
    if (chatEnabled != null) {
      $result.chatEnabled = chatEnabled;
    }
    if (splitTunneling != null) {
      $result.splitTunneling = splitTunneling;
    }
    if (hasSucceedingProxy != null) {
      $result.hasSucceedingProxy = hasSucceedingProxy;
    }
    if (fetchedGlobalConfig != null) {
      $result.fetchedGlobalConfig = fetchedGlobalConfig;
    }
    if (fetchedProxiesConfig != null) {
      $result.fetchedProxiesConfig = fetchedProxiesConfig;
    }
    if (plans != null) {
      $result.plans.addAll(plans);
    }
    if (paymentMethods != null) {
      $result.paymentMethods = paymentMethods;
    }
    if (devices != null) {
      $result.devices = devices;
    }
    if (sdkVersion != null) {
      $result.sdkVersion = sdkVersion;
    }
    if (appVersion != null) {
      $result.appVersion = appVersion;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (expirationDate != null) {
      $result.expirationDate = expirationDate;
    }
    if (chat != null) {
      $result.chat = chat;
    }
    if (proxyAll != null) {
      $result.proxyAll = proxyAll;
    }
    if (country != null) {
      $result.country = country;
    }
    if (isUserLoggedIn != null) {
      $result.isUserLoggedIn = isUserLoggedIn;
    }
    return $result;
  }
  ConfigOptions._() : super();
  factory ConfigOptions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConfigOptions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfigOptions', createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'developmentMode')
    ..aOS(2, _omitFieldNames ? '' : 'replicaAddr')
    ..aOS(3, _omitFieldNames ? '' : 'httpProxyAddr')
    ..aOS(4, _omitFieldNames ? '' : 'socksProxyAddr')
    ..aOB(5, _omitFieldNames ? '' : 'authEnabled')
    ..aOB(6, _omitFieldNames ? '' : 'chatEnabled')
    ..aOB(7, _omitFieldNames ? '' : 'splitTunneling')
    ..aOB(8, _omitFieldNames ? '' : 'hasSucceedingProxy')
    ..aOB(9, _omitFieldNames ? '' : 'fetchedGlobalConfig')
    ..aOB(10, _omitFieldNames ? '' : 'fetchedProxiesConfig')
    ..pc<Plan>(11, _omitFieldNames ? '' : 'plans', $pb.PbFieldType.PM, subBuilder: Plan.create)
    ..aOM<PaymentMethodsList>(12, _omitFieldNames ? '' : 'paymentMethods', subBuilder: PaymentMethodsList.create)
    ..aOM<Devices>(13, _omitFieldNames ? '' : 'devices', subBuilder: Devices.create)
    ..aOS(14, _omitFieldNames ? '' : 'sdkVersion')
    ..aOS(15, _omitFieldNames ? '' : 'appVersion')
    ..aOS(16, _omitFieldNames ? '' : 'deviceId')
    ..aOS(17, _omitFieldNames ? '' : 'expirationDate')
    ..aOM<ChatOptions>(18, _omitFieldNames ? '' : 'chat', subBuilder: ChatOptions.create)
    ..aOB(19, _omitFieldNames ? '' : 'proxyAll')
    ..aOS(20, _omitFieldNames ? '' : 'country')
    ..aOB(21, _omitFieldNames ? '' : 'isUserLoggedIn')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConfigOptions clone() => ConfigOptions()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConfigOptions copyWith(void Function(ConfigOptions) updates) => super.copyWith((message) => updates(message as ConfigOptions)) as ConfigOptions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfigOptions create() => ConfigOptions._();
  ConfigOptions createEmptyInstance() => create();
  static $pb.PbList<ConfigOptions> createRepeated() => $pb.PbList<ConfigOptions>();
  @$core.pragma('dart2js:noInline')
  static ConfigOptions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfigOptions>(create);
  static ConfigOptions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get developmentMode => $_getBF(0);
  @$pb.TagNumber(1)
  set developmentMode($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDevelopmentMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevelopmentMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get replicaAddr => $_getSZ(1);
  @$pb.TagNumber(2)
  set replicaAddr($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReplicaAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearReplicaAddr() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get httpProxyAddr => $_getSZ(2);
  @$pb.TagNumber(3)
  set httpProxyAddr($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHttpProxyAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearHttpProxyAddr() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get socksProxyAddr => $_getSZ(3);
  @$pb.TagNumber(4)
  set socksProxyAddr($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSocksProxyAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearSocksProxyAddr() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get authEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set authEnabled($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAuthEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearAuthEnabled() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get chatEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set chatEnabled($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasChatEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearChatEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get splitTunneling => $_getBF(6);
  @$pb.TagNumber(7)
  set splitTunneling($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSplitTunneling() => $_has(6);
  @$pb.TagNumber(7)
  void clearSplitTunneling() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get hasSucceedingProxy => $_getBF(7);
  @$pb.TagNumber(8)
  set hasSucceedingProxy($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasHasSucceedingProxy() => $_has(7);
  @$pb.TagNumber(8)
  void clearHasSucceedingProxy() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get fetchedGlobalConfig => $_getBF(8);
  @$pb.TagNumber(9)
  set fetchedGlobalConfig($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasFetchedGlobalConfig() => $_has(8);
  @$pb.TagNumber(9)
  void clearFetchedGlobalConfig() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get fetchedProxiesConfig => $_getBF(9);
  @$pb.TagNumber(10)
  set fetchedProxiesConfig($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasFetchedProxiesConfig() => $_has(9);
  @$pb.TagNumber(10)
  void clearFetchedProxiesConfig() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<Plan> get plans => $_getList(10);

  @$pb.TagNumber(12)
  PaymentMethodsList get paymentMethods => $_getN(11);
  @$pb.TagNumber(12)
  set paymentMethods(PaymentMethodsList v) { $_setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasPaymentMethods() => $_has(11);
  @$pb.TagNumber(12)
  void clearPaymentMethods() => $_clearField(12);
  @$pb.TagNumber(12)
  PaymentMethodsList ensurePaymentMethods() => $_ensure(11);

  @$pb.TagNumber(13)
  Devices get devices => $_getN(12);
  @$pb.TagNumber(13)
  set devices(Devices v) { $_setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasDevices() => $_has(12);
  @$pb.TagNumber(13)
  void clearDevices() => $_clearField(13);
  @$pb.TagNumber(13)
  Devices ensureDevices() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.String get sdkVersion => $_getSZ(13);
  @$pb.TagNumber(14)
  set sdkVersion($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasSdkVersion() => $_has(13);
  @$pb.TagNumber(14)
  void clearSdkVersion() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get appVersion => $_getSZ(14);
  @$pb.TagNumber(15)
  set appVersion($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasAppVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearAppVersion() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get deviceId => $_getSZ(15);
  @$pb.TagNumber(16)
  set deviceId($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasDeviceId() => $_has(15);
  @$pb.TagNumber(16)
  void clearDeviceId() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get expirationDate => $_getSZ(16);
  @$pb.TagNumber(17)
  set expirationDate($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasExpirationDate() => $_has(16);
  @$pb.TagNumber(17)
  void clearExpirationDate() => $_clearField(17);

  @$pb.TagNumber(18)
  ChatOptions get chat => $_getN(17);
  @$pb.TagNumber(18)
  set chat(ChatOptions v) { $_setField(18, v); }
  @$pb.TagNumber(18)
  $core.bool hasChat() => $_has(17);
  @$pb.TagNumber(18)
  void clearChat() => $_clearField(18);
  @$pb.TagNumber(18)
  ChatOptions ensureChat() => $_ensure(17);

  @$pb.TagNumber(19)
  $core.bool get proxyAll => $_getBF(18);
  @$pb.TagNumber(19)
  set proxyAll($core.bool v) { $_setBool(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasProxyAll() => $_has(18);
  @$pb.TagNumber(19)
  void clearProxyAll() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get country => $_getSZ(19);
  @$pb.TagNumber(20)
  set country($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasCountry() => $_has(19);
  @$pb.TagNumber(20)
  void clearCountry() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.bool get isUserLoggedIn => $_getBF(20);
  @$pb.TagNumber(21)
  set isUserLoggedIn($core.bool v) { $_setBool(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasIsUserLoggedIn() => $_has(20);
  @$pb.TagNumber(21)
  void clearIsUserLoggedIn() => $_clearField(21);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
