import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';

// TODO: translations
const chinaPlanDetails = [
  [
    'Unlimited data',
    'No logs',
    'Connect up to 3 devices',
  ],
  [
    'Everything included in Pro',
    'Faster Data Centers',
    'Dedicated Line',
    'Increased Reliability',
  ]
];

// TODO: translations
const featuresList = [
  'Unlimited data',
  'Faster data centers',
  'No logs',
  'Connect up to 3 devices',
  'No Ads',
];

final paymentProviders = [
  'stripe',
  'btc',
];

final renewalTextDependingOnExpiry = {
  'expiresSoon':
      'This is a Pro or Platinum user so they should have some text here',
  'expiresTomorrow': '',
  'expired': '',
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
