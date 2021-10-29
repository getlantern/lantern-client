import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/disappearing_timer_action.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';

class ContactInfoTopBar extends StatefulWidget {
  final Contact contact;

  const ContactInfoTopBar({
    required this.contact,
  }) : super();

  @override
  _ContactInfoTopBarState createState() => _ContactInfoTopBarState();
}

class _ContactInfoTopBarState extends State<ContactInfoTopBar> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.contact.displayNameOrFallback;
    var verifiedColor = black;
    var verificationLevel = widget.contact.verificationLevel;
    ValueNotifier<Contact?>? contactNotifier;
    var model = context.watch<MessagingModel>();

    // listen to the contact path for changes
    // will return a Contact if there are any, otherwise null
    contactNotifier = model.contactNotifier(widget.contact.contactId.id);

    var listener = () async {
      var updatedContact = contactNotifier!.value;
      // something changed for this contact, lets get the updates
      if (updatedContact != null) {
        setState(() {
          title = updatedContact.displayNameOrFallback;
          verificationLevel = updatedContact.verificationLevel;
        });
        // TODO: this needs to be disposed of properly
        await Future.delayed(longAnimationDuration,
            () => setState(() => verifiedColor = indicatorGreen));
      }
    };
    contactNotifier.addListener(listener);
    // immediately invoke listener in case the contactNotifier already has
    // an up-to-date contact.
    listener();

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: CustomAvatar(
              messengerId: widget.contact.contactId.id, displayName: title),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CText(
                title,
                maxLines: 1,
                style: tsHeading3,
              ),
              /* 
              * Contact is unverified => render pending badge
              */
              if (verificationLevel == VerificationLevel.UNVERIFIED)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 2.0),
                      child: CAssetImage(
                        path: ImagePaths.pending,
                        size: 12.0,
                      ),
                    ),
                    CText('pending_verification'.i18n.toUpperCase(),
                        style: tsOverline)
                  ],
                ),
              /* 
              * Contact is verified => render timer and verified badge
              */
              if (verificationLevel == VerificationLevel.VERIFIED)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DisappearingTimerAction(widget.contact),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: CAssetImage(
                        path: ImagePaths.verified_user,
                        size: 12.0,
                        color: verifiedColor,
                      ),
                    ),
                    CText('verified'.i18n.toUpperCase(),
                        style: tsOverline.copiedWith(color: verifiedColor)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
