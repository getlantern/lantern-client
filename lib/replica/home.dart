import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/search.dart';

/// ReplicaHomeScreen is the entrypoint for the user to search through Replica.
/// See docs/replica_home.png for a preview
class ReplicaHomeScreen extends StatefulWidget {
  const ReplicaHomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ReplicaHomeScreenState();
}

class _ReplicaHomeScreenState extends State<ReplicaHomeScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'replicaSearchInput');
  CustomTextEditingController? _textEditingController;

  late bool showResults = false;
  late String currentQuery = '';
  late int currentTab = 0;
  late bool showNewModal = false;

  void setSearchTab(int tab) async {
    setState(() {
      currentTab = tab;
    });
  }

  @override
  void initState() {
    super.initState();
    replicaModel.getSearchTerm().then((String cachedSearchTerm) {
      if (cachedSearchTerm.isNotEmpty) {
        _textEditingController?.initialValue = cachedSearchTerm;
        setState(() {
          currentQuery = cachedSearchTerm;
          showResults = true;
        });
      }
    });
    replicaModel.getShowNewBadge().then((bool showNewBadge) {
      if (showNewBadge) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          renderNewDialog(context, setSearchTab);
        });
      }
    });
    doGetCachedTab();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void doGetCachedTab() async {
    final cachedTab = await replicaModel.getSearchTab();
    setSearchTab(int.parse(cachedTab));
  }

  @override
  Widget build(BuildContext context) {
    if (showResults) {
      return ReplicaSearchScreen(
        currentQuery: currentQuery,
        currentTab: currentTab,
        onBackButtonPressed: onBackButtonPressed,
      );
    }
    // we need to initialize controller again coz we when switch widget controller is getting disposed
    _textEditingController = CustomTextEditingController(formKey: _formKey);
    return _buildSearchView();
  }

  void Function() renderNewDialog(BuildContext context, setSearchTab) {
    return CDialog(
      iconPath: ImagePaths.newspaper,
      title: 'replica_new_discover'.i18n,
      description: 'replica_new_discover_news'.i18n,
      agreeText: 'replica_check_it_out'.i18n,
      agreeAction: () async {
        await replicaModel.setShowNewBadge(false);
        await setSearchTab(5); // News is index 5
        return true;
      },
      includeCancel: false,
    ).show(context);
  }

  Widget _buildSearchView() {
    // No active query, return the landing search bar instead
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when clicking anywhere
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: BaseScreen(
        actionButton: renderFap(context),
        centerTitle: true,
        title: 'discover'.i18n,
        automaticallyImplyLeading: false,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 46, top: 30),
                    child: CAssetImage(
                      path: ImagePaths.lantern_logo,
                      size: 72,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 10.0, end: 10.0),
                    child: SearchField(
                      controller: _textEditingController!,
                      search: (query) async {
                        await replicaModel.setSearchTerm(query);
                        if (query != '') {
                          setState(() {
                            currentQuery = query;
                            showResults = true;
                          });
                        }
                      },
                      onClear: () async {
                        await replicaModel.setSearchTerm('');
                        await replicaModel.setSearchTab(0);
                      },
                    ),
                  ),
                  renderDiscoverText(),
                ],
              ),
            ),
            // if (!showNewModal) renderNewDialog(context)
          ],
        ),
      ),
    );
  }

  Widget renderDiscoverText() {
    return Padding(
      padding: const EdgeInsetsDirectional.all(12.0),
      child: Column(
        children: [
          CText('replica_search_intro'.i18n, style: tsBody1),
          const SizedBox(
            height: 8,
          ),
          CText('discover_disclaimer'.i18n, style: tsBody1),
        ],
      ),
    );
  }

  FloatingActionButton renderFap(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: black,
      child: const CAssetImage(
        path: ImagePaths.file_upload,
      ),
      onPressed: () async {
        await onUploadButtonPressed(context);
      },
    );
  }

//class methods
  Future<void> onBackButtonPressed() async {
    setState(() {
      showResults = false;
    });
    await replicaModel.setSearchTerm('');
    await replicaModel.setSearchTab(0);
  }
}
