import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

abstract class ReplicaCommonListView extends StatefulWidget {
  const ReplicaCommonListView({
    super.key,
    required this.replicaApi,
    required this.searchQuery,
    required this.searchCategory,
  });

  final ReplicaApi replicaApi;
  final String searchQuery;
  final SearchCategory searchCategory;
}

abstract class ReplicaCommonListViewState extends State<ReplicaCommonListView> {
  final PagingController<int, ReplicaSearchItem> pagingController =
      PagingController(firstPageKey: 0);
  String lastSearchQuery = '';

  @override
  void initState() {
    logger.t('applistview: $lastSearchQuery');

    lastSearchQuery = widget.searchQuery;
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    pagingController.addStatusListener((status) {
      // XXX <29-11-2021> soltzen: all fetching errors will be handled here.
      // The default behaviour is to display an error message. This is done in
      // renderListView() after we trigger a widget tree refresh here.
      // Ideally, show different errors differently.
      if (status == PagingStatus.firstPageError ||
          status == PagingStatus.subsequentPageError) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  Future<void> fetchPage(int page) async {
    logger.v('fetchPage($page)');
    try {
      final ret = await widget.replicaApi.search(
        lastSearchQuery,
        widget.searchCategory,
        page,
        Localization.localeShort,
      );
      if (ret.isEmpty) {
        logger.v('Successfully fetched the last page [${ret.length} items]');
        if (mounted) {
          pagingController.appendLastPage(ret);
        }
      } else {
        final nextPageKey = page + ret.length;
        logger.v(
          'Successfully fetched ${ret.length} items. Next key is $nextPageKey',
        );
        if (mounted) {
          pagingController.appendPage(ret, nextPageKey);
        }
      }
    } catch (err) {
      if (err is DioError) {
        logger.e('fetchPage err: ${err.error}');
      } else {
        logger.e('fetchPage err: $err');
      }

      if (mounted) {
        pagingController.error = 'fetching search result with $err';
      }
    }
  }

  double getCommonCacheExtent(List<dynamic>? list) {
    if (list != null) {
      return list.length * 20;
    }
    return 600;
  }

  Widget renderNoItemsFoundWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CAssetImage(
          path: ImagePaths.search_empty,
          size: 168,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 16),
          child: CText(
            'no_search_result_found'.i18n,
            style: tsBody1,
          ),
        ),
      ],
    );
  }

  /// prebuild runs a few checks before build() is called.  If it returns a
  /// Widget, the caller MUST return that widget in their build() method.
  Widget? prebuild(BuildContext context) {
    // XXX <08-12-2021> soltzen: Explicitly trigger a refresh, if the 'last
    // search query' this state did is not the same as the 'current search
    // query' our parent widget has.
    //
    // This is needed if our parent's parent widget (i.e., the main Replica
    // search bar in replica/ui/search_screen.dart) has a new search. When
    // that happens, this widget will be rebuilt, but the list will not be
    // refreshed automatically.
    if (lastSearchQuery != widget.searchQuery) {
      lastSearchQuery = widget.searchQuery;
      pagingController.refresh();
    }
    if (pagingController.error != null) {
      return renderReplicaErrorUI(text: 'search_result_error'.i18n);
    }
    return null;
  }

  Widget renderPaginatedListView(
    ItemWidgetBuilder<ReplicaSearchItem> itemBuilder,
  ) {
    var w = prebuild(context);
    if (w != null) {
      return w;
    }

    return PagedListView<int, ReplicaSearchItem>.separated(
      cacheExtent: getCommonCacheExtent(pagingController.value.itemList),
      scrollDirection: Axis.vertical,
      pagingController: pagingController,
      physics: defaultScrollPhysics,
      builderDelegate: PagedChildBuilderDelegate<ReplicaSearchItem>(
        animateTransitions: true,
        noItemsFoundIndicatorBuilder: (context) {
          return renderNoItemsFoundWidget();
        },
        itemBuilder: itemBuilder,
      ),
      separatorBuilder: (context, index) => const SizedBox.shrink(),
    );
  }
}
