import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/disappearing_timer_action.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';

class ContactInfoTopBar extends StatelessWidget {
  final Contact contact;
  const ContactInfoTopBar({
    required this.contact,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final title = contact.displayNameOrFallback;
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
                title,
                maxLines: 1,
                style: tsHeading3,
              ),
              Row(
                children: [
                  DisappearingTimerAction(contact),
                  // TODO: Verification - only show when actually verified
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: 8.0),
                    child: CAssetImage(
                      path: ImagePaths.verified_user,
                      size: 12.0,
                    ),
                  ),
                  CText('verified'.i18n.toUpperCase(), style: tsOverline)
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
