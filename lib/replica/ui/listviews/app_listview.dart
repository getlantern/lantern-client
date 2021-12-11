import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:lantern/replica/ui/listitems/app_listitem.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaAppListView extends ReplicaCommonListView {
  ReplicaAppListView({Key? key, required String searchQuery})
      : super(
            key: key,
            searchQuery: searchQuery,
            searchCategory: SearchCategory.App);
  @override
  State<StatefulWidget> createState() => _ReplicaAppListViewState();
}

class _ReplicaAppListViewState extends ReplicaCommonListViewState {
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
          return ReplicaAppListItem(
            item: item,
            onDownloadBtnPressed: () async {
              await replicaApi.download(item.replicaLink);
            },
            onShareBtnPressed:
                getCommonOnShareBtnPressedClosure(context, item.replicaLink),
            onTap: () async {
              await context.pushRoute(UnknownItemScreen(
                  replicaLink: item.replicaLink, category: SearchCategory.App));
            },
          );
        },
      ),
      separatorBuilder: (context, index) => const SizedBox.shrink(),
    );
  }
}
