import 'package:lantern/package_store.dart';
import 'package:lantern/ui/messaging/new_message.dart';
import 'package:lantern/ui/messaging/your_contact_info.dart';

import 'add_contact.dart';
import 'conversation.dart';
import 'conversations.dart';

class MessagesTab extends StatefulWidget {
  final String _initialRoute;
  final dynamic _initialRouteArguments;

  MessagesTab(this._initialRoute, this._initialRouteArguments);

  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
        initialRoute: widget._initialRoute,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (BuildContext _) => Conversations();
              break;
            case '/your_contact_info':
              builder = (BuildContext _) => YourContactInfo();
              break;
            case '/new_message':
              builder = (BuildContext _) => NewMessage();
              break;
            case '/add_contact':
              builder = (BuildContext _) => AddContact();
              break;
            case '/conversation':
              builder = (BuildContext context) => Conversation(
                  settings.arguments ?? widget._initialRouteArguments);
              break;
            default:
              throw Exception("unknown route ${settings.name}");
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        });
  }

  /// This captures the back-button and makes sure it's used to pop the scope on
  /// the navigator inside the messaging tab.
  WidgetBuilder willPopScopeBuilder(WidgetBuilder wrapped) {
    return (BuildContext context) =>
        new WillPopScope(child: wrapped(context), onWillPop: _onWillPop);
  }

  Future<bool> _onWillPop() {
    Navigator.pop(context);
    return Future.value(false);
  }

  @override
  bool get wantKeepAlive => true;
}
