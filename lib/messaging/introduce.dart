import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contacts/grouped_contact_list.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/button.dart';
import 'package:lantern/utils/iterable_extension.dart';

class Introduce extends StatefulWidget {
  @override
  _IntroduceState createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  List<String> selectedContactIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
        title: 'Introduce Contacts (${selectedContactIds.length})'.i18n,
        body: model.contacts(builder: (context,
            Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
          var sortedContacts = _contacts.toList()
            ..sort((a, b) => sanitizeContactName(a.value.displayName)
                .compareTo(sanitizeContactName(b.value.displayName)));

          var groupedSortedContacts = sortedContacts
              .groupBy((el) => sanitizeContactName(el.value.displayName));

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sortedContacts.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Text(
                        'Select two or more contacts to introduce.  They will be sent invitations to start messaging each other. '
                            .i18n,
                        style: tsEmptyContactState),
                  ),
                Expanded(
                    child: (sortedContacts.length <= 1)
                        ? Container(
                            alignment: AlignmentDirectional.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 16.0),
                            child: Text(
                                'Once you have two or more contacts you will be able to create introductions.'
                                    .i18n,
                                textAlign: TextAlign.center,
                                style: tsBaseScreenBodyText),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Expanded(
                                  flex: 2,
                                  child: groupedContactListGenerator(
                                      groupedSortedList: groupedSortedContacts,
                                      leadingCallback: (Contact contact) =>
                                          CircleAvatar(
                                            backgroundColor: avatarBgColors[
                                                generateUniqueColorIndex(
                                                    contact.contactId.id)],
                                            child: Text(
                                                sanitizeContactName(
                                                        contact.displayName)
                                                    .substring(0, 2)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          ),
                                      trailingCallback: (int index,
                                              Contact contact) =>
                                          Checkbox(
                                            checkColor: Colors.white,
                                            fillColor: MaterialStateProperty
                                                .resolveWith(getCheckboxColor),
                                            value: selectedContactIds
                                                .contains(contact.contactId.id),
                                            shape: const CircleBorder(
                                                side: BorderSide.none),
                                            onChanged: (bool? value) =>
                                                setState(() {
                                              value!
                                                  ? selectedContactIds
                                                      .add(contact.contactId.id)
                                                  : selectedContactIds.remove(
                                                      contact.contactId.id);
                                            }),
                                          )),
                                ),
                                (selectedContactIds.isNotEmpty)
                                    ? Container(
                                        color: grey1,
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Button(
                                                width: 200,
                                                text: 'Send Invitations'
                                                    .i18n
                                                    .toUpperCase(),
                                                onPressed: () async {
                                                  await model.introduce(
                                                      selectedContactIds);
                                                  showSnackbar(
                                                      context,
                                                      'Introductions Sent!'
                                                          .i18n);
                                                  await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 1000),
                                                    () async => await context
                                                        .router
                                                        .pop(),
                                                  );
                                                },
                                              ),
                                            ]),
                                      )
                                    : Container()
                              ]))
              ]);
        }));
  }
}
