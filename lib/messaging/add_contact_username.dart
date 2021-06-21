import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/button.dart';
import 'package:lantern/ui/widgets/custom_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';

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

    return BaseScreen(
      title: 'Add Contact'.i18n,
      actions: [
        IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Your Contact Info'.i18n,
            onPressed: () {
              Navigator.restorablePushNamed(context, '/your_contact_info');
            }),
      ],
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.loaderOverlay.show();
                      try {
                        Navigator.pushNamed(context, '/conversation',
                            arguments: contact);
                        // Navigator.pop(context);
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
      ),
    );
  }
}
