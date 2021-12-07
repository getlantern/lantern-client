import 'package:lantern/messaging/messaging.dart';

class ResetAllFlagsButton extends StatelessWidget {
  const ResetAllFlagsButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return model.getOnBoardingStatus((context, value, child) => Padding(
          padding: const EdgeInsetsDirectional.all(8.0),
          child: Button(
            tertiary: true,
            text: 'DEV - reset flags+timestamps',
            onPressed: () async {
              await model.resetAllFlagsAndTimestamps();
            },
          ),
        ));
  }
}
