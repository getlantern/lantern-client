import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:lantern/replica/ui/listitems/document_listitem.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

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
    print('XXX renderListView: query: ${super.lastSearchQuery}');
    var w = super.prebuild(context);
    if (w != null) {
      return w;
    }
    return PagedListView<int, ReplicaSearchItem>.separated(
      cacheExtent:
          super.getCommonCacheExtent(super.pagingController.value.itemList),
      scrollDirection: Axis.vertical,
      pagingController: super.pagingController,
      builderDelegate: PagedChildBuilderDelegate<ReplicaSearchItem>(
        animateTransitions: true,
        itemBuilder: (context, item, index) {
          return ReplicaDocumentListItem(
            item: item,
            onDownloadBtnPressed: () async {
              await replicaApi.download(item.replicaLink);
            },
            onShareBtnPressed:
                getCommonOnShareBtnPressedClosure(context, item.replicaLink),
            onTap: () {
              context.pushRoute(UnknownItemScreen(
                replicaLink: item.replicaLink,
                category: SearchCategory.Document,
              ));
            },
          );
        },
      ),
      separatorBuilder: (context, index) => const SizedBox.shrink(),
    );
  }
}
