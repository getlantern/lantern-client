import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lantern/utils/humanize.dart';

String sanitizeContactName(String displayName) {
  return displayName.isEmpty ? 'Unnamed Contact'.i18n : displayName.toString();
}

Map<String, List<dynamic>> constructReactionsMap(
    StoredMessage msg, Contact contact) {
  // hardcode the list of available emoticons in a way that is convenient to parse
  var reactions = {'👍': [], '👎': [], '😄': [], '❤': [], '😢': [], '•••': []};
  // https://api.dart.dev/stable/2.12.4/dart-core/Map/Map.fromIterables.html
  // create a Map from Iterable<String> and Iterable<Reaction>
  var reactor_emoticon_map = {};
  Map.fromIterables(msg.reactions.keys, msg.reactions.values)
      // reactorID <---> emoticon to reactor_emoticon_map
      .forEach((reactorId, reaction) =>
          reactor_emoticon_map[reactorId] = reaction.emoticon);

  // swap key-value pairs to create emoticon <--> List<reactorId>
  reactor_emoticon_map.forEach((reactorId, reaction) {
    reactions[reaction] = [...?reactions[reaction], reactorId];
  });

  // humanize reactorIdList
  reactions.forEach((reaction, reactorIdList) =>
      reactions[reaction] = _humanizeReactorIdList(reactorIdList, contact));

  return reactions;
}

List<dynamic> _humanizeReactorIdList(
    List<dynamic> reactorIdList, Contact contact) {
  var humanizedList = [];
  if (reactorIdList.isEmpty) return humanizedList;

  reactorIdList.forEach((reactorId) =>
      humanizedList.add(matchIdToDisplayName(reactorId, contact)));
  return humanizedList;
}

List<dynamic> constructReactionsList(BuildContext context,
    Map<String, List<dynamic>> reactions, StoredMessage msg) {
  var reactionsList = [];
  reactions.forEach(
    (key, value) {
      if (value.isNotEmpty) {
        reactionsList.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            // Tap on emoji to bring modal with breakdown of interactions
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => displayEmojiBreakdownPopup(context, msg, reactions),
              child: displayEmojiCount(reactions, key),
            ),
          ),
        );
      }
    },
  );
  return reactionsList;
}

String matchIdToDisplayName(String contactIdToMatch, Contact contact) {
  return contactIdToMatch == contact.contactId.id
      ? contact.displayName
      : 'me'.i18n;
}

Widget? renderStatusIcon(bool inbound, bool outbound, StoredMessage msg) {
  return inbound
      ? null
      : msg.status == StoredMessage_DeliveryStatus.COMPLETELY_SENT
          ? Icon(
              Icons.check_circle_outline_outlined,
              size: 12,
              color: outbound ? outboundMsgColor : inboundMsgColor,
            )
          : msg.status == StoredMessage_DeliveryStatus.SENDING
              ? SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 0.5,
                    color: outbound ? outboundMsgColor : inboundMsgColor,
                  ),
                )
              : msg.status == StoredMessage_DeliveryStatus.COMPLETELY_FAILED ||
                      msg.status ==
                          StoredMessage_DeliveryStatus.PARTIALLY_FAILED
                  ? Icon(
                      Icons.error_outline,
                      size: 12,
                      color: outbound ? outboundMsgColor : inboundMsgColor,
                    )
                  : null;
}

Future<void> displayEmojiBreakdownPopup(BuildContext context, StoredMessage msg,
    Map<String, List<dynamic>> reactions) {
  return showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
              ),
              const Center(
                  child: Text('Reactions', style: TextStyle(fontSize: 18.0))),
              Divider(thickness: 1, color: grey2),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var reaction in reactions.entries)
                    if (reaction.value.isNotEmpty)
                      ListTile(
                        leading: Text(reaction.key),
                        title: Text(reaction.value.join(', ')),
                      ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(12),
              ),
            ],
          ));
}

