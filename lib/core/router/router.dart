import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/account_management.dart';
import 'package:lantern/account/blocked_users.dart';
import 'package:lantern/account/chat_number_account.dart';
import 'package:lantern/account/device_linking/approve_device.dart';
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart';
import 'package:lantern/account/device_linking/authorize_device_via_email.dart';
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart';
import 'package:lantern/account/device_linking/link_device.dart';
import 'package:lantern/account/language.dart';
import 'package:lantern/account/lantern_desktop.dart';
import 'package:lantern/account/invite_friends.dart';
import 'package:lantern/account/recovery_key.dart';
import 'package:lantern/account/report_issue.dart';
import 'package:lantern/account/settings.dart';
import 'package:lantern/account/split_tunneling.dart';
import 'package:lantern/account/support.dart';
import 'package:lantern/common/ui/full_screen_dialog.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/home.dart';
import 'package:lantern/messaging/contacts/add_contact_number.dart';
import 'package:lantern/messaging/contacts/contact_info.dart';
import 'package:lantern/messaging/contacts/new_chat.dart';
import 'package:lantern/messaging/conversation/conversation.dart';
import 'package:lantern/messaging/introductions/introduce.dart';
import 'package:lantern/messaging/introductions/introductions.dart';
import 'package:lantern/messaging/onboarding/chat_number_messaging.dart';
import 'package:lantern/messaging/onboarding/chat_number_recovery.dart';
import 'package:lantern/plans/checkout.dart';
import 'package:lantern/plans/plans.dart';
import 'package:lantern/plans/reseller_checkout.dart';
import 'package:lantern/plans/stripe_checkout.dart';
import 'package:lantern/replica/link_handler.dart';
import 'package:lantern/replica/ui/viewers/audio.dart';
import 'package:lantern/replica/ui/viewers/image.dart';
import 'package:lantern/replica/ui/viewers/video.dart';
import 'package:lantern/replica/ui/viewers/misc.dart';
import 'package:lantern/replica/upload/title.dart';
import 'package:lantern/replica/upload/description.dart';
import 'package:lantern/replica/upload/review.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AutoRoute(
      initial: true,
      name: 'Home',
      page: HomePage,
      path: '/',
    ),
    CustomRoute<void>(
      page: FullScreenDialog,
      name: 'FullScreenDialogPage',
      path: 'fullScreenDialogPage',
      transitionsBuilder: popupTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: AccountManagement,
      name: 'AccountManagement',
      path: 'accountManagement',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: Settings,
      name: 'Settings',
      path: 'settings',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: SplitTunneling,
      name: 'SplitTunneling',
      path: 'splitTunneling',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: Language,
      name: 'Language',
      path: 'language',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: AuthorizeDeviceForPro,
      name: 'AuthorizePro',
      path: 'authorizePro',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: AuthorizeDeviceViaEmail,
      name: 'AuthorizeDeviceEmail',
      path: 'authorizeDeviceEmail',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: AuthorizeDeviceViaEmailPin,
      name: 'AuthorizeDeviceEmailPin',
      path: 'authorizeDeviceEmailPin',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ApproveDevice,
      name: 'ApproveDevice',
      path: 'approveDevice',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: LinkDevice,
      name: 'LinkDevice',
      path: 'linkDevice',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: LanternDesktop,
      name: 'LanternDesktop',
      path: 'lanternDesktop',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: InviteFriends,
      name: 'InviteFriends',
      path: 'inviteFriends',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReportIssue,
      name: 'ReportIssue',
      path: 'reportIssue',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
//
// * CHAT ROUTES
//
    CustomRoute<void>(
      page: RecoveryKey,
      name: 'RecoveryKey',
      path: 'recoveryKey',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ChatNumberRecovery,
      name: 'ChatNumberRecovery',
      path: 'chatNumberRecovery',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ChatNumberMessaging,
      name: 'ChatNumberMessaging',
      path: 'chatNumberMessaging',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: Conversation,
      name: 'Conversation',
      path: 'conversation',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ContactInfo,
      name: 'ContactInfo',
      path: 'contactInfo',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: NewChat,
      name: 'NewChat',
      path: 'newChat',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: AddViaChatNumber,
      name: 'AddViaChatNumber',
      path: 'addViaChatNumber',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: Introduce,
      name: 'Introduce',
      path: 'introduce',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: Introductions,
      name: 'Introductions',
      path: 'introductions',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ChatNumberAccount,
      name: 'ChatNumberAccount',
      path: 'chatNumberAccount',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: BlockedUsers,
      name: 'BlockedUsers',
      path: 'blockedUsers',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: Checkout,
      name: 'Checkout',
      path: 'checkout',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
     ),
    CustomRoute<void>(
      page: ResellerCodeCheckout,
      name: 'ResellerCodeCheckout',
      path: 'resellerCodeCheckout',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
     ),
    CustomRoute<void>(
      page: StripeCheckout,
      name: 'StripeCheckout',
      path: 'stripeCheckout',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
     ),
    CustomRoute<void>(
      page: PlansPage,
      name: 'PlansPage',
      path: 'plans',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
     ),
//
// * REPLICA ROUTES
//
    CustomRoute<void>(
      page: ReplicaUploadTitle,
      name: 'ReplicaUploadTitle',
      path: 'replicaUploadTitle',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaUploadDescription,
      name: 'ReplicaUploadDescription',
      path: 'replicaUploadDescription',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaUploadReview,
      name: 'ReplicaUploadReview',
      path: 'replicaUploadReview',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaLinkHandler,
      name: 'ReplicaLinkHandler',
      path: 'replicaLinkHandler',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaMiscViewer,
      name: 'ReplicaMiscViewer',
      path: 'replicaMiscViewer',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaImageViewer,
      name: 'ReplicaImageViewer',
      path: 'replicaImageViewer',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaVideoViewer,
      name: 'ReplicaVideoViewer',
      path: 'replicaVideoViewer',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaAudioViewer,
      name: 'ReplicaAudioViewer',
      path: 'replicaAudioViewer',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: Support,
      name: 'Support',
      path: 'support',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
  ],
)
class $AppRouter {}
