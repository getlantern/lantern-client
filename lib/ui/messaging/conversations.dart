import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class Conversations extends StatefulWidget {
  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  static const int pageLength = 25;

  MessagingModel model;

  // final PagingController<int, Conversation> _pagingController =
  //     PagingController(firstPageKey: 0);
  //
  // Future<void> _fetchPage(int pageKey) async {
  //   var page = await model.list<Conversation>("/cbt",
  //       start: pageKey, count: pageLength, reverseSort: true);
  //   var isLastPage = page.length < pageLength;
  //   if (isLastPage) {
  //     _pagingController.appendLastPage(page);
  //   } else {
  //     _pagingController.appendPage(page, pageKey + pageLength);
  //   }
  // }
  //
  // @override
  // void initState() {
  //   _pagingController.addPageRequestListener((pageKey) {
  //     _fetchPage(pageKey);
  //   });
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   _pagingController.dispose();
  //   super.dispose();
  // }

  // Widget buildConversation(
  //     BuildContext context, Conversation conversation, int index) {
  //   return model.conversation(conversation,
  //       (BuildContext context, Conversation conversation, Widget child) {
  //     return Column(
  //       children: [
  //         ListTile(
  //           title: model.contactOrGroup(conversation,
  //               (BuildContext context, dynamic contactOrGroup, Widget child) {
  //             return Text("$contactOrGroup.displayName ($contactOrGroup.id)",
  //                 style: TextStyle(fontWeight: FontWeight.bold));
  //           }),
  //           subtitle: Text(
  //             conversation.mostRecentMessageText ?? "voice memo".i18n,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //         Divider(thickness: 1),
  //       ],
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();

    return BaseScreen(
        title: 'Messages'.i18n,
        actions: [
          IconButton(
              icon: Icon(Icons.qr_code),
              tooltip: "Your Contact Info".i18n,
              onPressed: () {
                Navigator.restorablePushNamed(context, 'your_contact_info');
              }),
        ],
        body: Container(),
        actionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.restorablePushNamed(context, 'new_message');
          },
        ));
  }
}
