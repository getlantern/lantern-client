import 'package:lantern/common/common.dart';
import 'package:lantern/plans/feature_list.dart';
import 'package:lantern/plans/plan_details.dart';

@RoutePage(name: "PlansPage")
class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FullScreenDialog(
      widget: sessionModel
          .proUser((BuildContext context, bool proUser, Widget? child) {
        return sessionModel.plans(
          builder: (
            context,
            Iterable<PathAndValue<Plan>> plans,
            Widget? child,
          ) {
            if (plans.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CAssetImage(
                      path: ImagePaths.error,
                      size: 100,
                      color: grey5,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.all(24.0),
                      child: CText(
                        'error_fetching_plans'.i18n,
                        style: tsBody1,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              color: white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          padding: const EdgeInsetsDirectional.only(
                            top: 10,
                            bottom: 10,
                            start: 32,
                            end: 16,
                          ),
                          color: white,
                          child: Row(
                            children: [
                              const CAssetImage(
                                path: ImagePaths.lantern_pro_logotype,
                                size: 20,
                              ),
                              const Spacer(),
                              IconButton(
                                icon: mirrorLTR(
                                  context: context,
                                  child: CAssetImage(
                                    path: ImagePaths.cancel,
                                    color: black,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, null),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: white,
                          padding: const EdgeInsetsDirectional.only(
                            start: 24,
                            end: 24,
                          ),
                          child: Column(
                            children: [
                              // * Renewal text or upsell
                              if (proUser && plans.last.value.renewalText != '')
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    bottom: 12.0,
                                  ),
                                  child: CText(
                                    plans.last.value.renewalText,
                                    style: tsBody1,
                                  ),
                                ),
                              const Padding(
                                padding: EdgeInsetsDirectional.only(
                                  bottom: 8.0,
                                ),
                                child: CDivider(),
                              ),
                              FeatureList(),
                              const CDivider(height: 24),
                            ],
                          ),
                        ),
                        // * Step
                        Container(
                          color: white,
                          padding: const EdgeInsetsDirectional.only(
                            top: 16.0,
                            bottom: 16.0,
                            start: 32.0,
                            end: 32.0,
                          ),
                          child: Container(
                            margin:
                                const EdgeInsetsDirectional.only(start: 4.0),
                            child: PlanStep(
                              stepNum: '1',
                              description: 'choose_plan'.i18n,
                            ),
                          ),
                        ),
                        // * Card
                        ...plans.toList().reversed.map(
                              (plan) => Container(
                                color: white,
                                padding: const EdgeInsetsDirectional.only(
                                  start: 32.0,
                                  end: 32.0,
                                ),
                                child: PlanCard(
                                  plan: plan.value,
                                  isPro: proUser,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  // * Footer
                  Container(
                    height: 45,
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: grey3),
                      ),
                      color: grey1,
                    ),
                    child: GestureDetector(
                      onTap: () async => await context.pushRoute(
                        ResellerCodeCheckout(isPro: proUser),
                      ),
                      child: CText(
                        'Have a Lantern Pro activation code? Click here.',
                        style: tsBody1.copiedWith(color: grey5),
                      ),
                    ), // Translations
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  ///If the user is already so not ask for email
  ///f the user is not pro, ask for email
  void _onPromoCodeTap(BuildContext context, bool proUser) {
    if (proUser) {
      context.pushRoute(ResellerCodeCheckout(
          isPro: true, email: sessionModel.userEmail.value!));
    } else {
      context.pushRoute(CreateAccountEmail(
          accountCreation: AccountCreation.proCodeActivation));
    }
  }
}
