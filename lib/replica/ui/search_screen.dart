import 'package:lantern/common/common.dart';
import 'package:lantern/replica/ui/listviews/app_listview.dart';
import 'package:lantern/replica/ui/listviews/audio_listview.dart';
import 'package:lantern/replica/ui/listviews/document_listview.dart';
import 'package:lantern/replica/ui/listviews/video_listview.dart';
import 'package:lantern/replica/ui/listviews/image_listview.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// ReplicaSearchScreen renders a text field with a TabBar to display the
// different categories. Each category is a child of ListView (except the
// 'image' tab, which is a child of GridView)
// Looks like this: docs/replica_search_tabs.png
class ReplicaSearchScreen extends StatefulWidget {
  ReplicaSearchScreen({Key? key, required this.searchQuery});
  final String searchQuery;

  @override
  _ReplicaSearchScreenState createState() =>
      _ReplicaSearchScreenState(searchQuery);
}

class _ReplicaSearchScreenState extends State<ReplicaSearchScreen>
    with TickerProviderStateMixin {
  late ValueNotifier<String> _searchQueryListener;
  late final TabController _tabController =
      // Video + Image + Audio + Document + App = 5 categories
      TabController(length: 5, vsync: this);
  late final TextEditingController _textEditingController;

  _ReplicaSearchScreenState(String searchQuery) {
    _textEditingController = TextEditingController(text: searchQuery);
    _searchQueryListener = ValueNotifier<String>(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        centerTitle: true,
        title: 'Discover'.i18n,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 30),
            // TODO duplicate of the other textfieldform. Do something about this
            TextFormField(
              controller: _textEditingController,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (query) {
                setState(() {
                  _searchQueryListener.value = query;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Material(
                  color: blue4,
                  child: IconButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {
                          _searchQueryListener.value =
                              _textEditingController.text;
                        });
                      },
                      icon: const Icon(Icons.search),
                      color: white),
                ),
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                    20.0, 10.0, 20.0, 10.0),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: blue4,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: blue4,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              indicatorColor: indicatorRed,
              isScrollable: true,
              labelStyle: const TextStyle(fontSize: 12.0),
              tabs: <Widget>[
                Tab(
                  text: 'Video'.i18n,
                ),
                Tab(
                  text: 'Image'.i18n,
                ),
                Tab(
                  text: 'Audio'.i18n,
                ),
                Tab(
                  text: 'Document'.i18n,
                ),
                Tab(
                  text: 'App'.i18n,
                ),
              ],
            ),
            const SizedBox(height: 5),
            // TODO ValueListenableBuilder may not be necessary: try without it (just with setState and see)
            ValueListenableBuilder<String>(
                valueListenable: _searchQueryListener,
                builder: (BuildContext context, String value, Widget? child) {
                  return Expanded(
                      child: TabBarView(
                    controller: _tabController,
                    children: [
                      ReplicaVideoListView(searchQuery: value),
                      ReplicaImageListView(searchQuery: value),
                      ReplicaAudioListView(searchQuery: value),
                      ReplicaDocumentListView(searchQuery: value),
                      ReplicaAppListView(searchQuery: value),
                    ],
                  ));
                }),
          ],
        ));
  }
}
