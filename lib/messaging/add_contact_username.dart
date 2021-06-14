import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/package_store.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AddViaUsername extends StatefulWidget {
  @override
  _AddViaUsernameState createState() => _AddViaUsernameState();
}

class _AddViaUsernameState extends State<AddViaUsername> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'Contact Form');

  TextEditingController contactId = TextEditingController();
  TextEditingController displayName = TextEditingController();

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
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: contactId,
                    minLines: 2,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Messenger ID'.i18n,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.length != 52) {
                        return 'Please enter a 52 digit Messenger ID'.i18n;
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: displayName,
                    decoration: InputDecoration(
                      labelText: 'Name'.i18n,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name for this contact'.i18n;
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              context.loaderOverlay.show();
                              try {
                                await model.addOrUpdateDirectContact(
                                    contactId.value.text,
                                    displayName.value.text);
                                // Navigator.pushNamedAndRemoveUntil(
                                //     context, 'conversations', (r) => false);
                                Navigator.pop(context);
                              } finally {
                                context.loaderOverlay.hide();
                              }
                            }
                          },
                          child: Text('Continue'.i18n),
                        ),
                      ]),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
