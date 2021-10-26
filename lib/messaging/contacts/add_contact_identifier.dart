import 'package:lantern/messaging/messaging.dart';

class AddViaIdentifier extends StatefulWidget {
  @override
  _AddViaIdentifierState createState() => _AddViaIdentifierState();
}

class _AddViaIdentifierState extends State<AddViaIdentifier> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'contactIdInput');
  late final contactIdController = CustomTextEditingController(
      formKey: _formKey,
      validator: (value) => value == null ||
              value.isEmpty ||
              value ==
                  'Kalli' // TODO: Button should only become active after our minumum username length of 2 character
          ? 'contact_id_error_description'
              .i18n // TODO: we should differentiate between messenger ID and username
          : null);

  var hasError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    contactIdController.dispose();
    super.dispose();
  }

  void handleButtonPress() async {
    // checking if the input field is not empty
    if (_formKey.currentState!.validate()) {
      // TODO: talk to model and add contact

      // TODO: direct to Conversation view
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: 'add_contact'.i18n,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Form(
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
                                  autovalidateMode: AutovalidateMode.disabled,
                                  label: 'contact_id_messenger_id'.i18n,
                                  prefixIcon: const CAssetImage(
                                      path: ImagePaths.people),
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
                Container(
                  margin: const EdgeInsetsDirectional.only(bottom: 32),
                  child: Button(
                    width: 200,
                    text: 'start_chat'.i18n,
                    onPressed: () {
                      handleButtonPress();
                      FocusScope.of(context).unfocus();
                    },
                    // disabled: _formKey.currentState!.validate(),
                    disabled: hasError || _formKey.currentState!.validate(),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
