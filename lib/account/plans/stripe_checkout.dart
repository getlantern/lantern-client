import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/account/plans/price_summary.dart';
import 'package:lantern/common/common.dart';

class StripeCheckout extends StatelessWidget {
  final String email;
  final bool? isCN;
  final bool? isFree;
  final bool? isPro;
  final bool? isPlatinum;

  const StripeCheckout({
    required this.email,
    Key? key,
    this.isCN,
    this.isFree,
    this.isPro,
    this.isPlatinum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Lantern Pro Checkout',
      body: StatefulBuilder(
          builder: (context, setState) => Container(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  top: 24,
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    // * Step 2
                    // TODO: translations
                    const PlanStep(
                      stepNum: '3',
                      description: 'Checkout',
                    ),
                    // * Price summary
                    PriceSummary(
                      isCN: isCN,
                      isFree: isFree,
                      isPro: isPro,
                      isPlatinum: isPlatinum,
                      price: '10 \$',
                    ),
                    // TODO: translations
                    // TODO: pin to bottom
                    Button(text: 'Complete Payment', onPressed: () {}),
                  ],
                ),
              )),
    );
  }
}
