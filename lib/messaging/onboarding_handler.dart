import 'messaging.dart';

class OnboardingHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return model.getOnBoardingStatus(
        (BuildContext context, bool isOnboarded, Widget? child) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (!isOnboarded) {
          context.router.replace(const Welcome());
        } else {
          context.router.replace(const Chats());
        }
      });
      return Container();

      // * TESTING PURPOSES
      // return Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Button(
      //       text: 'complete onboarding',
      //       onPressed: () => model.markIsOnboarded(),
      //     ),
      //     CText(isOnboarded.toString(), style: tsCodeDisplay1)
      //   ],
      // );
    });
  }
}
