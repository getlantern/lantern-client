import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/package_store.dart';
// import 'package:loading_animations/loading_animations.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/ui/widgets/custom_text_field.dart';

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
        if (pastedContactId != null && pastedContactId != '') {
          return;
        }

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
          waitingForOtherSide = false;
        });
        showInfoDialog(context,
            title: 'error'.i18n,
            des: 'contactid_error_description'.i18n,
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
      topColor: Colors.white,
      iconColor: Colors.black,
      context: context,
      title: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('qr_trouble_scanning'.i18n.toUpperCase(),
              style: const TextStyle(fontSize: 20)),
        ],
      ),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.all(20.0),
                      child: Wrap(
                        children: [
                          CustomTextField(
                            enabled: !waitingForOtherSide,
                            controller: contactIdController,
                            label: 'contactid_your_id'.i18n,
                            helperText: 'contactid_paste_id'.i18n,
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: IconButton(
                              onPressed: () => _onContactIdAdd(),
                              icon: Icon(!waitingForOtherSide
                                  ? Icons.keyboard_arrow_right_outlined
                                  : Icons.check_circle),
                              color: waitingForOtherSide ? green : black,
                            ),
                            validator: (value) =>
                                value != '' || value != widget.me.contactId.id
                                    ? null
                                    : 'contactid_input_error'.i18n,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('contactid_your_id'.i18n.toUpperCase(),
                                  style: TextStyle(color: black, fontSize: 10)),
                            ],
                          ),
                          Divider(thickness: 1, color: grey2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showSnackbar(
                                      context: context,
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: Text(
                                            'copied'.i18n,
                                            style: txSnackBarText,
                                            textAlign: TextAlign.left,
                                          )),
                                        ],
                                      ),
                                    );
                                    Clipboard.setData(ClipboardData(
                                        text: widget.me.contactId.id));
                                  },
                                  // TODO: we need to manually wrap this up
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.all(10.0),
                                    child: Text(
                                        widget.me.contactId.id.toUpperCase(),
                                        overflow: TextOverflow.visible,
                                        style: const TextStyle(
                                            fontSize: 16.0, height: 26 / 16)),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    showSnackbar(
                                      context: context,
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: Text(
                                            'copied'.i18n,
                                            style: txSnackBarText,
                                            textAlign: TextAlign.left,
                                          )),
                                        ],
                                      ),
                                    );
                                    Clipboard.setData(ClipboardData(
                                        text: widget.me.contactId.id));
                                  },
                                  icon: CustomAssetImage(
                                    path: ImagePaths.content_copy,
                                    size: 20,
                                    color: black,
                                  ))
                            ],
                          ),
                          Divider(thickness: 1, color: grey2),
                        ],
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
