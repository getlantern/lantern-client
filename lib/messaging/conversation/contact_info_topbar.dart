import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/disappearing_timer_action.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';

class ContactInfoTopBar extends StatelessWidget {
  final Contact contact;
  final Color verifiedColor;

  const ContactInfoTopBar({
    required this.contact,
    required this.verifiedColor,
  }) : super();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: CustomAvatar(
              messengerId: contact.contactId.id,
              displayName: contact.displayNameOrFallback),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CText(
                contact.displayNameOrFallback,
                maxLines: 1,
                style: tsHeading3,
              ),
              /* 
              * Contact is unverified => render pending badge
              */
              if (contact.verificationLevel == VerificationLevel.UNVERIFIED)
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 2.0),
                      child: CAssetImage(
                        path: ImagePaths.pending,
                        size: 12.0,
                      ),
                    ),
                    CText('pending_verification'.i18n.toUpperCase(),
                        style: tsOverline.copiedWith(lineHeight: 14))
                  ],
                ),
              /* 
              * Contact is verified => render timer and verified badge
              */
              if (contact.verificationLevel == VerificationLevel.VERIFIED)
                Row(
                  children: [
                    DisappearingTimerAction(contact),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 8.0, end: 2.0),
                      child: CAssetImage(
                        path: ImagePaths.verified_user,
                        size: 12.0,
                        color: verifiedColor,
                      ),
                    ),
                    CText('verified'.i18n.toUpperCase(),
                        style: tsOverline.copiedWith(
                            lineHeight: 14, color: verifiedColor)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
