import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class NewMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'New Message'.i18n,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text('Add Contact'.i18n),
        ),
        Divider(thickness: 1),
        ListTile(
          leading: Icon(Icons.group_add),
          title: Text('New Group Message'.i18n),
        ),
        Expanded(
          child: FutureBuilder<List<Conversation>>(
              future: model.recentConversations(count: 10),
              builder: (context, AsyncSnapshot<List<Conversation>> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var recentConversations = snapshot.data;
                return ListView.builder(
                  itemCount: recentConversations.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${recentConversations[index]}'),
                    );
                  },
                );
              }),
        )
      ]),
    );
  }
}
