import 'package:auto_route/auto_route.dart';
import 'package:lantern/messaging/add_contact_QR.dart';
import 'package:lantern/messaging/add_contact_username.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/conversations.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/messaging/your_contact_info.dart';
import 'package:lantern/ui/index.dart';
import 'package:lantern/ui/widgets/account/developer_settings.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AdaptiveRoute<void>(
      initial: true,
      name: 'main',
      page: HomePage,
      path: '/main',
      children: [
        CustomRoute<void>(
          page: EmptyRouterPage,
          name: 'messages',
          path: 'messages',
          children: [
            CustomRoute<void>(
              page: Conversations,
              name: 'conversations',
              path: '',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: YourContactInfo,
              name: 'contactInfo',
              path: 'contactInfo',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: NewMessage,
              name: 'newMessage',
              path: 'newMessage',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: AddViaQR,
              name: 'addQR',
              path: 'addQR',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: AddViaUsername,
              name: 'addUsername',
              path: 'addUsername',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: Conversation,
              name: 'conversation',
              path: 'conversation',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
          ],
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 400,
        ),
        CustomRoute<void>(
          page: VPNTab,
          name: 'vpn',
          path: 'vpn',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 400,
        ),
        CustomRoute<void>(
          page: AccountTab,
          name: 'account',
          path: 'account',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 400,
        ),
        CustomRoute<void>(
          page: DeveloperSettingsTab,
          name: 'developer',
          path: 'developer',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 400,
        ),
      ],
    ),
  ],
)
class $AppRouter {}
