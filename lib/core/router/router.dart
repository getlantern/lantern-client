import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/core/router/tabs/account_tab_router.dart';
import 'package:lantern/core/router/tabs/developer_tab_router.dart';
import 'package:lantern/core/router/tabs/message_tab_router.dart';
import 'package:lantern/core/router/tabs/replica_tab_router.dart';
import 'package:lantern/core/router/tabs/vpn_tab_router.dart';
import 'package:lantern/messaging/conversation/conversation.dart';
import 'package:lantern/messaging/contacts/new_message.dart';
import 'package:lantern/home.dart';
import 'package:lantern/common/ui/full_screen_dialog.dart';
import 'package:lantern/messaging/introductions/introduce.dart';
import 'package:lantern/messaging/introductions/introductions.dart';
import 'package:lantern/replica/ui/image_preview_screen.dart';
import 'package:lantern/replica/ui/link_opener_screen.dart';
import 'package:lantern/replica/ui/media_views/audio_player.dart';
import 'package:lantern/replica/ui/search_screen.dart';
import 'package:lantern/replica/ui/unknown_item_screen.dart';
import 'package:lantern/replica/ui/media_views/video_player.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AutoRoute(
      initial: true,
      name: 'Home',
      page: HomePage,
      path: '/',
      children: [
        message_tab_router,
        vpn_tab_router,
        account_tab_router,
        developer_tab_router,
        replica_tab_router,
      ],
    ),
    CustomRoute<void>(
        page: FullScreenDialog,
        name: 'FullScreenDialogPage',
        path: 'fullScreenDialogPage',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Conversation,
        name: 'Conversation',
        path: 'conversation',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: NewMessage,
        name: 'NewMessage',
        path: 'newMessage',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Introduce,
        name: 'Introduce',
        path: 'introduce',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Introductions,
        name: 'Introductions',
        path: 'introductions',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: ReplicaLinkOpenerScreen,
        name: 'LinkOpenerScreen',
        path: 'linkOpenerScreen',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: ReplicaVideoPlayerScreen,
        name: 'ReplicaVideoPlayerScreen',
        path: 'replicaVideoPlayerScreen',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: ReplicaAudioPlayerScreen,
        name: 'ReplicaAudioPlayerScreen',
        path: 'replicaAudioPlayerScreen',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: ReplicaImagePreviewScreen,
        name: 'ReplicaImagePreviewScreen',
        path: 'replicaImagePreviewScreen',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: ReplicaUnknownItemScreen,
        name: 'UnknownItemScreen',
        path: 'unknownItemScreen',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: ReplicaSearchScreen,
        name: 'ReplicaSearchScreen',
        path: 'replicaSearchScreen',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
)
class $AppRouter {}
