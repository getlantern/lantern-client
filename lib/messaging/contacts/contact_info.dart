import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/call_action.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';

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
  var confirmBlock = false;
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
      setState(() => contactChanged(contactNotifier.value!));
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
    return BaseScreen(
      resizeToAvoidBottomInset: false,
      centerTitle: true,
      title: contact.displayNameOrFallback,
      actions: [
        CallAction(contact),
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
                        radius: 64),
                  ),
                ],
              ),
              /*
                * Display Name
                */
              ListSectionHeader('display_name'.i18n),
              CListTile(
                leading: const CAssetImage(
                  path: ImagePaths.user,
                ),
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
                trailing: CInkWell(
                  onTap: () async {
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
                        showSnackbar(context: context, content: 'Saved'.i18n);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: CText(
                      isEditing
                          ? 'save'.i18n.toUpperCase()
                          : 'edit'.i18n.toUpperCase(),
                      style: tsButtonPink,
                    ),
                  ),
                ),
              ),
              ListSectionHeader('messenger_id'.i18n),
              StatefulBuilder(
                builder: (context, setState) => CListTile(
                  onTap: () async =>
                      doCopyText(context, contact.contactId.id, setState),
                  leading: const CAssetImage(
                    path: ImagePaths.user,
                  ),
                  content: CText(
                    contact.contactId.id,
                    style: tsSubtitle1Short,
                  ),
                  trailing: CInkWell(
                    onTap: () async =>
                        doCopyText(context, contact.contactId.id, setState),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 10.0),
                      child: CAssetImage(
                        path: textCopied
                            ? ImagePaths.check_green
                            : ImagePaths.content_copy_outline,
                      ),
                    ),
                  ),
                ),
              ),
              /*
                * More Options
                */
              ListSectionHeader('more_options'.i18n),
              CListTile(
                  leading: const CAssetImage(
                    path: ImagePaths.user,
                  ),
                  content: CText(
                    contact.blocked ? 'unblock_user'.i18n : 'block_user'.i18n,
                    style: tsSubtitle1Short,
                  ),
                  trailing: CInkWell(
                    onTap: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(0),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CAssetImage(path: ImagePaths.block),
                              ),
                              CText(
                                  contact.blocked
                                      ? '${'unblock'.i18n} ${contact.displayNameOrFallback}?'
                                      : '${'block'.i18n} ${contact.displayNameOrFallback}?',
                                  style: tsBody3),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsetsDirectional.all(24),
                                  child: CText(
                                      contact.blocked
                                          ? 'unblock_info_description'.i18n
                                          : 'block_info_description'.i18n,
                                      style: tsBody1),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 8.0, end: 8.0),
                                  child: Row(
                                    children: [
                                      StatefulBuilder(
                                          builder: (context, setState) =>
                                              Checkbox(
                                                  checkColor: Colors.white,
                                                  fillColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                              getCheckboxColor),
                                                  value: confirmBlock,
                                                  onChanged: (bool? value) {
                                                    setState(() =>
                                                        confirmBlock = value!);
                                                  })),
                                      Container(
                                        // not sure why our overflow doesnt work here...
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6),
                                        child: CText(
                                            contact.blocked
                                                ? 'unblock_info_checkbox'.i18n
                                                : 'block_info_checkbox'.i18n,
                                            style: tsBody1),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async => context.router.pop(),
                                  child: CText('cancel'.i18n.toUpperCase(),
                                      style: tsButtonGrey),
                                ),
                                const SizedBox(width: 15),
                                TextButton(
                                  onPressed: () async {
                                    if (confirmBlock) {
                                      contact.blocked
                                          ? await model.unblockDirectContact(
                                              widget.contact.contactId.id)
                                          : await model.blockDirectContact(
                                              widget.contact.contactId.id);
                                      context.router.popUntilRoot();
                                      showSnackbar(
                                          context: context,
                                          content: contact.blocked
                                              ? 'contact_was_unblocked'
                                                  .i18n
                                                  .fill([
                                                  contact.displayNameOrFallback
                                                ])
                                              : 'contact_was_blocked'
                                                  .i18n
                                                  .fill([
                                                  contact.displayNameOrFallback
                                                ]));
                                    }
                                  },
                                  child: CText(
                                      contact.blocked
                                          ? 'unblock'.i18n.toUpperCase()
                                          : 'block'.i18n.toUpperCase(),
                                      style: tsButtonPink),
                                )
                              ],
                            )
                          ],
                        );
                      },
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: CText(
                        contact.blocked
                            ? 'unblock'.i18n.toUpperCase()
                            : 'block'.i18n.toUpperCase(),
                        style: tsButtonPink,
                      ),
                    ),
                  )),
              const CDivider(),
              CListTile(
                leading: const CAssetImage(
                  path: ImagePaths.user,
                ),
                content: CText(
                  'delete_permanently'.i18n,
                  style: tsSubtitle1Short,
                ),
                trailing: CInkWell(
                  onTap: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CAssetImage(path: ImagePaths.delete),
                            ),
                            CText('${'delete_contact'.i18n.toUpperCase()}?',
                                style: tsBody3),
                          ],
                        ),
                        content: CText('delete_info_description'.i18n,
                            style: tsBody1),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () async => context.router.pop(),
                                child: CText('cancel'.i18n.toUpperCase(),
                                    style: tsButtonGrey),
                              ),
                              const SizedBox(width: 15),
                              TextButton(
                                onPressed: () async {
                                  context.loaderOverlay.show(widget: spinner);
                                  try {
                                    await model.deleteDirectContact(
                                        contact.contactId.id);
                                  } catch (e, s) {
                                    showErrorDialog(context,
                                        e: e,
                                        s: s,
                                        des: 'error_delete_contact'.i18n);
                                  } finally {
                                    showSnackbar(
                                        context: context,
                                        content: 'contact_was_deleted'
                                            .i18n
                                            .fill([
                                          contact.displayNameOrFallback
                                        ]));
                                    context.loaderOverlay.hide();
                                    context.router.popUntilRoot();
                                  }
                                },
                                child: CText(
                                    'delete_contact'.i18n.toUpperCase(),
                                    style: tsButtonPink),
                              )
                            ],
                          )
                        ],
                      );
                    },
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: CText(
                      'delete'.i18n.toUpperCase(),
                      style: tsButtonPink,
                    ),
                  ),
                ),
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
        defaultAnimationDuration, () => setState(() => textCopied = false));
  }
}
