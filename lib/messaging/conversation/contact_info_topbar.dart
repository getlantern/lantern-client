import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/disappearing_timer_action.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging.dart';

class ContactInfoTopBar extends StatelessWidget {
  final Contact contact;
  final bool showVerificationAnimation;

  const ContactInfoTopBar({
    required this.contact,
    this.showVerificationAnimation = false,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final title = contact.displayNameOrFallback;
    var verifiedColor = showVerificationAnimation ? indicatorGreen : black;
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
              if (contact.verificationLevel == VerificationLevel.UNVERIFIED)
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
              if (contact.verificationLevel == VerificationLevel.VERIFIED)
                StatefulBuilder(
                    key: const ValueKey('verification_field'),
                    builder: (context, setState) {
                      Future.delayed(longAnimationDuration,
                          () => setState(() => verifiedColor = black));
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DisappearingTimerAction(contact),
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 8.0),
                            child: CAssetImage(
                              path: ImagePaths.verified_user,
                              size: 12.0,
                              color: verifiedColor,
                            ),
                          ),
                          CText('verified'.i18n.toUpperCase(),
                              style:
                                  tsOverline.copiedWith(color: verifiedColor)),
                        ],
                      );
                    }),
            ],
          ),
        ),
      ],
    );
  }
}
