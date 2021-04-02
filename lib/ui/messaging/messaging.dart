import 'package:lantern/package_store.dart';
import 'package:lantern/ui/messaging/new_message.dart';
import 'package:lantern/ui/messaging/your_contact_info.dart';

import 'add_contact.dart';
import 'conversation.dart';
import 'conversations.dart';

class MessagesTab extends StatefulWidget {
  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab>
    with AutomaticKeepAliveClientMixin {
  var navigator = Navigator(
      initialRoute: 'conversations',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'conversations':
            builder = (BuildContext _) => Conversations();
            break;
          case 'your_contact_info':
            builder = (BuildContext _) => YourContactInfo();
            break;
          case 'new_message':
            builder = (BuildContext _) => NewMessage();
            break;
          case 'add_contact':
            builder = (BuildContext _) => AddContact();
            break;
          case 'conversation':
            builder =
                (BuildContext context) => Conversation(settings.arguments);
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return navigator;
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