Container displayEmojiCount(
    Map<String, List<dynamic>> reactions, String emoticon) {
  // identify which Map (key-value) pair corresponds to the displayed emoticon
  final reactionKey = reactions.keys.firstWhere((key) => key == emoticon);
  final reactorsToKey = reactions[reactionKey]!;
  return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
          padding: reactorsToKey.length > 1
              ? const EdgeInsets.only(left: 3, top: 3, right: 6, bottom: 3)
              : const EdgeInsets.all(3),
          child: reactorsToKey.length > 1
              ? Text(emoticon + reactorsToKey.length.toString(),
                  style: const TextStyle(fontSize: 12))
              : Text(emoticon, style: const TextStyle(fontSize: 12))));
}

String determineDateSwitch(
    StoredMessage? priorMessage, StoredMessage? nextMessage) {
  if (priorMessage == null || nextMessage == null) return '';

  var currentDateTime =
      DateTime.fromMillisecondsSinceEpoch(priorMessage.ts.toInt());
  var nextMessageDateTime =
      DateTime.fromMillisecondsSinceEpoch(nextMessage.ts.toInt());

  if (nextMessageDateTime.difference(currentDateTime).inDays >= 1) {
    currentDateTime = nextMessageDateTime;
    return DateFormat.yMMMMd('en_US').format(currentDateTime);
  }

  return '';
}

bool determineDeletionStatus(StoredMessage msg) {
  return msg.remotelyDeletedAt != 0; // is 0 if message hasn't been deleted
}

void showSnackbar(
    {required BuildContext context,
    required Widget content,
    Duration duration = const Duration(milliseconds: 1000),
    SnackBarAction? action}) {
  final snackBar = SnackBar(
    content: content,
    action: action,
    backgroundColor: Colors.black,
    duration: duration,
    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    behavior: SnackBarBehavior.floating,
    elevation: 1,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0))),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Widget fullScreenDialogLayout(Color bgColor, Color iconColor,
    BuildContext context, List<Widget> widgetList) {
  return Container(
    color: bgColor,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.all(20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: iconColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          ...widgetList
        ]),
  );
}

int generateUniqueColorIndex(String str) {
  var index = 0;
  for (var i = 0; i < str.length; i++) {
    index += str.codeUnitAt(i);
  }
  return index % avatarBgColors.length;
}

