import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/model/messaging_model.dart';
import 'package:provider/provider.dart';

import '../extension/date_time_extensions.dart';
import '../i18n/i18n.dart';
import '../model/protos/messaging.pb.dart';

class MessagesTab extends StatefulWidget {
  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  static const int pageLength = 25;

  MessagingModel model;

  final PagingController<int, String> _conversationsPagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchConversationsPage(int pageKey) async {
    var page = await model.getRange<String>(
        "/conversationsByRecentActivity", pageKey, pageLength);
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

  Widget buildConversation(
      BuildContext context, String conversationID, int index) {
    return model.subscribedBuilder("/conversation/$conversationID",
        defaultValue: Conversation(), builder:
            (BuildContext context, Conversation conversation, Widget child) {
      return Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: conversation.userIDs.length == 0
                      ? Text("")
                      : model.subscribedBuilder(
                          "/contact/${conversation.userIDs[0]}",
                          defaultValue: Contact(), builder:
                              (BuildContext context, Contact contact,
                                  Widget child) {
                          return Text(contact.name,
                              style: TextStyle(fontWeight: FontWeight.bold));
                        }),
                ),
                Text(
                  DateTime.now()
                          .difference(
                              conversation.mostRecentMessageTime.toDateTime())
                          .humanized +
                      " " +
                      "ago".i18n,
                ),
              ],
            ),
            subtitle: Text(
              conversation.mostRecentMessage,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Divider(thickness: 1),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (model == null) {
      model = context.watch<MessagingModel>();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'.i18n),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          Icon(Icons.search),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Icon(Icons.qr_code),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PagedListView<int, String>(
              pagingController: _conversationsPagingController,
              builderDelegate: PagedChildBuilderDelegate<String>(
                itemBuilder: buildConversation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
