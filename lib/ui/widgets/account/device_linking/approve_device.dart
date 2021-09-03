import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_pin_field.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ApproveDevice extends StatelessWidget {
  ApproveDevice({Key? key}) : super(key: key);

  final pinCodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Widget explanationStep({required String icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsetsDirectional.only(end: 16),
          child: CustomAssetImage(
            path: icon,
            size: 24,
            color: Colors.black,
          ),
        ),
        Flexible(
          child: Text(
            text,
            style: tsExplanation,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return sessionModel.emailAddress(
        (BuildContext context, String emailAddress, Widget? child) {
      return BaseScreen(
        title: 'Add Device'.i18n,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsetsDirectional.only(top: 32, bottom: 6),
                  alignment: Alignment.center,
                  child: Text(
                    'Enter or paste device linking PIN'.i18n.toUpperCase(),
                    style: tsPinLabel,
                  ),
                ),
                CustomPinField(
                  length: 6,
                  controller: pinCodeController,
                  onDone: (code) {
                    context.loaderOverlay.show();
                    sessionModel.approveDevice(code).then((value) {
                      pinCodeController.text = '';
                      context.loaderOverlay.hide();
                      Navigator.pop(context);
                    }).onError((error, stackTrace) {
                      pinCodeController.text = '';
                      context.loaderOverlay.hide();
                    });
                  },
                ),
                CustomDivider(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(bottom: 16),
                  child: explanationStep(
                      icon: ImagePaths.number_1,
                      text: 'approve_device_step_1'.i18n),
                ),
                explanationStep(
                    icon: ImagePaths.number_2,
                    text: 'approve_device_step_2'.i18n),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
