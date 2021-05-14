import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/back_button_respecting_navigator.dart';

import '../../routes.dart';
import 'account_menu.dart';
import 'device_linking/authorize_device_for_pro.dart';
import 'device_linking/authorize_device_via_email.dart';
import 'device_linking/authorize_device_via_email_pin.dart';
import 'language.dart';
import 'settings.dart';

class AccountTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackButtonRespectingNavigator(
        onGenerateRoute: (RouteSettings settings) {
      WidgetBuilder builder;
      switch (settings.name) {
        case '/':
          builder = (BuildContext _) => AccountMenu();
          break;
        case routeSettings:
          builder = (BuildContext _) => Settings();
          break;
        case routeLanguage:
          builder = (BuildContext _) => Language();
          break;
        case routeAuthorizeDeviceForPro:
          builder = (BuildContext _) => AuthorizeDeviceForPro();
          break;
        case routeAuthorizeDeviceViaEmail:
          builder = (BuildContext _) => AuthorizeDeviceViaEmail();
          break;
        case routeAuthorizeDeviceViaEmailPin:
          builder = (BuildContext _) => AuthorizeDeviceViaEmailPin();
          break;
        default:
          throw Exception('unknown route ${settings.name}');
      }
      return MaterialPageRoute(builder: builder, settings: settings);
    });
  }
}
