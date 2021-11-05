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
    });
  }
}
