import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
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
    var model = context.watch<MessagingModel>();
    var size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.white,
      width: size.width,
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Form(
            key: _formKey,
            child: Column(children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                child: CustomTextField(
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
                        setState(() {
                          // TODO: missing
                          contact = model.getContactFromUsername(
                              usernameController.value.text) as Contact;
                        });
                      } catch (e) {
                        return 'An error occurred while searching for this username'
                            .i18n;
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Button(
                    width: 200,
                    text: 'Start Message'.i18n,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        context.loaderOverlay.show();
                        try {
                          await context
                              .pushRoute(Conversation(contact: contact!));
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
      ),
    );
  }
}
