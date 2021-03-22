import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/messaging/new_message.dart';
import 'package:lantern/ui/messaging/your_contact_info.dart';

import 'conversations.dart';

class MessagesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var messagingModel = context.watch<MessagingModel>();

    return Navigator(
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
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
