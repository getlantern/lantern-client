import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/call_action.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';
import 'show_block_contact_dialog.dart';
import 'show_delete_contact_dialog.dart';

class ContactInfo extends StatefulWidget {
  final MessagingModel model;
  final Contact contact;

  ContactInfo({required this.model, required this.contact}) : super();

  @override
  _ContactInfoState createState() => _ContactInfoState(model, contact);
}

class _ContactInfoState extends State<ContactInfo> {
  final MessagingModel model;
  late Contact contact;
  late ValueNotifier<Contact?> contactNotifier;
  late void Function() contactListener;

  final formKey = GlobalKey<FormState>();
  var textCopied = false;
  var isEditing = false;
  late final displayNameController =
      CustomTextEditingController(formKey: formKey);

  _ContactInfoState(this.model, Contact contact) : super() {
    contactChanged(contact);
  }

  void contactChanged(Contact newContact) {
    contact = newContact;
    if (!isEditing) {
      displayNameController.text = contact.displayName;
    }
  }

  @override
  void initState() {
    super.initState();
    contactNotifier = model.contactNotifier(contact.contactId.id);
    contactListener = () async {
      if (contactNotifier.value != null) {
        setState(() => contactChanged(contactNotifier.value!));
      }
    };
    contactNotifier.addListener(contactListener);
  }

  @override
  void dispose() {
    displayNameController.dispose();
    contactNotifier.removeListener(contactListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isExpanded = false;
    return BaseScreen(
      resizeToAvoidBottomInset: false,
      centerTitle: true,
      title: contact.displayNameOrFallback,
      actions: [
        if (!contact.isMe) CallAction(contact),
        Container(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const CAssetImage(path: ImagePaths.messages),
              onPressed: () async => await context
                  .pushRoute(Conversation(contactId: contact.contactId))),
        )
      ],
      body: ListView(
        physics: defaultScrollPhysics,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*
              * Avatar
              */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                    child: CustomAvatar(
                      messengerId: contact.contactId.id,
                      displayName: contact.displayNameOrFallback,
                      radius: 64,
                      textStyle: tsDisplayBlack,
                    ),
                  ),
                ],
              ),
              /*
              * Display Name
              */
              if (!contact.isMe)
                ListItemFactory.settingsItem(
                  header: 'display_name'.i18n,
                  icon: ImagePaths.user,
                  content: !isEditing
                      ? CText(displayNameController.value.text, style: tsBody1)
                      : TextField(
                          // we don't exactly need the UI and the functionality of CTextField but can change
                          controller: displayNameController,
                          style: tsBody1,
                          focusNode: displayNameController.focusNode,
                          decoration: InputDecoration(
                              filled: isEditing,
                              fillColor: isEditing ? grey1 : transparent,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              )),
                          keyboardType: TextInputType.text,
                        ),
                  trailingArray: [
                    TextButton(
                      onPressed: () async {
                        setState(() => isEditing = !isEditing);
                        if (isEditing) {
                          displayNameController.focusNode.requestFocus();
                        }
                        var notifyModel = displayNameController.text !=
                            contact.displayNameOrFallback;
                        if (notifyModel) {
                          try {
                            await model.addOrUpdateDirectContact(
                                unsafeId: contact.contactId.id,
                                displayName: displayNameController.text);
                          } catch (e, s) {
                            showErrorDialog(context,
                                e: e, s: s, des: 'save_error'.i18n);
                          } finally {
                            showSnackbar(
                                context: context, content: 'Saved'.i18n);
                          }
                        }
                      },
                      child: CText(
                        isEditing
                            ? 'save'.i18n.toUpperCase()
                            : 'edit'.i18n.toUpperCase(),
                        style: tsButtonPink,
                      ),
                    )
                  ],
                ),
              StatefulBuilder(
                builder: (context, setState) {
                  return ListItemFactory.settingsItem(
                    header: 'secure_chat_number'.i18n,
                    // onTap: () async =>
                    //     doCopyText(context, contact.chatNumber.number, setState),
                    icon: ImagePaths.chatNumber,
                    content: isExpanded
                        ? Padding(
                            padding: const EdgeInsetsDirectional.only(top: 6.0),
                            child: FullChatNumberWidget(
                                context, contact.chatNumber),
                          )
                        : CText(
                            contact.chatNumber.shortNumber.formattedChatNumber,
                            style: tsSubtitle1Short,
                          ),
                    trailingArray: [
                      CInkWell(
                        onTap: () => setState(() => isExpanded = !isExpanded),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 20.0),
                          child: CAssetImage(
                            path: isExpanded
                                ? ImagePaths.arrow_up
                                : ImagePaths.arrow_down,
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
              /*
                * More Options
                */
              if (!contact.isMe)
                ListItemFactory.settingsItem(
                    header: 'more_options'.i18n,
                    content: CText(
                      contact.blocked ? 'unblock_user'.i18n : 'block_user'.i18n,
                      style: tsSubtitle1Short,
                    ),
                    trailingArray: [
                      TextButton(
                        onPressed: () async => showBlockContactDialog(
                          context,
                          contact,
                          model,
                        ),
                        child: CText(
                          contact.blocked
                              ? 'unblock'.i18n.toUpperCase()
                              : 'block'.i18n.toUpperCase(),
                          style: tsButtonPink,
                        ),
                      )
                    ]),
              if (!contact.isMe)
                ListItemFactory.settingsItem(
                  content: CText(
                    'delete_permanently'.i18n,
                    style: tsSubtitle1Short,
                  ),
                  trailingArray: [
                    TextButton(
                      onPressed: () async => showDeleteContactDialog(
                        context,
                        contact,
                        model,
                      ),
                      child: CText(
                        'delete_contact'.i18n.toUpperCase(),
                        style: tsButtonPink,
                      ),
                    )
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void doCopyText(
      BuildContext context, String copyThis, Function setState) async {
    copyText(context, copyThis);
    setState(() => textCopied = true);
    await Future.delayed(
        longAnimationDuration, () => setState(() => textCopied = false));
  }
}
