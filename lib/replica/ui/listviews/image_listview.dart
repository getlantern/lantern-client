import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:lantern/replica/ui/listitems/image_listitem.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaImageListView renders a list of ReplicaImageListItem.
/// Looks like this docs/replica_image_listview.png
class ReplicaImageListView extends ReplicaCommonListView {
  ReplicaImageListView({Key? key, required String searchQuery})
      : super(
            key: key,
            searchQuery: searchQuery,
            searchCategory: SearchCategory.Image);

  @override
  State<StatefulWidget> createState() => _ReplicaImageListViewState();
}

class _ReplicaImageListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    var w = super.prebuild(context);
    if (w != null) {
      return w;
    }
    return PagedGridView<int, ReplicaSearchItem>(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 10.0,
      ),
      cacheExtent:
          super.getCommonCacheExtent(super.pagingController.value.itemList),
      scrollDirection: Axis.vertical,
      pagingController: super.pagingController,
      builderDelegate: PagedChildBuilderDelegate<ReplicaSearchItem>(
        animateTransitions: true,
        itemBuilder: (context, item, index) {
          return ReplicaImageListItem(
            item: item,
            onDownloadBtnPressed: () async {
              await replicaApi.download(item.replicaLink);
            },
            onShareBtnPressed: () async {
              await Share.share(item.replicaLink.toMagnetLink());
            },
            replicaApi: super.replicaApi,
            onTap: () async {
              await context.pushRoute(
                  ReplicaImagePreviewScreen(replicaLink: item.replicaLink));
            },
          );
        },
      ),
    );
  }
}
