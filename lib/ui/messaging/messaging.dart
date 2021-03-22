import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class MessagesTab extends StatefulWidget {
  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  static const int pageLength = 25;

  MessagingModel model;

  final PagingController<int, Conversation> _conversationsPagingController =
  PagingController(firstPageKey: 0);

  Future<void> _fetchConversationsPage(int pageKey) async {
    var page = await model.getRange<Conversation>(
        "/cbt", pageKey, pageLength);
    var isLastPage = page.length < pageLength;
    if (isLastPage) {
      _conversationsPagingController.appendLastPage(page);
    } else {
      _conversationsPagingController.appendPage(page, pageKey + pageLength);
    }
  }

  @override
  void initState() {
    _conversationsPagingController.addPageRequestListener((pageKey) {
      _fetchConversationsPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _conversationsPagingController.dispose();
    super.dispose();
  }

  Widget buildConversation(BuildContext context, Conversation conversation,
      int index) {
    return model.conversation(conversation,
            (BuildContext context, Conversation conversation, Widget child) {
          return Column(
            children: [
              ListTile(
                title: model.contactOrGroup(
                    conversation, (BuildContext context,
                    dynamic contactOrGroup,
                    Widget child) {
                  return Text(
                      "$contactOrGroup.displayName ($contactOrGroup.id)",
                      style: TextStyle(fontWeight: FontWeight.bold));
                }),
                subtitle: Text(
                  conversation.mostRecentMessageText ?? "voice memo".i18n,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(thickness: 1),
            ],
          );
        });
  }

  onSearch() {}

  onScanQR() {}

  @override
  Widget build(BuildContext context) {
    var messagingModel = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'Messages'.i18n,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          ],
        ),
      ),
    );
  }
}
