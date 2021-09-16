import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/account/account.dart';
import 'package:lantern/common/ui/button.dart';
import 'package:lantern/common/ui/custom/text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';

class DisplayName extends StatelessWidget {
  final Contact me;
  final formKey = GlobalKey<FormState>();
  late final displayNameController =
      CustomTextEditingController(formKey: formKey);

  DisplayName({Key? key, required this.me}) : super(key: key) {
    displayNameController.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    var messagingModel = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'change_display_name'.i18n,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsetsDirectional.only(top: 32),
                child: CTextField(
                  controller: displayNameController,
                  initialValue: me.displayName,
                  label: 'display_name_label'.i18n,
                  helperText: 'display_name_helper'.i18n,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(
                    Icons.account_circle,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsetsDirectional.only(bottom: 32),
                child: Button(
                  width: 200,
                  text: 'Submit'.i18n,
                  onPressed: () async {
                    context.loaderOverlay.show();
                    try {
                      final name = displayNameController.value.text;
                      await messagingModel.setMyDisplayName(name);
                      Navigator.pop(context);
                    } catch (e) {
                      displayNameController.error = 'display_name_invalid'.i18n;
                    } finally {
                      context.loaderOverlay.hide();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
