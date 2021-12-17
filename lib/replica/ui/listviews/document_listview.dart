import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:lantern/replica/ui/listitems/document_listitem.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaDocumentListView renders a list of ReplicaDocumentListItem.
/// Looks very similar to ReplicaAppListView
/// Looks like this docs/replica_document_listview.png
class ReplicaDocumentListView extends ReplicaCommonListView {
  ReplicaDocumentListView({Key? key, required String searchQuery})
      : super(
            key: key,
            searchQuery: searchQuery,
            searchCategory: SearchCategory.Document);
  @override
  State<StatefulWidget> createState() => _ReplicaDocumentListViewState();
}

class _ReplicaDocumentListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    return renderPaginatedListView((context, item, index) {
      return ReplicaDocumentListItem(
        item: item,
        replicaApi: replicaApi,
        onTap: () {
          context.pushRoute(ReplicaUnknownItemScreen(
            replicaLink: item.replicaLink,
            category: SearchCategory.Document,
          ));
        },
      );
    });
  }
}
