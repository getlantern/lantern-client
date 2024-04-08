import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

// ReplicaSearchScreen renders a text field with a TabBar to display the
// different categories. Each category is a child of ListView (except the
// 'image' tab, which is a child of GridView)
// Looks like this: docs/replica_search_tabs.png
class ReplicaSearchScreen extends StatefulWidget {
  const ReplicaSearchScreen({
    super.key,
    required this.currentQuery,
    required this.currentTab,
    required this.onBackButtonPressed,
    required this.textEditingController,
  });

  final String currentQuery;
  final int currentTab;
  final CustomTextEditingController textEditingController;

  final VoidCallback onBackButtonPressed;

  @override
  _ReplicaSearchScreenState createState() => _ReplicaSearchScreenState();
}

class _ReplicaSearchScreenState extends State<ReplicaSearchScreen>
    with TickerProviderStateMixin {
  late final TabController tabController =
      // Video + Image + Audio + Document + App  = 5 categories
      TabController(length: 5, vsync: this);
  late final CustomTextEditingController textEditingController = widget.textEditingController;
  late String searchQuery = widget.currentQuery;
  late int searchTab = widget.currentTab;

  @override
  void initState() {
    super.initState();
    tabController.index = searchTab;
  }

  @override
  Widget build(BuildContext context) {
    print("Replica Search");
    return BaseScreen(
      centerTitle: true,
      onBackButtonPressed: widget.onBackButtonPressed,
      title: GestureDetector(
        child: CText(
          'discover'.i18n,
          style: tsHeading3.copiedWith(color: black).short,
        ),
        onTap: () {},
      ),
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
              search: onSearch,
              onClear: () async {
                await replicaModel.setSearchTerm('');
                await replicaModel.setSearchTab(0);
              },
            ),
            const SizedBox(height: 10),
            // <08-22-22, echo> I feel like the standard list view under tabs scrolls directly under tab (no padding) no?
            TabBar(
              controller: tabController,
              onTap: (tab) async => await replicaModel.setSearchTab(tab),
              unselectedLabelStyle: tsBody1,
              unselectedLabelColor: grey5,
              indicatorColor: indicatorRed,
              isScrollable: true,
              labelStyle: tsSubtitle2,
              labelColor: pink4,
              tabs: <Widget>[
                Tab(text: 'videos'.i18n),
                Tab(text: 'images'.i18n),
                Tab(text: 'audio'.i18n),
                Tab(text: 'document'.i18n),
                Tab(text: 'app'.i18n),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                key: const Key('replica_tab_view'),
                controller: tabController,
                physics: defaultScrollPhysics,
                children: [
                  ReplicaListLayout(
                    replicaApi: replicaApi,
                    searchQuery: searchQuery,
                    searchCategory: SearchCategory.Video,
                  ),
                  ReplicaListLayout(
                    replicaApi: replicaApi,
                    searchQuery: searchQuery,
                    searchCategory: SearchCategory.Image,
                  ),
                  ReplicaListLayout(
                    replicaApi: replicaApi,
                    searchQuery: searchQuery,
                    searchCategory: SearchCategory.Audio,
                  ),
                  ReplicaListLayout(
                    replicaApi: replicaApi,
                    searchQuery: searchQuery,
                    searchCategory: SearchCategory.Document,
                  ),
                  ReplicaListLayout(
                    replicaApi: replicaApi,
                    searchQuery: searchQuery,
                    searchCategory: SearchCategory.App,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  // class methods
  Future<void> onSearch(String query) async {
    FocusScope.of(context).requestFocus(FocusNode());
    await replicaModel.setSearchTerm(query);
    await replicaModel.setSearchTab(tabController.index);
    if (textEditingController.text != '') {
      setState(() {
        searchQuery = textEditingController.text;
      });
    }
  }
}
