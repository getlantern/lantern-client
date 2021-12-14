import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/listitems/audio_listitem.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaAppListView renders a list of ReplicaAudioListItem
/// Looks like this docs/replica_audio_listview.png
class ReplicaAudioListView extends ReplicaCommonListView {
  ReplicaAudioListView({Key? key, required String searchQuery})
      : super(
            key: key,
            searchQuery: searchQuery,
            searchCategory: SearchCategory.Audio);
  @override
  State<StatefulWidget> createState() => _ReplicaAudioListViewState();
}

class _ReplicaAudioListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
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
          return ReplicaAudioListItem(
            item: item,
            onTap: () {
              context.pushRoute(ReplicaAudioPlayerScreen(
                  replicaLink: item.replicaLink,
                  mimeType: item.primaryMimeType));
            },
            replicaApi: super.replicaApi,
          );
        },
      ),
      separatorBuilder: (context, index) => const SizedBox.shrink(),
    );
  }
}
