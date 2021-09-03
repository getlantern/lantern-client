import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/button.dart';
import 'package:lantern/ui/widgets/custom_text_field.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

class AddViaContactId extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddViaContactId();
  }
}

class AddViaContactIdBody extends StatefulWidget {
  final Contact me;

  AddViaContactIdBody(this.me) : super();

  @override
  _AddViaContactIdBodyState createState() => _AddViaContactIdBodyState();
}

class _AddViaContactIdBodyState extends State<AddViaContactIdBody> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'contactIdInput');
  String? pastedContactId;
  late MessagingModel model;
  TextEditingController contactIdController = TextEditingController();
  bool waitingForOtherSide = false;

  void _onContactIdAdd() async {
    // checking if the input field is not empty
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          pastedContactId = contactIdController.value.text;
          waitingForOtherSide = true;
        });
        var mostRecentHelloTs =
            await model.addProvisionalContact(pastedContactId!);
        var contactNotifier = model.contactNotifier(pastedContactId!);
        late void Function() listener;
        listener = () async {
          var updatedContact = contactNotifier.value;
          if (updatedContact != null &&
              updatedContact.mostRecentHelloTs > mostRecentHelloTs) {
            contactNotifier.removeListener(listener);
            // go back to New Message with the updatedContact info
            Navigator.pop(context, updatedContact);
          }
        };
        contactNotifier.addListener(listener);
        // immediately invoke listener in case the contactNotifier already has
        // an up-to-date contact.
        listener();
      } catch (e) {
        setState(() {
          pastedContactId = '';
        });
        contactIdController.text = '';
        showInfoDialog(context,
            title: 'Error'.i18n,
            des: 'Something went wrong while adding this contact'.i18n,
            icon: ImagePaths.alert_icon,
            buttonText: 'OK'.i18n);
      }
    }
  }

  @override
  void dispose() {
    contactIdController.dispose();
    if (pastedContactId != null && pastedContactId != '') {
      // when exiting this screen, immediately delete any provisional contact
      model.deleteProvisionalContact(pastedContactId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();
    return fullScreenDialogLayout(
      Colors.white,
      Colors.black,
      context,
      Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Wrap(
                      children: [
                        CustomTextField(
                          controller: contactIdController,
                          enabled: !waitingForOtherSide,
                          label: 'user id'.i18n,
                          helperText: 'Add contact via user id'.i18n,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          validator: (value) => value != ''
                              ? null
                              : 'Please enter a valid contact id'.i18n,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your contact id'.i18n,
                            style: const TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.w500)),
                        ListTile(
                          title: Text(widget.me.contactId.id),
                          tileColor: Colors.black12,
                          onTap: () {
                            showSnackbar(
                              context: context,
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text(
                                    'ID Copied'.i18n,
                                    style: txSnackBarText,
                                    textAlign: TextAlign.left,
                                  )),
                                ],
                              ),
                            );
                            Clipboard.setData(
                                ClipboardData(text: widget.me.contactId.id));
                          },
                          trailing: const Icon(Icons.copy_all_outlined),
                        ),
                      ],
                    ),
                  ),
                  if (!waitingForOtherSide)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Button(
                              width: 200,
                              text: 'Add Contact'.i18n,
                              onPressed: () => _onContactIdAdd(),
                            ),
                          ]),
                    ),
                ]),
          ),
          if (waitingForOtherSide)
            Expanded(
              flex: 1,
              child: LoadingBouncingGrid.square(
                borderColor: primaryPink,
                borderSize: 1.0,
                size: 100.0,
                backgroundColor: primaryPink,
                duration: const Duration(milliseconds: 1000),
              ),
            )
        ],
      ),
    );
  }
}
