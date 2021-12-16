import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listitems/app_listitem.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaAppListView renders 'App' Replica items
/// Looks quite similar to ReplicaDocumentListView: docs/replica_app_listview.png
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
    logger.v('renderListView: query: ${super.lastSearchQuery}');
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
        noItemsFoundIndicatorBuilder: (context) {
          return Column(
            children: [
              const CAssetImage(
                path: ImagePaths.unknown,
                size: 168,
              ),
              CText(
                'Sorry, we couldn’t find anything matching that search'.i18n,
                style: tsBody1,
              ),
            ],
          );
        },
        itemBuilder: (context, item, index) {
          return ReplicaAppListItem(
            item: item,
            replicaApi: replicaApi,
            onTap: () async {
              await context.pushRoute(ReplicaUnknownItemScreen(
                  replicaLink: item.replicaLink, category: SearchCategory.App));
            },
          );
        },
      ),
      separatorBuilder: (context, index) => const SizedBox.shrink(),
    );
  }
}
