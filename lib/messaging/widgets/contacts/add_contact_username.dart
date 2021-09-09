import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/button.dart';
import 'package:lantern/ui/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:auto_route/auto_route.dart';

class AddViaUsername extends StatefulWidget {
  @override
  _AddViaUsernameState createState() => _AddViaUsernameState();
}

class _AddViaUsernameState extends State<AddViaUsername> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'username_form');
  Contact? contact;

  late final usernameController = CustomTextEditingController(
    formKey: _formKey,
    validator: (value) =>
        value != '' ? null : 'Please enter a valid username'.i18n,
  );

  @override
  Widget build(BuildContext context) {
    return fullScreenDialogLayout(
        topColor: Colors.white,
        iconColor: Colors.black,
        context: context,
        title: const Text('Add via username'),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.all(20.0),
                      child: Wrap(
                        children: [
                          CustomTextField(
                            controller: usernameController,
                            label: 'Username'.i18n,
                            helperText:
                                'Enter a username to start a message conversation'
                                    .i18n,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.all(20.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Button(
                              width: 200,
                              text: 'Start Message'.i18n,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  context.loaderOverlay.show();
                                  try {
                                    await context.pushRoute(Conversation(
                                        contactId: contact!.contactId));
                                  } finally {
                                    context.loaderOverlay.hide();
                                  }
                                }
                              },
                            ),
                          ]),
                    )
                  ]),
            ),
          ],
        ));
  }
}