Future<void> displayConversationOptions(
    MessagingModel model, BuildContext parentContext, Contact contact) {
  final seconds = <int>[5, 60, 3600, 10800, 21600, 86400, 604800, 0];
  return showModalBottomSheet(
      context: parentContext,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (bottomContext) => Wrap(
            alignment: WrapAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  'Conversation Menu',
                  style: tsBottomModalTitle,
                ),
              ),
              const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color.fromRGBO(235, 235, 235, 1)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.timer,
                    color: Colors.black,
                  ),
                  title: Text('Disappearing Messages'.i18n,
                      style: tsBottomModalList),
                  onTap: () async {
                    var selectedPosition = -1;
                    return showDialog(
                      context: bottomContext,
                      barrierDismissible: true,
                      barrierColor: Colors.black.withOpacity(0.8),
                      builder: (context) => AlertDialog(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(0),
                        scrollable: true,
                        clipBehavior: Clip.hardEdge,
                        title: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            'Disappearing Messages'.i18n,
                            style: tsDisappearingTitleBottomModal,
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 2),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 24.0),
                                      child:
                                          contact.messagesDisappearAfterSeconds ==
                                                  0
                                              ? Text(
                                                  'All messages will not disappear for you and your contact',
                                                  style:
                                                      tsDisappearingContentBottomModal,
                                                )
                                              : Text(
                                                  'All messages will disappear after ${contact.messagesDisappearAfterSeconds.humanizeSeconds(longForm: true)} for you and your contact',
                                                  style:
                                                      tsDisappearingContentBottomModal,
                                                ),
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Color.fromRGBO(235, 235, 235, 1),
                                    height: 2,
                                    indent: 3,
                                    endIndent: 3,
                                  ),
                                  SizedBox(
                                    height: 264,
                                    width: MediaQuery.of(context).size.width,
                                    child: Scrollbar(
                                      interactive: true,
                                      showTrackOnHover: true,
                                      radius: const Radius.circular(50),
                                      child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: seconds.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            contentPadding:
                                                const EdgeInsets.only(),
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
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: Transform.scale(
                                                scale: 1.2,
                                                child: Radio(
                                                  value: selectedPosition != -1
                                                      ? seconds[index] !=
                                                          seconds[
                                                              selectedPosition]
                                                      : contact
                                                              .messagesDisappearAfterSeconds !=
                                                          seconds[index],
                                                  groupValue: false,
                                                  onChanged: (value) async {
                                                    setState(() {
                                                      selectedPosition = index;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                                seconds[index] == 0
                                                    ? 'Off'.i18n
                                                    : seconds[index]
                                                        .humanizeSeconds(
                                                            longForm: true),
                                                style: tsAlertDialogListTile),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        actions: [
                          Column(
                            children: [
                              const Divider(
                                thickness: 1,
                                color: Color.fromRGBO(235, 235, 235, 1),
                                height: 1,
                                indent: 3,
                                endIndent: 3,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () async => context.router.pop(),
                                    child: Text('Cancel'.i18n.toUpperCase(),
                                        style: tsAlertDialogButtonGrey),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (selectedPosition != -1) {
                                        await model.setDisappearSettings(
                                            contact, seconds[selectedPosition]);
                                      }
                                      await context.router.pop();
                                      await parentContext.router.pop();
                                    },
                                    child: Text('Set'.i18n.toUpperCase(),
                                        style: tsAlertDialogButtonPink),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color.fromRGBO(235, 235, 235, 1)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.people,
                    color: Colors.black,
                  ),
                  title:
                      Text('Introduce Contacts'.i18n, style: tsBottomModalList),
                  onTap: () async =>
                      await bottomContext.pushRoute(const Introduce()),
                ),
              ),
              const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color.fromRGBO(235, 235, 235, 1)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                    leading: const Icon(Icons.delete, color: Colors.black),
                    title: Text('Delete ${contact.displayName}',
                        style: tsBottomModalList),
                    onTap: () => showDialog<void>(
                          context: bottomContext,
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
                                    child: Icon(Icons.delete),
                                  ),
                                  Text('Delete Contact'.i18n.toUpperCase(),
                                      style: tsAlertDialogTitle),
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(
                                        'Once deleted, you will need to scan their QR code or have a mutual friend send an introduction, to message them again.'
                                            .i18n,
                                        style: tsAlertDialogBody)
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () async =>
                                          context.router.pop(),
                                      child: Text('Cancel'.i18n.toUpperCase(),
                                          style: tsAlertDialogButtonGrey),
                                    ),
                                    const SizedBox(width: 15),
                                    TextButton(
                                      onPressed: () async {
                                        context.loaderOverlay.show(
                                            widget: const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ));
                                        try {
                                          await model.deleteDirectContact(
                                              contact.contactId.id);
                                        } catch (e) {
                                          showInfoDialog(context,
                                              title: 'Error'.i18n,
                                              des:
                                                  'Something went wrong while deleting this contact.'
                                                      .i18n,
                                              icon: ImagePaths.alert_icon,
                                              buttonText: 'OK'.i18n);
                                        } finally {
                                          context.loaderOverlay.hide();
                                          // In order to be capable to return to the root screen, we need to pop the bottom sheet
                                          // and then pop the root screen.
                                          context.router.popUntilRoot();
                                          parentContext.router.popUntilRoot();
                                        }
                                      },
                                      child: Text(
                                          'Delete Contact'.i18n.toUpperCase(),
                                          style: tsAlertDialogButtonPink),
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        )),
              ),
            ],
          ));
}
