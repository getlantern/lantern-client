import 'package:lantern/messaging/introductions/introduction_extension.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pbenum.dart';

import 'contacts/long_tap_menu.dart';
import 'messaging.dart';

class Chats extends StatefulWidget {
  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  var scrollListController = ItemScrollController();
  Color? customBg;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleReminder(
      Iterable<PathAndValue<Contact>> _contacts, MessagingModel model) async {
    //* Store timestamp to DB and compare to mostRecentMessageTs
    try {
      await model.saveNotificationsTS();
    } catch (e) {
      print(e);
    }

    //* temporary background color change
    setState(() => customBg = blue1);
    Future.delayed(const Duration(milliseconds: 500),
        () => setState(() => customBg = null));

    //* Scroll to first unaccepted message
    if (scrollListController.isAttached &&
        shouldScroll(
          context: context,
          numElements: _contacts.length,
          elHeight: 72.0,
        )) {
      final firstUnaccepted = _contacts.firstWhere((element) =>
          element.value.verificationLevel == VerificationLevel.UNACCEPTED);
      final scrollTo = _contacts
          .toList()
          .indexWhere((element) => element.value == firstUnaccepted.value);
      await scrollListController.scrollTo(
          index: scrollTo, duration: const Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
        title: 'chats'.i18n,
        actions: [
          // * Notifications icon
          model.contactsByActivity(builder: (context,
              Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
            final requests = _contacts
                .where((element) =>
                    element.value.verificationLevel ==
                    VerificationLevel.UNACCEPTED)
                .toList();

            if (requests.isEmpty) {
              return const SizedBox();
            }

            // 1. get most recent unaccepted contact
            // 2. get most recent message TS from that contact
            final mostRecentUnacceptedTS = requests
                .firstWhere((element) =>
                    element.value.verificationLevel ==
                    VerificationLevel.UNACCEPTED)
                .value
                .mostRecentMessageTs
                .toInt();

            return model.getLastDismissedNotificationTS(
                (context, mostRecentNotifTS, child) => requests.isNotEmpty &&
                        (mostRecentUnacceptedTS > mostRecentNotifTS)
                    ? RoundButton(
                        onPressed: () => handleReminder(_contacts, model),
                        backgroundColor: transparent,
                        icon: CBadge(
                          count: requests.length,
                          showBadge: requests.isNotEmpty,
                          child:
                              const CAssetImage(path: ImagePaths.notifications),
                        ),
                      )
                    : const SizedBox());
          }),
          // * Search
          RoundButton(
            onPressed: () async => await showSearch(
              context: context,
              query: '',
              delegate: CustomSearchDelegate(searchMessages: true),
            ),
            backgroundColor: transparent,
            icon: const CAssetImage(path: ImagePaths.search),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*
            * Introductions
            */
            model.bestIntroductions(
                builder: (context,
                        Iterable<PathAndValue<StoredMessage>> introductions,
                        Widget? child) =>
                    (introductions.getPending().isNotEmpty)
                        ? ListItemFactory.messagingItem(
                            leading: CBadge(
                              count: introductions.getPending().length,
                              showBadge: true,
                              child: const Icon(
                                Icons.people,
                                color: Colors.black,
                              ),
                            ),
                            content: CText('introductions'.i18n,
                                style: tsSubtitle1Short),
                            trailingArray: [
                              const CAssetImage(
                                path: ImagePaths.keyboard_arrow_right,
                                size: iconSize,
                              )
                            ],
                            onTap: () async =>
                                await context.pushRoute(const Introductions()),
                          )
                        : const SizedBox()),
            /*
            * Messages
            */
            model.contactsByActivity(builder: (context,
                Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
              // * NO CONTACTS
              if (_contacts.isEmpty) {
                return const Expanded(child: EmptyChats());
              }

              final reshapedContactList = reshapeContactList(_contacts);
              final unacceptedStartIndex = reshapedContactList.indexWhere(
                  (element) =>
                      element.value.verificationLevel ==
                      VerificationLevel.UNACCEPTED);

              return Expanded(
                child: ScrollablePositionedList.builder(
                  itemScrollController: scrollListController,
                  itemCount: reshapedContactList.length,
                  physics: defaultScrollPhysics,
                  itemBuilder: (context, index) {
                    var contactItem = reshapedContactList[index];
                    return model.contact(context, contactItem,
                        (context, contact, child) {
                      var isUnaccepted = contact.verificationLevel ==
                          VerificationLevel.UNACCEPTED;
                      var displayName = isUnaccepted
                          ? contact.chatNumber.shortNumber.formattedChatNumber
                          : contact.displayNameOrFallback;
                      var content = isUnaccepted
                          ? contact.chatNumber.shortNumber.formattedChatNumber
                          : contact.displayNameOrFallback;
                      return Column(
                        children: [
                          ListItemFactory.messagingItem(
                            customBg: isUnaccepted ? customBg : null,
                            header: unacceptedStartIndex == index
                                ? 'new_requests'.i18n.fill([
                                    '(${reshapedContactList.length - unacceptedStartIndex})'
                                  ])
                                : null,
                            focusedMenu: !isUnaccepted
                                ? renderLongTapMenu(
                                    contact: contact, context: context)
                                : null,
                            leading: CustomAvatar(
                                customColor: isUnaccepted ? grey5 : null,
                                messengerId: contact.contactId.id,
                                displayName: displayName),
                            content: content,
                            subtitle:
                                '${contact.mostRecentMessageText.isNotEmpty ? contact.mostRecentMessageText : 'attachment'}'
                                    .i18n,
                            onTap: () async => await context.pushRoute(
                                Conversation(contactId: contact.contactId)),
                            trailingArray: [
                              HumanizedDate.fromMillis(
                                contact.mostRecentMessageTs.toInt(),
                                builder: (context, date) => CText(date,
                                    style: tsBody2.copiedWith(color: grey5)),
                              )
                            ],
                          ),
                        ],
                      );
                    });
                  },
                ),
              );
            }),
          ],
        ),
        actionButton: FloatingActionButton(
          backgroundColor: blue4,
          onPressed: () async => await context.pushRoute(const NewChat()),
          child: CAssetImage(path: ImagePaths.add, color: white),
        ));
  }
}

List<PathAndValue<Contact>> reshapeContactList(
    Iterable<PathAndValue<Contact>> contacts) {
  // Contacts with message timestamps which are not blocked
  var _activeConversations = contacts
      .where((contact) =>
          contact.value.mostRecentMessageTs > 0 && !contact.value.blocked)
      .toList();
  // Newest -> older
  _activeConversations.sort((a, b) {
    return (b.value.mostRecentMessageTs - a.value.mostRecentMessageTs).toInt();
  });

  // Either verified or unverified
  var _acceptedContacts = _activeConversations.where((element) =>
      element.value.verificationLevel == VerificationLevel.VERIFIED ||
      element.value.verificationLevel == VerificationLevel.UNVERIFIED);

  // Unaccepted AKA message requests
  var _unacceptedContacts = _activeConversations.where((element) =>
      element.value.verificationLevel == VerificationLevel.UNACCEPTED);

  return [
    ..._acceptedContacts,
    ..._unacceptedContacts,
  ];
}

class EmptyChats extends StatelessWidget {
  const EmptyChats({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 8.0, end: 8.0, top: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: CAssetImage(
                path: Directionality.of(context) == TextDirection.ltr
                    ? ImagePaths.empty_chats
                    : ImagePaths.empty_chats_rtl,
                size: 210),
          ),
          CText('empty_chats_text'.i18n, style: tsBody1Color(grey5)),
          // // *
          // // * DEV
          // // *
          // model.getOnBoardingStatus(
          //     (context, value, child) => Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Button(
          //             tertiary: true,
          //             text: 'DEV - toggle value'.i18n,
          //             width: 200.0,
          //             onPressed: () async {
          //               await model.overrideOnBoarded(!value);
          //               context.router.popUntilRoot();
          //             },
          //           ),
          //         )),
        ],
      ),
    );
  }
}
