import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/package_store.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AddContactById extends StatefulWidget {
  @override
  _AddContactByIdState createState() {
    return _AddContactByIdState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class _AddContactByIdState extends State<AddContactById> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    TextEditingController contactId = TextEditingController();
    TextEditingController displayName = TextEditingController();

    return Form(
      key: _formKey,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextFormField(
            controller: contactId,
            minLines: 2,
            maxLines: null,
            decoration: InputDecoration(
              labelText: 'Messenger ID'.i18n,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value.length != 52) {
                return 'Please enter a 52 digit Messenger ID'.i18n;
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: TextFormField(
            controller: displayName,
            decoration: InputDecoration(
              labelText: 'Name'.i18n,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a name for this contact'.i18n;
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
              child: Text('Continue'.i18n),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  context.showLoaderOverlay();
                  try {
                    await model.addOrUpdateContact(
                        contactId.value.text, displayName.value.text);
                    Navigator.pushNamedAndRemoveUntil(
                        context, 'conversations', (r) => false);
                  } finally {
                    context.hideLoaderOverlay();
                  }
                }
              }),
        )
      ]),
    );
  }
}
