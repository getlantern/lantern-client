import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

abstract class ReplicaCommonListView extends StatefulWidget {
  ReplicaCommonListView(
      {Key? key, required this.searchQuery, required this.searchCategory});

  final String searchQuery;
  final SearchCategory searchCategory;
}

abstract class ReplicaCommonListViewState extends State<ReplicaCommonListView> {
  final PagingController<int, ReplicaSearchItem> pagingController =
      PagingController(firstPageKey: 0);
  final ReplicaApi replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);
  String lastSearchQuery = '';

  @override
  void initState() {
    logger.v('applistview: $lastSearchQuery');

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
      final ret = await replicaApi.search(
        lastSearchQuery,
        widget.searchCategory,
        page,
        'en', // TODO <07-12-2021> soltzen: support more than one locale
      );
      if (ret.isEmpty) {
        logger.v('Successfully fetched the last page [${ret.length} items]');
        pagingController.appendLastPage(ret);
      } else {
        final nextPageKey = page + ret.length;
        logger.v(
            'Successfully fetched ${ret.length} items. Next key is $nextPageKey');
        pagingController.appendPage(ret, nextPageKey);
      }
    } catch (err) {
      logger.v('fetchPage err: $err');
      if (mounted) {
        pagingController.error = 'fetching search result with $err';
      }
    }
  }

  Widget showError(String err) {
    logger.v('showError(): $err');
    return Expanded(
        child: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Flexible(
              child: Text(
            'Error: $err',
          ))
        ])));
  }

  double getCommonCacheExtent(List<dynamic>? list) {
    if (list != null) {
      return list.length * 20;
    }
    return 600;
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
      return showError(pagingController.error);
    }
    return null;
  }
}
