import 'common.dart';
import 'common_desktop.dart';
import 'package:collection/collection.dart';
import 'package:lantern/plans/utils.dart';
import 'package:fixnum/fixnum.dart';

extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}

class ConfigOptions {
  final bool developmentMode;
  final String replicaAddr;
  final bool authEnabled;
  final bool hasSucceedingProxy;
  final bool fetchedGlobalConfig;
  final bool fetchedProxiesConfig;
  final String sdkVersion;
  final Map<String, Plan>? plans;
  final Map<String, PaymentMethod>? paymentMethods;

  ConfigOptions({
    this.developmentMode = false,
    this.replicaAddr = '',
    this.authEnabled = false,
    this.hasSucceedingProxy = false,
    this.fetchedGlobalConfig = false,
    this.fetchedProxiesConfig = false,
    this.sdkVersion = '',
    this.plans = null,
    this.paymentMethods = null,
  });

  bool get startupReady => hasSucceedingProxy && fetchedGlobalConfig && fetchedProxiesConfig;

  factory ConfigOptions.fromJson(Map<String, dynamic> parsedJson) {
    final Map<String, Plan> plans = {};
    final plansResponse = parsedJson['plans'];
    if (plansResponse is List<dynamic>) {
      for (var item in plansResponse) {
        var id = item['id'] ?? item['name'];
        plans[id] = planFromJson(item) as Plan;
      }
    }
    final paymentMethods = paymentMethodsFromJson(parsedJson['paymentMethods']);
    print("plans are $plans");
    print("payment methods are $paymentMethods");
    return ConfigOptions(
      developmentMode: parsedJson['developmentMode'],
      authEnabled: parsedJson['authEnabled'],
      hasSucceedingProxy: parsedJson['hasSucceedingProxy'],
      fetchedGlobalConfig: parsedJson['fetchedGlobalConfig'],
      fetchedProxiesConfig: parsedJson['fetchedProxiesConfig'],
      plans: plans,
      paymentMethods: paymentMethods,
      replicaAddr : parsedJson['replicaAddr'].toString(),
      sdkVersion: parsedJson['sdkVersion'].toString(),
    );
  }
}