import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contact_intro_preview.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/button.dart';
import 'package:sizer/sizer.dart';

class Introduce extends StatefulWidget {
  static const NUM_RECENT_CONTACTS = 10;

  @override
  _IntroduceState createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    var selectedContacts = [];
    // contacts.forEach((contact) =>
    //     selectedContacts.add({'contact': contact, 'isSelected': false}));

    Color getColor(Set<MaterialState> states) {
      const interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.white;
      }
      return Colors.black;
    }

    return BaseScreen(
      title: 'Introduce Contacts'.i18n,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Text(
              'Select two or more contacts to introduce.  They will be sent invitations to start messaging each other. '
                  .i18n,
              style: tsBaseScreenBodyText),
        ),
        Expanded(
          child: model.contacts(builder: (context,
              Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
            var contacts = _contacts.toList();
            var all = contacts.take(Introduce.NUM_RECENT_CONTACTS).toList();
            if (contacts.length > Introduce.NUM_RECENT_CONTACTS) {
              contacts.sort((a, b) {
                var dc = (a.value.displayName).compareTo(b.value.displayName);
                if (dc != 0) {
                  return dc;
                }
                return a.value.contactId.id.compareTo(b.value.contactId.id);
              });
              all += contacts;
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: all.length,
                    itemBuilder: (context, index) {
                      var contact = all[index];
                      var displayName = contact.value.displayName.isEmpty
                          ? 'Unnamed contact'.i18n
                          : contact.value.displayName;
                      var avatarLetters = displayName.substring(0, 2);
                      return Column(
                        children: [
                          // true will style this as a Contact preview
                          ContactIntroPreview(
                            contact,
                            index,
                            CircleAvatar(
                              backgroundColor: avatarBgColors[
                                  generateUniqueColorIndex(
                                      contact.value.contactId.id)],
                              child: Text(avatarLetters.toUpperCase(),
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            FittedBox(
                              child: Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    MaterialStateProperty.resolveWith(getColor),
                                // value: selectedContacts[index]['isSelected'],
                                value: false,
                                shape:
                                    const CircleBorder(side: BorderSide.none),
                                // onChanged: (bool? value) => setState(() {
                                //   selectedContacts[index]['isSelected'] = value;
                                // }),
                                onChanged: (bool? value) => {},
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (selectedContacts.isNotEmpty)
                  Expanded(
                    child: Container(
                      color: grey1,
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Button(
                              width: 200,
                              text: 'Send Invitantios'.i18n.toUpperCase(),
                              onPressed: () {},
                            ),
                          ]),
                    ),
                  )
              ],
            );
          }),
        )
      ]),
    );
  }
}
