import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging_model.dart';

Future showConversationOptions(
    {required MessagingModel model,
    required BuildContext parentContext,
    required Contact contact}) {
  return showModalBottomSheet(
      context: parentContext,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      builder: (bottomContext) => Wrap(
            alignment: WrapAlignment.center,
            children: [
              BottomModalItem(
                leading: const CAssetImage(
                  path: ImagePaths.timer,
                ),
                label: 'disappearing_messages'.i18n,
                onTap: () async {
                  final scrollController = ScrollController();
                  final seconds = <int>[
                    5,
                    60,
                    3600,
                    10800,
                    21600,
                    86400,
                    604800,
                    0
                  ];
                  var selectedPosition = -1;

                  return showDialog(
                    context: bottomContext,
                    barrierDismissible: true,
                    barrierColor: black.withOpacity(0.8),
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        contentPadding: const EdgeInsetsDirectional.all(0),
                        clipBehavior: Clip.hardEdge,
                        content: ConstrainedBox(
                          constraints: disappearingDialogConstraints(context),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 16.0),
                                color: white,
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    CText(
                                      'disappearing_messages'.i18n,
                                      style: tsBody3,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 16.0,
                                          end: 16.0,
                                          top: 24.0,
                                          bottom: 24.0),
                                      child:
                                          contact.messagesDisappearAfterSeconds ==
                                                      0 ||
                                                  (selectedPosition != -1 &&
                                                      seconds[selectedPosition] ==
                                                          0)
                                              ? CTextWrap(
                                                  'message_disappearing'.i18n,
                                                  style: tsBody1.copiedWith(
                                                      color: grey5),
                                                )
                                              : CTextWrap(
                                                  'message_disappearing_description'
                                                      .i18n
                                                      .fill([
                                                    selectedPosition != -1
                                                        ? seconds[
                                                                selectedPosition]
                                                            .humanizeSeconds(
                                                                longForm: true)
                                                        : contact
                                                            .messagesDisappearAfterSeconds
                                                            .humanizeSeconds(
                                                                longForm: true)
                                                  ]),
                                                  style: tsBody1.copiedWith(
                                                      color: grey5),
                                                ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              CDivider(
                                thickness: 1,
                                color: grey3,
                                size: 2,
                                margin: 16,
                              ),
                              Flexible(
                                child: LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    // set the height so that one of the rows
                                    // gets cut in half, to help give the user a
                                    // visual cue that they can scroll
                                    final maxHeight =
                                        constraints.maxHeight / 48 * 48 - 24;
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: maxHeight,
                                      ),
                                      child: Scrollbar(
                                        controller: scrollController,
                                        interactive: true,
                                        isAlwaysShown: true,
                                        showTrackOnHover: true,
                                        radius: const Radius.circular(50),
                                        child: ListView.builder(
                                          controller: scrollController,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          physics: defaultScrollPhysics,
                                          itemCount: seconds.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .only(),
                                              horizontalTitleGap: 8,
                                              minLeadingWidth: 20,
                                              onTap: () async {
                                                setState(() {
                                                  selectedPosition = index;
                                                });
                                              },
                                              selectedTileColor: Colors.white,
                                              tileColor: const Color.fromRGBO(
                                                  245, 245, 245, 1),
                                              selected: selectedPosition != -1
                                                  ? seconds[index] !=
                                                      seconds[selectedPosition]
                                                  : contact
                                                          .messagesDisappearAfterSeconds !=
                                                      seconds[index],
                                              leading: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .only(start: 8),
                                                child: Transform.scale(
                                                  scale: 1.2,
                                                  child: Radio(
                                                    value: selectedPosition !=
                                                            -1
                                                        ? seconds[index] !=
                                                            seconds[
                                                                selectedPosition]
                                                        : contact
                                                                .messagesDisappearAfterSeconds !=
                                                            seconds[index],
                                                    groupValue: false,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (states) =>
                                                          states.contains(
                                                                  MaterialState
                                                                      .selected)
                                                              ? pink4
                                                              : black,
                                                    ),
                                                    activeColor: pink4,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        selectedPosition =
                                                            index;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              title: Transform.translate(
                                                offset: const Offset(-4, 0),
                                                child: CText(
                                                  seconds[index] == 0
                                                      ? 'off'.i18n
                                                      : seconds[index]
                                                          .humanizeSeconds(
                                                              longForm: true),
                                                  style: tsBody1,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    const CDivider(
                                      thickness: 1,
                                      color: Color.fromRGBO(235, 235, 235, 1),
                                      size: 1,
                                      margin: 16,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsetsDirectional
                                                        .only(
                                                    top: 16,
                                                    bottom: 16,
                                                    end: 16)),
                                          ),
                                          onPressed: () async =>
                                              context.router.pop(),
                                          child: CText(
                                              'cancel'.i18n.toUpperCase(),
                                              style: tsButtonGrey),
                                        ),
                                        TextButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsetsDirectional
                                                        .only(
                                                    top: 16,
                                                    bottom: 16,
                                                    end: 24)),
                                          ),
                                          onPressed: () async {
                                            if (selectedPosition != -1) {
                                              await model.setDisappearSettings(
                                                  contact,
                                                  seconds[selectedPosition]);
                                            }
                                            await context.router.pop();
                                            await parentContext.router.pop();
                                          },
                                          child: CText('set'.i18n.toUpperCase(),
                                              style: tsButtonPink),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              BottomModalItem(
                leading: const CAssetImage(
                  path: ImagePaths.people,
                ),
                label: 'introduce_contacts'.i18n,
                onTap: () async =>
                    await bottomContext.pushRoute(const Introduce()),
              ),
              BottomModalItem(
                  leading: const CAssetImage(
                    path: ImagePaths.trash,
                  ),
                  label: 'delete_contact_name'.i18n.fill([contact.displayName]),
                  onTap: () => showDialog<void>(
                        context: bottomContext,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.delete),
                                ),
                                CText('delete_contact'.i18n.toUpperCase(),
                                    style: tsBody3),
                              ],
                            ),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  CTextWrap('delete_contact_confirmation'.i18n,
                                      style: tsBody1)
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
                                      context.loaderOverlay.show(
                                          widget: Center(
                                        child: CircularProgressIndicator(
                                          color: white,
                                        ),
                                      ));
                                      try {
                                        await model.deleteDirectContact(
                                            contact.contactId.id);
                                      } catch (e, s) {
                                        showErrorDialog(context,
                                            e: e,
                                            s: s,
                                            des: 'error_delete_contact'.i18n);
                                      } finally {
                                        context.loaderOverlay.hide();
                                        // In order to be capable to return to the root screen, we need to pop the bottom sheet
                                        // and then pop the root screen.
                                        context.router.popUntilRoot();
                                        parentContext.router.popUntilRoot();
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
                      )),
            ],
          ));
}

BoxConstraints disappearingDialogConstraints(BuildContext context) {
  var size = MediaQuery.of(context).size;
  // limit the width of the dialog on really wide screens
  var width = min(size.width * 0.9, 304.0);

  // note - minWidth and maxWidth have to equal to avoid layout errors on wide
  // screens.
  return BoxConstraints(
    maxHeight: size.height * 0.9,
    minWidth: width,
    maxWidth: width,
  );
}
