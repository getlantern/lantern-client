import 'dart:async';
import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router.gr.dart' as router;
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/app_item.dart';
import 'package:lantern/replica/models/audio_item.dart';
import 'package:lantern/replica/models/document_item.dart';
import 'package:lantern/replica/models/image_item.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/models/video_item.dart';
import 'package:lantern/replica/models/web_item.dart';
import 'package:lantern/replica/ui/app_listitem.dart';
import 'package:lantern/replica/ui/audio_listitem.dart';
import 'package:lantern/replica/ui/document_listitem.dart';
import 'package:lantern/replica/ui/image_listitem.dart';
import 'package:lantern/replica/ui/searchcategory.dart';
import 'package:lantern/replica/ui/web_listitem.dart';
import 'package:lantern/replica/ui/video_listitem.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaSearchScreen extends StatefulWidget {
  @override
  _ReplicaSearchScreenState createState() => _ReplicaSearchScreenState();
}

class _ReplicaSearchScreenState extends State<ReplicaSearchScreen> {
  // Default category is Video
  SearchCategory _category = SearchCategory.Video;
  String _selectedSearchQuery = '';
  final TextEditingController _textFieldController = TextEditingController();
  final PagingController<int, ReplicaSearchItem> _pagingController =
      PagingController(firstPageKey: 0);
  final ReplicaApi _replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);
  // final focusNode = FocusNode();

  // bool interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info) {
  //   focusNode.unfocus();
  //   if (keyboardMode == KeyboardMode.emoji) {
  //     setState(() {
  //       keyboardMode = KeyboardMode.none;
  //     });
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    _pagingController.addStatusListener((status) {
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
    // BackButtonInterceptor.add(interceptBackButton);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int page) async {
    logger.v('_fetchPage($page)');
    try {
      final ret = await _replicaApi.search(
        _selectedSearchQuery,
        _category,
        page,
        'en', // TODO <07-12-2021> soltzen: support more than one locale
      );
      final nextPageKey = page + ret.length;
      print(
          'XXX Successfully fetched ${ret.length} items. Next key is $nextPageKey');
      _pagingController.appendPage(ret, nextPageKey);
    } catch (err) {
      logger.v('_fetchPage err: $err');
      _pagingController.error = 'fetching search result with $err';
    }
  }

  double _getCacheExtent(List<dynamic>? list) {
    logger.v('XXX getCacheExtent for a list of length ${list?.length}');
    if (list != null) {
      return list.length * 20;
    }
    return 600;
  }

  Widget renderListView(BuildContext context) {
    print(
        'XXX renderListView: query: $_selectedSearchQuery | category: $_category');
    if (_pagingController.error != null) {
      return showError(_pagingController.error);
    }

    return Flexible(
        child: PagedListView<int, ReplicaSearchItem>.separated(
      cacheExtent: _getCacheExtent(_pagingController.value.itemList),
      scrollDirection: Axis.vertical,
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<ReplicaSearchItem>(
        animateTransitions: true,
        itemBuilder: (context, item, index) {
          var onDownloadBtnPressed = () async {
            logger.v('onDownloadBtnPressed');
            if (item.replicaLink == null) {
              throw Exception(
                  'Invoked download on a non-downloadable item: $item');
            }
            try {
              await _replicaApi.download(item.replicaLink!, item.displayName);
            } catch (ex) {
              logger.e('Failed to download item: $ex');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Failed to download item'),
              ));
            }
          };

          var onShareBtnPressed = () async {
            await FlutterShare.share(
                title: 'Lantern',
                text: 'Share text',
                linkUrl: item.replicaLink!.toMagnetLink(),
                chooserTitle: 'Example Chooser Title');
          };

          switch (_category) {
            case SearchCategory.Web:
              return ReplicaWebListTile(
                webItem: item as ReplicaWebItem,
                onTap: (link) async {
                  if (!await launch(link)) throw 'Could not launch $link';
                },
              );
            case SearchCategory.Video:
              return ReplicaVideoListTile(
                  videoItem: item as ReplicaVideoItem,
                  onDownloadBtnPressed: onDownloadBtnPressed,
                  onShareBtnPressed: onShareBtnPressed,
                  replicaApi: _replicaApi,
                  onTap: (link) {
                    context.pushRoute(
                        router.ReplicaVideoPlayerScreen(replicaLink: link));
                  });
            case SearchCategory.Audio:
              return ReplicaAudioListTile(
                audioItem: item as ReplicaAudioItem,
                onDownloadBtnPressed: onDownloadBtnPressed,
                onShareBtnPressed: onShareBtnPressed,
              );
            case SearchCategory.Image:
              return ReplicaImageListTile(
                imageItem: item as ReplicaImageItem,
                onDownloadBtnPressed: onDownloadBtnPressed,
                onShareBtnPressed: onShareBtnPressed,
                replicaApi: _replicaApi,
              );
            case SearchCategory.Document:
              return ReplicaDocumentListTile(
                documentItem: item as ReplicaDocumentItem,
                onDownloadBtnPressed: onDownloadBtnPressed,
                onShareBtnPressed: onShareBtnPressed,
              );
            case SearchCategory.App:
              return ReplicaAppListTile(
                appItem: item as ReplicaAppItem,
                onDownloadBtnPressed: onDownloadBtnPressed,
                onShareBtnPressed: onShareBtnPressed,
              );
            case SearchCategory.Unknown:
              throw Exception('Unknown category. Should never happen');
          }
        },
      ),
      separatorBuilder: (context, index) => const SizedBox.shrink(),
    ));
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

  Widget renderTextField(int flex) {
    return Flexible(
        flex: flex,
        child: WillPopScope(
            onWillPop: () async {
              FocusScope.of(context).unfocus();
              return true;
            },
            child: TextFormField(
              controller: _textFieldController,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (query) async {
                // Set this initially to show the spinner
                setState(() {
                  _selectedSearchQuery = query;
                  _pagingController.refresh();
                });
              },
              onTap: () {
                setState(() {
                  _textFieldController.clear();
                  _selectedSearchQuery = '';
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
            )));
  }

  List<DropdownMenuItem<String>> getCategoryItems() => SearchCategory.values
      .map((cat) => DropdownMenuItem<String>(
          value: cat.toShortString(), child: Text(cat.toShortString())))
      .toList();

  Widget renderDropdownCategories(int flex) {
    return Flexible(
        flex: flex,
        child: DropdownButtonFormField<String>(
          items: getCategoryItems(),
          value: _category.toShortString(),
          onChanged: (v) {
            if (v != null) {
              // setState(() {
              _category = EnumToString.fromString(SearchCategory.values, v)!;
              logger.v('switching category: $_category');
              // });
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
            // Dismisses soft keyboard on tab anywhere
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      renderTextField(7),
                      renderDropdownCategories(3),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (_selectedSearchQuery.isNotEmpty) renderListView(context)
              ],
            )));
  }
}
