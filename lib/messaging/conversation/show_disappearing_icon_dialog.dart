import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging_model.dart';

void showDisappearingIconDialog({
  required BuildContext parentContext,
  required BuildContext bottomContext,
  required Contact contact,
  required MessagingModel model,
}) {
  final scrollController = ScrollController();
  final seconds = <int>[5, 60, 3600, 10800, 21600, 86400, 604800, 0];
  var selectedPosition = -1;

  showDialog(
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
                          start: 16.0, end: 16.0, top: 24.0, bottom: 24.0),
                      child: contact.messagesDisappearAfterSeconds == 0 ||
                              (selectedPosition != -1 &&
                                  seconds[selectedPosition] == 0)
                          ? CTextWrap(
                              'message_disappearing'.i18n,
                              style: tsBody1.copiedWith(color: grey5),
                            )
                          : CTextWrap(
                              'message_disappearing_description'.i18n.fill([
                                selectedPosition != -1
                                    ? seconds[selectedPosition]
                                        .humanizeSeconds(longForm: true)
                                    : contact.messagesDisappearAfterSeconds
                                        .humanizeSeconds(longForm: true)
                              ]),
                              style: tsBody1.copiedWith(color: grey5),
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
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // set the height so that one of the rows
                    // gets cut in half, to help give the user a
                    // visual cue that they can scroll
                    final maxHeight = constraints.maxHeight / 48 * 48 - 24;
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
                                  const EdgeInsetsDirectional.only(),
                              horizontalTitleGap: 8,
                              minLeadingWidth: 20,
                              onTap: () async {
                                setState(() {
                                  selectedPosition = index;
                                });
                              },
                              selectedTileColor: Colors.white,
                              tileColor: const Color.fromRGBO(245, 245, 245, 1),
                              selected: selectedPosition != -1
                                  ? seconds[index] != seconds[selectedPosition]
                                  : contact.messagesDisappearAfterSeconds !=
                                      seconds[index],
                              leading: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(start: 8),
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
                                      (states) => states
                                              .contains(MaterialState.selected)
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
                                          .humanizeSeconds(longForm: true),
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
                                const EdgeInsetsDirectional.only(
                                    top: 16, bottom: 16, end: 16)),
                          ),
                          onPressed: () async => context.router.pop(),
                          child: CText('cancel'.i18n.toUpperCase(),
                              style: tsButtonGrey),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsetsDirectional.only(
                                    top: 16, bottom: 16, end: 24)),
                          ),
                          onPressed: () async {
                            if (selectedPosition != -1) {
                              await model.setDisappearSettings(
                                  contact, seconds[selectedPosition]);
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
