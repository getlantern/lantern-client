import 'package:lantern/features/messaging/conversation/disappearing_timer_action.dart';

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
            customColor: contact.isUnaccepted() ? grey5 : null,
            messengerId: contact.contactId.id,
            displayName: contact.displayName,
          ),
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
              Row(
                children: [
                  DisappearingTimerAction(contact),
                  if (contact.isVerified())
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 8.0,
                        end: 2.0,
                      ),
                      child: CAssetImage(
                        path: ImagePaths.verified_user,
                        size: 12.0,
                        color: verifiedColor,
                      ),
                    ),
                  if (contact.isVerified())
                    CText(
                      'verified'.i18n.toUpperCase(),
                      style: tsOverline.copiedWith(
                        lineHeight: 14,
                        color: verifiedColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
