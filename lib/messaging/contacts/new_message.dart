import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/contacts/add_contact_QR.dart';
import 'package:lantern/messaging/contacts/grouped_contact_list.dart';
import 'package:lantern/messaging/conversation/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/common/iterable_extension.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class NewMessage extends StatefulWidget {
  // static const NUM_RECENT_CONTACTS = 10;

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var scrollListController = ItemScrollController();
  Contact? _updatedContact;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'new_message'.i18n,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'search'.i18n,
          onPressed: () {},
        ),
      ],
      body: model.me(
        (BuildContext context, Contact me, Widget? child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(
                  Icons.qr_code,
                  color: black,
                ),
                title: Text('scan_qr_code'.i18n),
                trailing: const CustomAssetImage(
                  path: ImagePaths.keyboard_arrow_right_icon,
                  size: 24,
                ),
                onTap: () async => await context.router
                    .push(
                  FullScreenDialogPage(widget: AddViaQR(me: me)),
                )
                    .then((value) {
                  // we only care about this if it comes back with an updated contact
                  if (value != null) {
                    setState(() {
                      _updatedContact = value as Contact;
                    });
                    showSnackbar(
                        context: context,
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                // TODO: i18n interpolation
                                '${_updatedContact!.displayName} is a Contact'
                                    .i18n,
                                overflow: TextOverflow.visible,
                                style: tsInfoDialogText(white),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 4000),
                        action: SnackBarAction(
                          textColor: secondaryPink,
                          label: 'start_chat'.i18n.toUpperCase(),
                          onPressed: () async {
                            await context.pushRoute(Conversation(
                                contactId: _updatedContact!.contactId));
                          },
                        ));
                  }
                }),
              ),
              Divider(thickness: 1, color: grey2),
              ListTile(
                leading: Icon(
                  Icons.people,
                  color: black,
                ),
                title: Text('introduce_contacts'.i18n),
                trailing: const CustomAssetImage(
                  path: ImagePaths.keyboard_arrow_right_icon,
                  size: 24,
                ),
                onTap: () async => await context.pushRoute(const Introduce()),
              ),
              Divider(thickness: 1, color: grey2),
              Container(
                child: model.contacts(builder: (context,
                    Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
                  return _contacts.toList().isNotEmpty
                      ? ListTile(
                          title: Text('contacts'.i18n.toUpperCase(),
                              style: tsEmptyContactState))
                      : Container();
                }),
              ),
              Flexible(child: model.contacts(builder: (context,
                  Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
                var contacts = _contacts.toList();

                // TODO: uncomment if we need to limit num of contacts here hiding this for now
                // var recentContacts =
                //     contacts.take(NewMessage.NUM_RECENT_CONTACTS).toList();

                // related https://github.com/getlantern/android-lantern/issues/299
                var sortedContacts = contacts
                  ..sort((a, b) => sanitizeContactName(a.value.displayName)
                      .compareTo(sanitizeContactName(b.value.displayName)));

                var groupedSortedContacts = sortedContacts
                    .groupBy((el) => sanitizeContactName(el.value.displayName));

                // scroll to index of the contact we just added, if there is one
                // otherwise start from top (index = 0)
                var scrollIndex = _updatedContact != null
                    ? sortedContacts.indexWhere((element) =>
                        element.value.contactId.id ==
                        _updatedContact!.contactId.id)
                    : 0;
                if (scrollListController.isAttached) {
                  scrollListController.scrollTo(
                      index: scrollIndex != -1 ? scrollIndex : 0,
                      //if recent contact can not be found in our list for some reason
                      duration: const Duration(milliseconds: 300));
                }

                return groupedSortedContacts.isNotEmpty
                    ? groupedContactListGenerator(
                        groupedSortedList: groupedSortedContacts,
                        scrollListController: scrollListController,
                        leadingCallback: (Contact contact) =>
                            renderContactAvatar(
                                displayName: contact.displayName),
                        onTapCallback: (Contact contact) async =>
                            await context.pushRoute(
                                Conversation(contactId: contact.contactId)))
                    : Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsetsDirectional.all(16.0),
                        child: Text('no_contacts_yet'.i18n,
                            textAlign: TextAlign.center,
                            style:
                                tsEmptyContactState)); // rendering this instead of SizedBox() to avoid null dimension errors
              })),
            ],
          );
        },
      ),
    );
  }
}
