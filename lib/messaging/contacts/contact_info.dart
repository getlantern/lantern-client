import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/call_action.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';

class ContactInfo extends StatefulWidget {
  final Contact contact;

  ContactInfo({Key? key, required this.contact}) : super();

  @override
  _ContactInfoState createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  final formKey = GlobalKey<FormState>();
  var textCopied = false;
  var confirmBlock = false;
  var isEditing = false;
  late final displayNameController = CustomTextEditingController(
      formKey: formKey, text: widget.contact.displayNameOrFallback);
  ValueNotifier<Contact?>? contactNotifier;
  void Function()? listener;
  Contact? updatedContact;
  var newDisplayName;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    if (listener != null) {
      contactNotifier?.removeListener(listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    // TODO: repeated pattern
    // listen to the contact path for changes
    // will return a Contact if there are any, otherwise null
    contactNotifier = model.contactNotifier(widget.contact.contactId.id);

    var listener = () async {
      // something changed for this contact, lets get the updates
      updatedContact = contactNotifier!.value as Contact;
      if (updatedContact != null && mounted) {
        setState(() {
          newDisplayName = updatedContact!.displayNameOrFallback;
        });
      }
    };
    contactNotifier!.addListener(listener);
    listener();

    return BaseScreen(
      resizeToAvoidBottomInset: false,
      centerTitle: true,
      padHorizontal: false,
      title: newDisplayName ?? widget.contact.displayNameOrFallback,
      actions: [
        CallAction(widget.contact),
        Container(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const CAssetImage(path: ImagePaths.messages),
              onPressed: () async => await context.pushRoute(
                  Conversation(contactId: widget.contact.contactId))),
        )
      ],
      body: ListView(
        physics: defaultScrollPhysics,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /*
                * Avatar
                */
                Container(
                  padding:
                      const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                  child: CustomAvatar(
                      messengerId: widget.contact.contactId.id,
                      displayName: newDisplayName ??
                          widget.contact.displayNameOrFallback,
                      radius: 64),
                ),
                /*
                * Display Name - using Wrap since had issues with Row
                */
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 8, top: 21, bottom: 3),
                      child: CText('display_name'.i18n.toUpperCase(),
                          maxLines: 1, style: tsOverline),
                    ),
                    const CDivider(),
                    CListTile(
                      leading: const CAssetImage(
                        path: ImagePaths.user,
                      ),
                      content: !isEditing
                          ? CText(displayNameController.value.text,
                              style: tsBody1)
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
                      trailing: InkWell(
                        focusColor: grey3,
                        onTap: () async {
                          setState(() => isEditing = !isEditing);
                          if (isEditing) {
                            displayNameController.focusNode.requestFocus();
                          }
                          var notifyModel = displayNameController.text !=
                              widget.contact.displayNameOrFallback;
                          if (notifyModel) {
                            try {
                              await model.addOrUpdateDirectContact(
                                  unsafeId: widget.contact.contactId.id,
                                  verificationLevel: widget
                                      .contact.verificationLevel.name
                                      .toString(),
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
                        child: Ink(
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
                  ],
                ),
                /*
                * Username
                */
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 8, top: 21, bottom: 3),
                      child: CText('username - DEPRECATED'.toUpperCase(),
                          maxLines: 1, style: tsOverline),
                    ),
                    const CDivider(),
                    StatefulBuilder(
                        builder: (context, setState) => CListTile(
                              leading: const CAssetImage(
                                path: ImagePaths.user,
                              ),
                              content: CText(
                                '@${newDisplayName ?? widget.contact.displayNameOrFallback}',
                                style: tsSubtitle1Short,
                              ),
                              trailing: InkWell(
                                focusColor: grey3,
                                onTap: () {
                                  copyText(
                                      context,
                                      newDisplayName ??
                                          widget.contact
                                              .displayNameOrFallback); // TODO: this should be username
                                  setState(() => textCopied = true);
                                  Future.delayed(defaultAnimationDuration,
                                      () => setState(() => textCopied = false));
                                },
                                child: CAssetImage(
                                  path: textCopied
                                      ? ImagePaths.check_green
                                      : ImagePaths.content_copy_outline,
                                ),
                              ),
                            )),
                  ],
                ),
                /*
                * Messenger ID
                */
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 8, top: 21, bottom: 3),
                      child: CText('messenger_id'.i18n.toUpperCase(),
                          maxLines: 1, style: tsOverline),
                    ),
                    const CDivider(),
                    StatefulBuilder(
                        builder: (context, setState) => CListTile(
                              leading: const CAssetImage(
                                path: ImagePaths.user,
                              ),
                              content: CText(
                                widget.contact.contactId.id,
                                style: tsSubtitle1Short,
                              ),
                              trailing: InkWell(
                                focusColor: grey3,
                                onTap: () {
                                  copyText(
                                      context, widget.contact.contactId.id);
                                  setState(() => textCopied = true);
                                  Future.delayed(defaultAnimationDuration,
                                      () => setState(() => textCopied = false));
                                },
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 10.0),
                                  child: CAssetImage(
                                    path: textCopied
                                        ? ImagePaths.check_green
                                        : ImagePaths.content_copy_outline,
                                  ),
                                ),
                              ),
                            ))
                  ],
                ),
                /*
                * More Options
                */
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 8, top: 21, bottom: 3),
                      child: CText('more_options'.i18n.toUpperCase(),
                          maxLines: 1, style: tsOverline),
                    ),
                    const CDivider(),
                    CListTile(
                        leading: const CAssetImage(
                          path: ImagePaths.user,
                        ),
                        content: CText(
                          widget.contact.blocked
                              ? 'unblock_user'.i18n
                              : 'block_user'.i18n,
                          style: tsSubtitle1Short,
                        ),
                        trailing: InkWell(
                          focusColor: grey3,
                          onTap: () => showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: const EdgeInsets.all(0),
                                title: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child:
                                          CAssetImage(path: ImagePaths.block),
                                    ),
                                    CText(
                                        widget.contact.blocked
                                            ? '${'unblock'.i18n} ${widget.contact.displayNameOrFallback}?'
                                            : '${'block'.i18n} ${widget.contact.displayNameOrFallback}?',
                                        style: tsBody3),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.all(24),
                                        child: CText(
                                            widget.contact.blocked
                                                ? 'unblock_info_description'
                                                    .i18n
                                                : 'block_info_description'.i18n,
                                            style: tsBody1),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 8.0, end: 8.0),
                                        child: Row(
                                          children: [
                                            StatefulBuilder(
                                                builder: (context, setState) =>
                                                    Checkbox(
                                                        checkColor:
                                                            Colors.white,
                                                        fillColor:
                                                            MaterialStateProperty
                                                                .resolveWith(
                                                                    getCheckboxColor),
                                                        value: confirmBlock,
                                                        onChanged:
                                                            (bool? value) {
                                                          setState(() =>
                                                              confirmBlock =
                                                                  value!);
                                                        })),
                                            Container(
                                              // not sure why our overflow doesnt work here...
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.6),
                                              child: CText(
                                                  widget.contact.blocked
                                                      ? 'unblock_info_checkbox'
                                                          .i18n
                                                      : 'block_info_checkbox'
                                                          .i18n,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () async =>
                                            context.router.pop(),
                                        child: CText(
                                            'cancel'.i18n.toUpperCase(),
                                            style: tsButtonGrey),
                                      ),
                                      const SizedBox(width: 15),
                                      TextButton(
                                        onPressed: () async {
                                          if (confirmBlock) {
                                            widget.contact.blocked
                                                ? await model
                                                    .unblockDirectContact(widget
                                                        .contact.contactId.id)
                                                : await model
                                                    .blockDirectContact(widget
                                                        .contact.contactId.id);
                                            context.router.popUntilRoot();
                                            showSnackbar(
                                                context: context,
                                                content: widget.contact.blocked
                                                    ? 'contact_was_unblocked'
                                                        .i18n
                                                        .fill([
                                                        newDisplayName ??
                                                            widget.contact
                                                                .displayNameOrFallback
                                                      ])
                                                    : 'contact_was_blocked'
                                                        .i18n
                                                        .fill([
                                                        newDisplayName ??
                                                            widget.contact
                                                                .displayNameOrFallback
                                                      ]));
                                          }
                                        },
                                        child: CText(
                                            widget.contact.blocked
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
                          child: Ink(
                            padding: const EdgeInsets.all(8),
                            child: CText(
                              widget.contact.blocked
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
                        trailing: InkWell(
                          focusColor: grey3,
                          onTap: () => showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child:
                                          CAssetImage(path: ImagePaths.delete),
                                    ),
                                    CText(
                                        '${'delete_contact'.i18n.toUpperCase()}?',
                                        style: tsBody3),
                                  ],
                                ),
                                content: CText('delete_info_description'.i18n,
                                    style: tsBody1),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () async =>
                                            context.router.pop(),
                                        child: CText(
                                            'cancel'.i18n.toUpperCase(),
                                            style: tsButtonGrey),
                                      ),
                                      const SizedBox(width: 15),
                                      TextButton(
                                        onPressed: () async {
                                          context.loaderOverlay
                                              .show(widget: spinner);
                                          try {
                                            await model.deleteDirectContact(
                                                widget.contact.contactId.id);
                                          } catch (e, s) {
                                            showErrorDialog(context,
                                                e: e,
                                                s: s,
                                                des: 'error_delete_contact'
                                                    .i18n);
                                          } finally {
                                            showSnackbar(
                                                context: context,
                                                content: 'contact_was_deleted'
                                                    .i18n
                                                    .fill([
                                                  widget.contact
                                                      .displayNameOrFallback
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
                          child: Ink(
                            padding: const EdgeInsets.all(8),
                            child: CText(
                              'delete'.i18n.toUpperCase(),
                              style: tsButtonPink,
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
