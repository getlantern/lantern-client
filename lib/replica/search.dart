import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

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
  late ValueNotifier<String> searchQueryListener;
  late final TabController tabController =
      // Video + Image + Audio + Document + App = 5 categories
      TabController(length: 5, vsync: this);
  final formKey = GlobalKey<FormState>(debugLabel: 'replicaSearchInput');
  late final CustomTextEditingController textEditingController;

  _ReplicaSearchScreenState(String searchQuery) {
    textEditingController =
        CustomTextEditingController(formKey: formKey, text: searchQuery);
    if (searchQuery != '') {
      searchQueryListener = ValueNotifier<String>(searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      centerTitle: true,
      title: 'discover'.i18n,
      actions: [
        IconButton(
          onPressed: () async {
            await onUploadButtonPressed(context);
          },
          icon: CAssetImage(
            size: 20,
            path: ImagePaths.file_upload,
            color: black,
          ),
        ),
      ],
      body: replicaModel.withReplicaApi((context, replicaApi, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 30),
            SearchField(
              controller: textEditingController,
              search: (query) async {
                FocusScope.of(context).requestFocus(FocusNode());
                if (textEditingController.text != '') {
                  setState(() {
                    searchQueryListener.value = textEditingController.text;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            // TODO <08-10-22, kalli> Hide tabs if we have no results
            TabBar(
              controller: tabController,
              unselectedLabelStyle: tsBody1,
              unselectedLabelColor: grey5,
              indicatorColor: indicatorRed,
              isScrollable: true,
              labelStyle: tsSubtitle2,
              labelColor: pink4,
              tabs: <Widget>[
                Tab(
                  text: 'videos'.i18n,
                ),
                Tab(
                  text: 'images'.i18n,
                ),
                Tab(
                  text: 'audio'.i18n,
                ),
                Tab(
                  text: 'document'.i18n,
                ),
                Tab(
                  text: 'app'.i18n,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // TODO <17-12-2021> soltzen: ValueListenableBuilder may not be
            // necessary: try without it (just with setState and see)
            ValueListenableBuilder<String>(
              valueListenable: searchQueryListener,
              builder: (BuildContext context, String value, Widget? child) {
                return Expanded(
                  // TODO <08-08-22, kalli> Everything below is full screen, we want the bottom tabs to show.
                  child: TabBarView(
                    key: const Key('replica_tab_view'),
                    controller: tabController,
                    children: [
                      // TODO <08-10-22, kalli> Hide tabs if we have no results
                      // TODO <08-16-22, kalli> Since we use a single layout, we don't need to have media-specific ListView widgets
                      ReplicaVideoListView(
                        replicaApi: replicaApi,
                        searchQuery: value,
                      ),
                      ReplicaImageListView(
                        replicaApi: replicaApi,
                        searchQuery: value,
                      ),
                      ReplicaAudioListView(
                        replicaApi: replicaApi,
                        searchQuery: value,
                      ),
                      ReplicaDocumentListView(
                        replicaApi: replicaApi,
                        searchQuery: value,
                      ),
                      ReplicaAppListView(
                        replicaApi: replicaApi,
                        searchQuery: value,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
