import 'package:lantern/messaging/introductions/introduction_extension.dart';

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
    if (Platform.isAndroid) {
      sessionModel.disableScreenShot();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      sessionModel.enableScreenShot();
    }
    super.dispose();
  }

  void handleReminder(Iterable<PathAndValue<Contact>> _contacts) async {
    //* Store timestamp to DB and compare to mostRecentMessageTs
    try {
      await messagingModel.saveNotificationsTS();
    } catch (e) {
      print(e);
    }

    //* temporary background color change
    setState(() => customBg = blue1);
    Future.delayed(
      shortAnimationDuration,
      () => setState(() => customBg = null),
    );

    //* Scroll to first unaccepted message
    if (scrollListController.isAttached &&
        shouldScroll(
          context: context,
          numElements: _contacts.length,
          elHeight: 72.0,
        )) {
      final firstUnaccepted =
          _contacts.firstWhere((element) => element.value.isUnaccepted());
      final scrollTo = _contacts
          .toList()
          .indexWhere((element) => element.value == firstUnaccepted.value);
      await scrollListController.scrollTo(
        index: scrollTo,
        duration: defaultAnimationDuration,
        curve: defaultCurves,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return sessionModel.chatEnabled(
      (context, chatEnabled, _) => doBuild(context, !chatEnabled),
    );
  }

  Widget doBuild(BuildContext context, bool chatDisabled) {
    return BaseScreen(
      title: 'chats'.i18n,
      actions: chatDisabled
          ? []
          : [
              // * Notifications icon
              messagingModel.contactsByActivity(
                builder: (
                  context,
                  Iterable<PathAndValue<Contact>> _contacts,
                  Widget? child,
                ) {
                  final requests = _contacts
                      .where((element) => element.value.isUnaccepted())
                      .toList();

                  if (requests.isEmpty) {
                    return const SizedBox();
                  }

                  // 1. get most recent unaccepted contact
                  // 2. get most recent message TS from that contact
                  final mostRecentUnacceptedTS = requests
                      .firstWhere((element) => element.value.isUnaccepted())
                      .value
                      .mostRecentMessageTs
                      .toInt();

                  return messagingModel.getLastDismissedNotificationTS(
                    (context, mostRecentNotifTS, child) =>
                        requests.isNotEmpty &&
                                (mostRecentUnacceptedTS > mostRecentNotifTS)
                            ? RoundButton(
                                onPressed: () => handleReminder(_contacts),
                                backgroundColor: transparent,
                                icon: CBadge(
                                  count: requests.length,
                                  showBadge: requests.isNotEmpty,
                                  child: const CAssetImage(
                                    path: ImagePaths.notifications,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                  );
                },
              ),
              // * Search
              IconButton(
                key: const ValueKey('search_icon'),
                visualDensity: VisualDensity.compact,
                onPressed: () async => await showSearch(
                  context: context,
                  query: '',
                  delegate: CustomSearchDelegate(searchMessages: true),
                ),
                icon: const CAssetImage(path: ImagePaths.search),
              ),
              // * Bottom modal
              IconButton(
                key: const ValueKey('chats_topbar_more_menu'),
                visualDensity: VisualDensity.compact,
                onPressed: () async => showBottomModal(
                  context: context,
                  children: [
                    messagingModel
                        .me((_, me, __) => ShareYourChatNumber(me).bottomItem),
                    sessionModel.proUser(
                      (_, isPro, child) => ListItemFactory.bottomItem(
                        icon: ImagePaths.account,
                        content: 'account_management'.i18n,
                        onTap: () async {
                          await context.router.pop();
                          await context.router
                              .push(AccountManagement(isPro: isPro));
                        },
                      ),
                    ),
                    ListItemFactory.bottomItem(
                      icon: ImagePaths.people,
                      content: 'introduce_contacts'.i18n,
                      onTap: () async {
                        await context.router.pop();
                        await context.router
                            .push(Introduce(singleIntro: false));
                      },
                    ),
                  ],
                ),
                icon: const CAssetImage(path: ImagePaths.more_vert),
              ),
            ],
      body: chatDisabled
          ? const SizedBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*
            * Introductions
            */
                messagingModel.bestIntroductions(
                  builder: (
                    context,
                    Iterable<PathAndValue<StoredMessage>> introductions,
                    Widget? child,
                  ) =>
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
                              content: CText(
                                'introductions'.i18n,
                                style: tsSubtitle1Short,
                              ),
                              trailingArray: [const ContinueArrow()],
                              onTap: () async => await context
                                  .pushRoute(const Introductions()),
                            )
                          : const SizedBox(),
                ),
                /*
            * Messages
            */
                messagingModel.contactsByActivity(
                  builder: (
                    context,
                    Iterable<PathAndValue<Contact>> _contacts,
                    Widget? child,
                  ) {
                    // * NO CONTACTS
                    if (_contacts.isEmpty) {
                      return const Expanded(child: EmptyChats());
                    }

                    final reshapedContactList = reshapeContactList(_contacts);
                    final unacceptedStartIndex = reshapedContactList
                        .indexWhere((element) => element.value.isUnaccepted());

                    return Expanded(
                      child: ScrollablePositionedList.builder(
                        itemScrollController: scrollListController,
                        itemCount: reshapedContactList.length,
                        physics: defaultScrollPhysics,
                        itemBuilder: (context, index) {
                          var contact = reshapedContactList[index].value;
                          var isUnaccepted = contact.isUnaccepted();
                          return Column(
                            key: const ValueKey('chats_messages_list'),
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
                                        contact: contact,
                                        context: context,
                                      )
                                    : null,
                                leading: CustomAvatar(
                                  customColor: isUnaccepted ? grey5 : null,
                                  messengerId: contact.contactId.id,
                                  displayName: contact.displayName,
                                ),
                                content: contact.displayNameOrFallback,
                                subtitle:
                                    '${contact.mostRecentMessageText.isNotEmpty ? contact.mostRecentMessageText : 'attachment'.i18n}',
                                onTap: () async => await context.pushRoute(
                                  Conversation(contactId: contact.contactId),
                                ),
                                trailingArray: [
                                  HumanizedDate.fromMillis(
                                    contact.mostRecentMessageTs.toInt(),
                                    builder: (context, date) => CText(
                                      date,
                                      style: tsBody2.copiedWith(color: grey5),
                                    ),
                                  ),
                                  if (contact.numUnviewedMessages > 0)
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        start: 8.0,
                                      ),
                                      child: CircleAvatar(
                                        maxRadius: activeIconSize - 4,
                                        backgroundColor: pink4,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
      actionButton: chatDisabled
          ? null
          : FloatingActionButton(
              backgroundColor: blue4,
              onPressed: () async => await context.pushRoute(const NewChat()),
              child: CAssetImage(path: ImagePaths.add, color: white),
            ),
    );
  }
}

/// Sorts message list from newest to oldest, from verified to unverified, and from accepted to unaccepted
List<PathAndValue<Contact>> reshapeContactList(
  Iterable<PathAndValue<Contact>> contacts,
) {
  // Contacts with message timestamps which are not blocked
  var _activeConversations = contacts
      .where(
        (contact) =>
            contact.value.mostRecentMessageTs > 0 &&
            contact.value.isNotBlocked(),
      )
      .toList();
  // Newest -> older
  _activeConversations.sort((a, b) {
    return (b.value.mostRecentMessageTs - a.value.mostRecentMessageTs).toInt();
  });

  // Either verified or unverified
  var _acceptedContacts = _activeConversations.where(
    (element) => element.value.isVerified() || element.value.isUnverified(),
  );

  // Unaccepted AKA message requests
  var _unacceptedContacts =
      _activeConversations.where((element) => element.value.isUnaccepted());

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: CAssetImage(
            path: Directionality.of(context) == TextDirection.ltr
                ? ImagePaths.empty_chats
                : ImagePaths.empty_chats_rtl,
            size: 250,
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 17),
          child: CText(
            'empty_chats_text'.i18n,
            style: tsBody1Color(grey5),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
