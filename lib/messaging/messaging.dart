import 'package:lantern/package_store.dart';

import 'conversations.dart';

class MessagesTab extends StatefulWidget {
  MessagesTab();

  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Conversations();
    // Navigator(
    //     initialRoute: widget._initialRoute,
    //     onGenerateRoute: (RouteSettings settings) {
    //       WidgetBuilder builder;
    //       switch (settings.name) {
    //         case '/':
    //           builder = (BuildContext _) => Conversations();
    //           break;
    //         case '/your_contact_info':
    //           builder = (BuildContext _) => YourContactInfo();
    //           break;
    //         case '/new_message':
    //           builder = (BuildContext _) => NewMessage();
    //           break;
    //         case '/add_contact_QR':
    //           builder = (BuildContext _) => AddViaQR();
    //           break;
    //         case '/add_contact_username':
    //           builder = (BuildContext _) => AddViaUsername();
    //           break;
    //         case '/conversation':
    //           builder = (BuildContext context) => Conversation(
    //                 settings.arguments ?? widget._initialRouteArguments,
    //               );
    //           break;
    //         default:
    //           throw Exception('unknown route ${settings.name}');
    //       }
    //       return MaterialPageRoute(builder: builder, settings: settings);
    //     });
  }

  @override
  bool get wantKeepAlive => true;
}
