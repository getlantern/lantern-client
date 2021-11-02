import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/disappearing_timer_action.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';

class ContactInfoTopBar extends StatefulWidget {
  final Contact contact;
  final Color verifiedColor;

  const ContactInfoTopBar({
    required this.contact,
    required this.verifiedColor,
  }) : super();

  @override
  _ContactInfoTopBarState createState() => _ContactInfoTopBarState();
}

class _ContactInfoTopBarState extends State<ContactInfoTopBar> {
  ValueNotifier<Contact?>? contactNotifier;
  Contact? updatedContact;
  void Function()? listener;
  var newDisplayName;
  VerificationLevel? newVerificationLevel;

  @override
  void dispose() {
    if (listener != null) {
      contactNotifier?.removeListener(listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    // TODO: repeated pattern
    // listen to the contact path for changes
    // will return a Contact if there are any, otherwise null
    contactNotifier = model.contactNotifier(widget.contact.contactId.id);
    var listener = () async {
      // something changed for this contact, lets get the updates
      updatedContact = contactNotifier!.value as Contact;
      if (updatedContact != null && mounted) {
        setState(() {
          newDisplayName = updatedContact!.displayNameOrFallback;
          newVerificationLevel = updatedContact!.verificationLevel;
        });
      }
    };
    contactNotifier!.addListener(listener);
    listener();

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: CustomAvatar(
              messengerId: widget.contact.contactId.id,
              displayName:
                  newDisplayName ?? widget.contact.displayNameOrFallback),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CText(
                newDisplayName,
                maxLines: 1,
                style: tsHeading3,
              ),
              /* 
              * Contact is unverified => render pending badge
              */
              if (newVerificationLevel == VerificationLevel.UNVERIFIED)
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
              if (newVerificationLevel == VerificationLevel.VERIFIED)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DisappearingTimerAction(widget.contact),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: CAssetImage(
                        path: ImagePaths.verified_user,
                        size: 12.0,
                        color: widget.verifiedColor,
                      ),
                    ),
                    CText('verified'.i18n.toUpperCase(),
                        style:
                            tsOverline.copiedWith(color: widget.verifiedColor)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
