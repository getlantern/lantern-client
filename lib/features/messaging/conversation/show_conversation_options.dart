import '../messaging.dart';
import 'show_verification_options.dart';

Future showConversationOptions({
  required BuildContext parentContext,
  required Contact contact,
  Function? topBarAnimationCallback,
}) {
  // Note: we are using showModalBottomSheet directly here because of the complicated double context handling re:disappearing messages
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
        ListItemFactory.bottomItem(
          icon: ImagePaths.user,
          content: 'view_contact_info'.i18n,
          onTap: () async {
            await bottomContext.router.maybePop();
            await bottomContext.pushRoute(ContactInfo(contact: contact));
          },
        ),
        ListItemFactory.bottomItem(
          icon: ImagePaths.timer,
          content: 'disappearing_messages'.i18n,
          onTap: () async {
            final scrollController = ScrollController();
            final seconds = <int>[5, 60, 3600, 10800, 21600, 86400, 604800, 0];
            var selectedPosition = -1;
            await bottomContext.router.maybePop();

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
                          padding: const EdgeInsetsDirectional.only(top: 16.0),
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
                                  bottom: 24.0,
                                ),
                                child: contact.messagesDisappearAfterSeconds ==
                                            0 ||
                                        (selectedPosition != -1 &&
                                            seconds[selectedPosition] == 0)
                                    ? CText(
                                        'message_disappearing'.i18n.fill(
                                          [contact.displayNameOrFallback],
                                        ),
                                        style: tsBody1.copiedWith(
                                          color: grey5,
                                        ),
                                      )
                                    : CText(
                                        'message_disappearing_description'
                                            .i18n
                                            .fill([
                                          selectedPosition != -1
                                              ? seconds[selectedPosition]
                                                  .humanizeSeconds(
                                                  longForm: true,
                                                )
                                              : contact
                                                  .messagesDisappearAfterSeconds
                                                  .humanizeSeconds(
                                                  longForm: true,
                                                ),
                                          contact.displayNameOrFallback
                                        ]),
                                        style: tsBody1.copiedWith(
                                          color: grey5,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        CDivider(
                          thickness: 1,
                          color: grey3,
                          height: 2,
                          margin: 16,
                        ),
                        Flexible(
                          child: LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
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
                                  controller: ScrollController(),
                                  interactive: true,
                                  // TODO: this generates an annoying error https://github.com/flutter/flutter/issues/97873
                                  // thumbVisibility: true,
                                  trackVisibility: true,
                                  radius: const Radius.circular(
                                    scrollBarRadius,
                                  ),
                                  child: ListView.builder(
                                    controller: scrollController,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: defaultScrollPhysics,
                                    itemCount: seconds.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        contentPadding:
                                            const EdgeInsetsDirectional.only(),
                                        horizontalTitleGap: 8,
                                        minLeadingWidth: 20,
                                        onTap: () async {
                                          setState(() {
                                            selectedPosition = index;
                                          });
                                        },
                                        selectedTileColor: Colors.white,
                                        tileColor: const Color.fromRGBO(
                                          245,
                                          245,
                                          245,
                                          1,
                                        ),
                                        selected: selectedPosition != -1
                                            ? seconds[index] !=
                                                seconds[selectedPosition]
                                            : contact
                                                    .messagesDisappearAfterSeconds !=
                                                seconds[index],
                                        leading: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            start: 8,
                                          ),
                                          child: Transform.scale(
                                            scale: 1.2,
                                            child: Radio(
                                              value: selectedPosition != -1
                                                  ? seconds[index] !=
                                                      seconds[selectedPosition]
                                                  : contact
                                                          .messagesDisappearAfterSeconds !=
                                                      seconds[index],
                                              groupValue: false,
                                              fillColor: MaterialStateProperty
                                                  .resolveWith<Color>(
                                                (states) => states.contains(
                                                  MaterialState.selected,
                                                )
                                                    ? pink4
                                                    : black,
                                              ),
                                              activeColor: pink4,
                                              onChanged: (value) async {
                                                setState(() {
                                                  selectedPosition = index;
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
                                                    longForm: true,
                                                  ),
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
                              CDivider(
                                thickness: 1,
                                color: grey3,
                                height: 1,
                                margin: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                        const EdgeInsetsDirectional.only(
                                          top: 16,
                                          bottom: 16,
                                          end: 16,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async => context.router.maybePop(),
                                    child: CText(
                                      'cancel'.i18n.toUpperCase(),
                                      style: tsButtonGrey,
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                        const EdgeInsetsDirectional.only(
                                          top: 16,
                                          bottom: 16,
                                          end: 24,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (selectedPosition != -1) {
                                        await messagingModel
                                            .setDisappearSettings(
                                          contact,
                                          seconds[selectedPosition],
                                        );
                                      }
                                      await context.router.maybePop();
                                    },
                                    child: CText(
                                      'set'.i18n.toUpperCase(),
                                      style: tsButtonPink,
                                    ),
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
        if (!contact.isMe)
          ListItemFactory.bottomItem(
            icon: ImagePaths.people,
            content: 'introduce_contact'.i18n,
            onTap: () async {
              await bottomContext.router.maybePop();
              await bottomContext.pushRoute(
                Introduce(
                  singleIntro: true,
                  contactToIntro: contact,
                ),
              );
            },
          ),
        if (!contact.isMe && contact.isUnverified())
          ListItemFactory.bottomItem(
            icon: ImagePaths.verified_user,
            content: 'contact_verification'.i18n,
            onTap: () async {
              await bottomContext.router.maybePop();
              showVerificationOptions(
                contact: contact,
                bottomModalContext: parentContext,
                topBarAnimationCallback: topBarAnimationCallback!,
              );
            },
          ),
      ],
    ),
  );
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
