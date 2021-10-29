import 'package:lantern/messaging/messaging.dart';

class AddViaIdentifier extends StatefulWidget {
  @override
  _AddViaIdentifierState createState() => _AddViaIdentifierState();
}

class _AddViaIdentifierState extends State<AddViaIdentifier> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'contactIdInput');
  late final contactIdController = CustomTextEditingController(
      formKey: _formKey, validator: (value) => validateInput(value));
  var shouldSubmit = false;
  var noMatch = false;
  var identifierToAdd = '';

  @override
  void initState() {
    super.initState();
    contactIdController.focusNode.requestFocus();
  }

  @override
  void dispose() {
    contactIdController.dispose();
    super.dispose();
  }

  void handleButtonPress(MessagingModel model) async {
    contactIdController.focusNode.unfocus();
    setState(() => noMatch = false);
    if (_formKey.currentState?.validate() == true) {
      try {
        // TODO: search for a contact with this messenger ID
        context.loaderOverlay.show(widget: spinner);
      } catch (e) {
        setState(() => noMatch = true);
      } finally {
        context.loaderOverlay.hide();
      }

      if (!noMatch) {
        await model.addProvisionalContact(identifierToAdd, 'id', 'UNVERIFIED');
        // TODO: direct to Conversation view
      }
    }
  }

  String? validateInput(String? value) {
    // input is invalid
    if (value == null ||
        value.isEmpty ||
        value.length < 2 ||
        isValidUsername(value) ||
        isValidMessengerID(value)) {
      return 'contact_id_validation_general'.i18n;
    }
    // input is valid
    return null;
  }

  bool isValidUsername(String value) {
    var pattern = r'(^[a-z][a-z0-9\-]{2,28}[a-z0-9]$)';
    var regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool isValidMessengerID(String value) {
    // TODO: pull isSanitizedContactId from messaging-android
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
      title: 'add_contact'.i18n,
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Form(
                onChanged: () => setState(
                    () => shouldSubmit = _formKey.currentState!.validate()),
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 24.0, top: 60, end: 24.0),
                        child: Wrap(
                          children: [
                            CTextField(
                              controller: contactIdController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              label: 'contact_id_messenger_id'.i18n,
                              prefixIcon:
                                  const CAssetImage(path: ImagePaths.people),
                              hintText: 'contact_id_type'.i18n,
                              keyboardType: TextInputType.text,
                              maxLines: null,
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
            ),
            if (noMatch)
              const Expanded(
                  child: Center(
                child: Text('[Dev note] Could not find a match'),
              )),
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: 32),
              child: Button(
                width: 200,
                text: 'start_chat'.i18n,
                onPressed: () => handleButtonPress(model),
                disabled: !shouldSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
