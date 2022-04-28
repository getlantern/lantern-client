import 'package:intl/intl.dart';

// TODO: temporary
const plansCN = [
  {
    'id': '1y-cny-9',
    'description': '一年套餐',
    'duration': {'days': 0, 'months': 0, 'years': 1},
    'price': {'cny': 34000},
    'expectedMonthlyPrice': {'cny': 2836},
    'usdPrice': 4800,
    'usdPrice1Y': 4800,
    'usdPrice2Y': 8700,
    'redeemFor': {'days': 0, 'months': 1},
    'renewalBonus': {'days': 0, 'months': 1},
    'renewalBonusExpired': {'days': 15, 'months': 0},
    'renewalBonusExpected': {'days': 0, 'months': 0},
    'discount': 0,
    'bestValue': false,
    'level': 'pro',
  },
  {
    'id': '2y-cny-9',
    'description': '两年套餐',
    'duration': {'days': 0, 'months': 0, 'years': 2},
    'price': {'cny': 61700},
    'expectedMonthlyPrice': {'cny': 2570},
    'usdPrice': 8700,
    'usdPrice1Y': 4800,
    'usdPrice2Y': 8700,
    'redeemFor': {'days': 0, 'months': 3},
    'renewalBonus': {'days': 0, 'months': 3},
    'renewalBonusExpired': {'days': 15, 'months': 1},
    'renewalBonusExpected': {'days': 0, 'months': 0},
    'discount': 0.09379407616361073,
    'bestValue': false,
    'level': 'pro',
  },
  {
    'id': '1y-cny-9-platinum',
    'description': 'one_year_plan_platinum',
    'duration': {'days': 0, 'months': 0, 'years': 1},
    'price': {'cny': 69500},
    'expectedMonthlyPrice': {'cny': 5790},
    'usdPrice': 9800,
    'usdPrice1Y': 9800,
    'usdPrice2Y': 18700,
    'redeemFor': {'days': 0, 'months': 1},
    'renewalBonus': {'days': 0, 'months': 1},
    'renewalBonusExpired': {'days': 15, 'months': 0},
    'renewalBonusExpected': {'days': 0, 'months': 0},
    'discount': 0,
    'bestValue': true,
    'level': 'platinum',
  },
  {
    'id': '2y-cny-9-platinum',
    'description': 'two_years_plan_platinum',
    'duration': {'days': 0, 'months': 0, 'years': 2},
    'price': {'cny': 132600},
    'expectedMonthlyPrice': {'cny': 5524},
    'usdPrice': 18700,
    'usdPrice1Y': 9800,
    'usdPrice2Y': 18700,
    'redeemFor': {'days': 0, 'months': 3},
    'renewalBonus': {'days': 0, 'months': 3},
    'renewalBonusExpired': {'days': 15, 'months': 1},
    'renewalBonusExpected': {'days': 0, 'months': 0},
    'discount': 0.0459412780656304,
    'bestValue': true,
    'level': 'platinum',
  }
];

const plansGlobal = [
  {
    'id': '1y-cad-9',
    'description': '1 year Pro',
    'duration': {'days': 0, 'months': 0, 'years': 1},
    'price': {'cad': 34000},
    'expectedMonthlyPrice': {'cad': 2836},
    'usdPrice': 4800,
    'usdPrice1Y': 4800,
    'usdPrice2Y': 8700,
    'redeemFor': {'days': 0, 'months': 1},
    'renewalBonus': {'days': 0, 'months': 1},
    'renewalBonusExpired': {'days': 15, 'months': 0},
    'renewalBonusExpected': {'days': 0, 'months': 0},
    'discount': 0,
    'bestValue': false,
    'level': 'pro',
  },
  {
    'id': '2y-cad-9',
    'description': '2 Years Pro',
    'duration': {'days': 0, 'months': 0, 'years': 2},
    'price': {'cad': 61700},
    'expectedMonthlyPrice': {'cad': 2570},
    'usdPrice': 8700,
    'usdPrice1Y': 4800,
    'usdPrice2Y': 8700,
    'redeemFor': {'days': 0, 'months': 3},
    'renewalBonus': {'days': 0, 'months': 3},
    'renewalBonusExpired': {'days': 15, 'months': 1},
    'renewalBonusExpected': {'days': 0, 'months': 0},
    'discount': 0.09379407616361073,
    'bestValue': true,
    'level': 'pro',
  },
];

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

const featuresList = [
  // TODO: translations
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
// TODO: temporary
const plans = plansCN;
const isCN = true;
const isFree = true;
const isPro = true;
const isPlatinum = false;

final currencyFormatter = NumberFormat('#,##,000');
