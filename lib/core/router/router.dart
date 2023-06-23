import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/core/router/router.gr.dart';
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
import 'package:lantern/vpn/vpn_split_tunneling.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page,Route,Screen',
)
class AppRouter extends $AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();
  @override
  final List<AutoRoute> routes = [
    AutoRoute(path: '/', page: Home.page),
    CustomRoute(
        page: FullScreenDialogPage.page,
        path: '/fullScreenDialogPage',
        transitionsBuilder: popupTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: AccountManagement.page,
        path: '/accountManagement',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: Settings.page,
        path: '/settings',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: SplitTunneling.page,
        path: '/splitTunneling',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: Language.page,
        path: '/language',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: AuthorizePro.page,
        path: '/authorizePro',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: AuthorizeDeviceEmail.page,
        path: '/authorizeDeviceEmail',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: AuthorizeDeviceEmailPin.page,
        path: '/authorizeDeviceEmailPin',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ApproveDevice.page,
        path: '/approveDevice',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: RecoveryKey.page,
        path: '/recoveryKey',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ChatNumberRecovery.page,
        path: '/chatNumberRecovery',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ChatNumberMessaging.page,
        path: '/chatNumberMessaging',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: Conversation.page,
        path: '/conversation',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ContactInfo.page,
        path: '/contactInfo',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: NewChat.page,
        path: '/newChat',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: AddViaChatNumber.page,
        path: '/addViaChatNumber',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: Introduce.page,
        path: '/introduce',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: Introductions.page,
        path: '/introductions',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ChatNumberAccount.page,
        path: '/chatNumberAccount',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: BlockedUsers.page,
        path: '/blockedUsers',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ReplicaUploadTitle.page,
        path: '/replicaUploadTitle',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ReplicaUploadDescription.page,
        path: '/replicaUploadDescription',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ReplicaUploadReview.page,
        path: '/replicaUploadReview',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ReplicaLinkHandler.page,
        path: '/replicaLinkHandler',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ReplicaMiscViewer.page,
        path: '/replicaMiscViewer',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ReplicaImageViewer.page,
        path: '/replicaImageViewer',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ReplicaVideoViewer.page,
        path: '/replicaVideoViewer',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ReplicaAudioViewer.page,
        path: '/replicaAudioViewer',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: Support.page,
        path: '/support',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ];
}
