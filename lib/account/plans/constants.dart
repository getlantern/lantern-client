import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';

final chinaPlanDetails = [
  [
    'Unlimited data'.i18n,
    'No logs'.i18n,
    'Connect up to 3 devices'.i18n,
  ],
  [
    'Everything included in Pro'.i18n,
    'Faster Data Centers'.i18n,
    'Dedicated Line'.i18n,
    'Increased Reliability'.i18n,
  ]
];

final featuresList = [
  'Unlimited data'.i18n,
  'Faster Data Centers'.i18n,
  'No logs'.i18n,
  'Connect up to 3 devices'.i18n,
  'No Ads'.i18n,
];

final paymentProviders = [
  'stripe',
  'btc',
];

final renewalTextDependingOnExpiry = {
  'expiresSoon': 'expires_soon'.i18n,
  'expiresToday': 'expires_today'.i18n,
  'expired': 'expired'.i18n,
};

final currencyFormatter = NumberFormat('#,##,000');

// TODO: move to utils file
List<Map<String, Object>> formatCachedPlans(String cachedPlans) {
  // transform the String cached in db to a workable format
  // ignore: omit_local_variable_types
  List<Map<String, Object>> plans = [];

  if (cachedPlans == '') return [];
  final plansMap = jsonDecode(cachedPlans) as Map;
  plansMap.forEach((key, value) => plans.add(value));
  return plans;
}

// TODO: move below to utils file
void onAPIcallTimeout({code, message}) {
  throw PlatformException(
    code: code,
    message: message,
  );
}

// TODO: Make sure this is coming localized from the backend
String localizedErrorDescription(error) =>
    (error as PlatformException).message.toString();

// TODO: we build a pollForUpdates logic instead of having a constant duration
const defaultTimeoutDuration = Duration(seconds: 10);
