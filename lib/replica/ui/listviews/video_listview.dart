import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/listitems/video_listitem.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaVideoListView extends ReplicaCommonListView {
  ReplicaVideoListView({Key? key, required String searchQuery})
      : super(
            key: key,
            searchQuery: searchQuery,
            searchCategory: SearchCategory.Video);
  @override
  State<StatefulWidget> createState() => _ReplicaVideoListViewState();
}

class _ReplicaVideoListViewState extends ReplicaCommonListViewState {
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
          return ReplicaVideoListItem(
              item: item,
              onDownloadBtnPressed: () async {
                await replicaApi.download(item.replicaLink);
              },
              onShareBtnPressed:
                  getCommonOnShareBtnPressedClosure(context, item.replicaLink),
              replicaApi: super.replicaApi,
              onTap: () {
                context.pushRoute(ReplicaVideoPlayerScreen(
                    replicaLink: item.replicaLink,
                    mimeType: item.primaryMimeType));
              });
        },
      ),
      separatorBuilder: (context, index) => const SizedBox.shrink(),
    );
  }
}
