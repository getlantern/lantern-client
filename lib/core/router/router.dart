import 'package:lantern/common/common.dart';

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
        page: Account.page,
        path: '/account',
        transitionsBuilder: defaultTransition,
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
        page: PlayCheckout.page,
        path: '/playcheckout',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: Checkout.page,
        path: '/checkout',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: ResellerCodeCheckout.page,
        path: '/resellerCodeCheckout',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: StripeCheckout.page,
        path: '/stripeCheckout',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute(
        page: PlansPage.page,
        path: '/plans',
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
    CustomRoute(
      page: ReportIssue.page,
      path: '/reportIssue',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute(
      page: InviteFriends.page,
      path: '/inviteFriends',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute(
      page: LanternDesktop.page,
      path: '/lanternDesktop',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute(
      page: LinkDevice.page,
      path: '/linkDevice',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
    CustomRoute(
      page: AppWebview.page,
      path: '/app_webview',
      transitionsBuilder: defaultTransition,
      durationInMilliseconds: defaultTransitionMillis,
      reverseDurationInMilliseconds: defaultTransitionMillis,
    ),
  ];
}
