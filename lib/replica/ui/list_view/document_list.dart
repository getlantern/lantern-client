import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/replica/common.dart';

/// ReplicaDocumentListView renders a list of ReplicaDocumentListItem.
/// Looks very similar to ReplicaAppListView
/// Looks like this docs/replica_document_listview.png
class ReplicaDocumentListView extends ReplicaCommonListView {
  ReplicaDocumentListView({
    Key? key,
    required ReplicaApi replicaApi,
    required String searchQuery,
  }) : super(
          key: key,
          replicaApi: replicaApi,
          searchQuery: searchQuery,
          searchCategory: SearchCategory.Document,
        );

  @override
  State<StatefulWidget> createState() => _ReplicaDocumentListViewState();
}

class _ReplicaDocumentListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    return renderPaginatedListView((context, item, index) {
      return ReplicaDocumentListItem(
        item: item,
        replicaApi: widget.replicaApi,
        onTap: () async {
          await context.pushRoute(
            ReplicaMiscViewer(
              item: item,
              replicaApi: widget.replicaApi,
              category: SearchCategory.Document,
            ),
          );
        },
      );
    });
  }
}
