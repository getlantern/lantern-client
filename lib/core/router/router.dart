import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router_observer.dart';
import 'package:lantern/messaging/add_contact_QR.dart';
import 'package:lantern/messaging/add_contact_username.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/conversations.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/messaging/your_contact_info.dart';
import 'package:lantern/ui/index.dart';
import 'package:lantern/ui/widgets/account/developer_settings.dart';
import 'package:lantern/ui/widgets/account/device_linking/approve_device.dart';
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_for_pro.dart';
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_via_email.dart';
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_via_email_pin.dart';
import 'package:lantern/ui/widgets/account/language.dart';
import 'package:lantern/ui/widgets/account/pro_account.dart';
import 'package:lantern/ui/widgets/account/settings.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AutoRoute(
      initial: true,
      name: 'home',
      page: HomePage,
      path: '/',
      //guards: [RouterObserver],
      children: [
        CustomRoute<void>(
          page: EmptyRouterPage,
          name: 'MessagesRouter',
          path: 'messages',
          children: [
            CustomRoute<void>(
              page: Conversations,
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
              guards: [RouterObserver],
            ),
          ],
        ),
        CustomRoute<void>(
          page: EmptyRouterPage,
          name: 'VpnRouter',
          path: 'vpn',
          children: [
            CustomRoute<void>(
              page: VPNTab,
              name: 'vpn',
              path: '',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
          ],
        ),
        CustomRoute<void>(
          page: EmptyRouterPage,
          name: 'AccountRouter',
          path: 'account',
          children: [
            CustomRoute<void>(
              page: AccountTab,
              name: 'account',
              path: '',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: ProAccount,
              name: 'ProAccount',
              path: 'proAccount',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: Settings,
              name: 'Settings',
              path: 'settings',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: Language,
              name: 'Language',
              path: 'language',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: AuthorizeDeviceForPro,
              name: 'AuthorizePro',
              path: 'authorizePro',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: AuthorizeDeviceViaEmail,
              name: 'AuthorizeDeviceEmail',
              path: 'authorizeDeviceEmail',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: AuthorizeDeviceViaEmailPin,
              name: 'AuthorizeDeviceEmailPin',
              path: 'authorizeDeviceEmailPin',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
            CustomRoute<void>(
              page: ApproveDevice,
              name: 'ApproveDevice',
              path: 'approveDevice',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
          ],
        ),
        CustomRoute<void>(
          page: EmptyRouterPage,
          name: 'DeveloperRoute',
          path: 'developer',
          children: [
            CustomRoute<void>(
              page: DeveloperSettingsTab,
              name: 'developerSetting',
              path: '',
              transitionsBuilder: TransitionsBuilders.fadeIn,
              durationInMilliseconds: 400,
            ),
          ],
        ),
      ],
    ),
  ],
)
class $AppRouter {}
