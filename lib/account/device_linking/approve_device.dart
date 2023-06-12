import 'package:lantern/common/common.dart';
import 'explanation_step.dart';

class ApproveDevice extends StatelessWidget {
  ApproveDevice({Key? key}) : super(key: key);

  final pinCodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return sessionModel.emailAddress(
        (BuildContext context, String emailAddress, Widget? child) {
      return BaseScreen(
        title: 'Link Device'.i18n,
        body: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsetsDirectional.only(top: 32, bottom: 6),
                alignment: Alignment.center,
                child: CText(
                  'Enter or paste device linking PIN'.i18n.toUpperCase(),
                  style: tsOverline,
                ),
              ),
              PinField(
                length: 6,
                controller: pinCodeController,
                onDone: (code) {
                  context.loaderOverlay.show(widget: spinner);
                  sessionModel.approveDevice(code).then((value) {
                    pinCodeController.clear();
                    context.loaderOverlay.hide();
                    Navigator.pop(context);
                  }).onError((error, stackTrace) {
                    pinCodeController.clear();
                    context.loaderOverlay.hide();
                  });
                },
              ),
              LabeledDivider(
                padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(bottom: 16),
                child: ExplanationStep(
                    ImagePaths.number_1, 'approve_device_step_1'.i18n),
              ),
              ExplanationStep(
                  ImagePaths.number_2, 'approve_device_step_2'.i18n),
              const Spacer(),
            ],
          ),
        ),
      );
    });
  }
}
