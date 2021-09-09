import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';

// import 'package:loading_animations/loading_animations.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_text_field.dart';
import 'package:lantern/ui/widgets/pulse_animation.dart';

import 'add_contact.dart';

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

class _AddViaContactIdBodyState extends AddContactState<AddViaContactIdBody> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'contactIdInput');
  String? enteredContactId;
  late MessagingModel model;
  late final contactIdController = CustomTextEditingController(
      formKey: _formKey,
      validator: (value) => value != '' || value != widget.me.contactId.id
          ? null
          : 'contactid_input_error'.i18n);
  bool waitingForOtherSide = false;

  void _onContactIdAdd() async {
    // checking if the input field is not empty
    if (_formKey.currentState!.validate()) {
      try {
        if (enteredContactId != null && enteredContactId != '') {
          return;
        }

        setState(() {
          enteredContactId = contactIdController.value.text;
          waitingForOtherSide = true;
        });
        var mostRecentHelloTs = await model
            .addProvisionalContact(enteredContactId!.replaceAll('\-', ''));
        waitForContact(model, enteredContactId!, mostRecentHelloTs);
      } catch (e) {
        setState(() {
          enteredContactId = '';
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
    if (enteredContactId != null && enteredContactId != '') {
      // when exiting this screen, immediately delete any provisional contact
      model.deleteProvisionalContact(enteredContactId!);
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
          Text('qr_trouble_scanning'.i18n,
              style: const TextStyle(fontSize: 20)),
        ],
      ),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            if (waitingForOtherSide)
              PulseAnimation(
                Text(
                  'qr_info_waiting_QR'.i18n,
                  style: tsInfoTextBlack,
                ),
              ),
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
                              controller: contactIdController,
                              label: 'contactid_messenger_id'.i18n,
                              helperText: 'contactid_enter_manually'.i18n,
                              keyboardType: TextInputType.text,
                              suffixIcon: IconButton(
                                onPressed: () => _onContactIdAdd(),
                                icon: Icon(!waitingForOtherSide
                                    ? Icons.keyboard_arrow_right_outlined
                                    : Icons.check_circle),
                                color: waitingForOtherSide ? green : black,
                              ),
                              enabled: !waitingForOtherSide,
                              maxLines: null),
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(start: 10),
                                child: Text(
                                  'contactid_your_id'.i18n.toUpperCase(),
                                  style: TextStyle(color: black, fontSize: 10),
                                ),
                              ),
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
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 10.0, end: 10),
                                    child: Text(
                                        humanizeContactId(
                                            widget.me.contactId.id),
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
