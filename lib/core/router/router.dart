import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/account_management.dart';
import 'package:lantern/account/blocked_users.dart';
import 'package:lantern/account/chat_number_account.dart';
import 'package:lantern/account/device_linking/approve_device.dart';
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart';
import 'package:lantern/account/device_linking/authorize_device_via_email.dart';
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart';
import 'package:lantern/account/language.dart';
import 'package:lantern/account/plans/checkout.dart';
import 'package:lantern/account/plans/activation_code_checkout.dart';
import 'package:lantern/account/plans/stripe_checkout.dart';
import 'package:lantern/account/plans/upgrade.dart';
import 'package:lantern/account/recovery_key.dart';
import 'package:lantern/account/settings.dart';
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
import 'package:lantern/replica/ui/link_opener_screen.dart';
import 'package:lantern/replica/ui/media_views/audio_player_screen.dart';
import 'package:lantern/replica/ui/media_views/image_preview_screen.dart';
import 'package:lantern/replica/ui/media_views/pdf_screen.dart';
import 'package:lantern/replica/ui/media_views/unknown_item_screen.dart';
import 'package:lantern/replica/ui/media_views/video_player_screen.dart';
import 'package:lantern/replica/ui/search_screen.dart';
import 'package:lantern/replica/ui/upload_file.dart';

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
      page: FullScreenDialog,
      name: 'FullScreenDialogPage',
      path: 'fullScreenDialogPage',
      transitionsBuilder: popupTransition,
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
      page: AccountManagement,
      name: 'AccountManagement',
      path: 'accountManagement',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaLinkOpenerScreen,
      name: 'ReplicaLinkOpenerScreen',
      path: 'replicaLinkOpenerScreen',
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
      page: ReplicaVideoPlayerScreen,
      name: 'ReplicaVideoPlayerScreen',
      path: 'replicaVideoPlayerScreen',
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
      page: ReplicaAudioPlayerScreen,
      name: 'ReplicaAudioPlayerScreen',
      path: 'replicaAudioPlayerScreen',
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
      page: ReplicaImagePreviewScreen,
      name: 'ReplicaImagePreviewScreen',
      path: 'replicaImagePreviewScreen',
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
      page: RecoveryKey,
      name: 'RecoveryKey',
      path: 'recoveryKey',
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
      page: ReplicaPDFScreen,
      name: 'ReplicaPDFScreen',
      path: 'replicaPDFScreen',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaUnknownItemScreen,
      name: 'ReplicaUnknownItemScreen',
      path: 'replicaUnknownItemScreen',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaSearchScreen,
      name: 'ReplicaSearchScreen',
      path: 'replicaSearchScreen',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ReplicaUploadFileScreen,
      name: 'ReplicaUploadFileScreen',
      path: 'replicaUploadFileScreen',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: Upgrade,
      name: 'Upgrade',
      path: 'upgrade',
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
      page: StripeCheckout,
      name: 'StripeCheckout',
      path: 'stripeCheckout',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute<void>(
      page: ActivationCodeCheckout,
      name: 'ActivationCodeCheckout',
      path: 'activationCodeCheckout',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
  ],
)
class $AppRouter {}
