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
  final _formKey = GlobalKey<FormState>(debugLabel: 'Contact Form');
  Contact? contact;

  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return fullScreenDialogLayout(Colors.white, Colors.black, context, [
      Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              children: [
                CustomTextField(
                    controller: usernameController,
                    label: 'Username'.i18n,
                    helperText:
                        'Enter a username to start a message conversation'.i18n,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    validator: (value) {
                      try {
                        // get contact from username
                      } catch (e) {
                        return 'An error occurred while searching for this username'
                            .i18n;
                      }
                    }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Button(
                width: 200,
                text: 'Start Message'.i18n,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    context.loaderOverlay.show();
                    try {
                      await context.pushRoute(Conversation(contact: contact!));
                    } finally {
                      context.loaderOverlay.hide();
                    }
                  }
                },
              ),
            ]),
          )
        ]),
      )
    ]);
  }
}
