import 'package:lantern/messaging/messaging.dart';

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
        value != '' ? null : 'please_enter_a_valid_username'.i18n,
  );

  @override
  Widget build(BuildContext context) {
    return fullScreenDialogLayout(
        topColor: Colors.white,
        iconColor: Colors.black,
        context: context,
        title: Text('add_via_username'.i18n),
        onCloseCallback: () {},
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
                            label: 'username'.i18n,
                            helperText:
                                'enter_a_username_to_start_a_conversation'.i18n,
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
                              text: 'start_message'.i18n,
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
