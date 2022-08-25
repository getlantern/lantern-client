import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/search.dart';

/// ReplicaHomeScreen is the entrypoint for the user to search through Replica.
/// See docs/replica_home.png for a preview
class ReplicaHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReplicaHomeScreenState();
}

class _ReplicaHomeScreenState extends State<ReplicaHomeScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'replicaSearchInput');
  late final _textEditingController =
      CustomTextEditingController(formKey: _formKey);
  late bool showResults = false;
  late String currentQuery = '';
  late int currentTab = 0;

  @override
  void initState() {
    super.initState();
    replicaModel.getSearchTerm().then((String cachedSearchTerm) {
      if (cachedSearchTerm.isNotEmpty) {
        _textEditingController.initialValue = cachedSearchTerm;
        setState(() {
          currentQuery = cachedSearchTerm;
          showResults = true;
        });
      }
    });

    replicaModel.getSearchTab().then(
          (int cachedSearchTab) => setState(() => currentTab = cachedSearchTab),
        );
  }

  @override
  Widget build(BuildContext context) {
    // We are showing the ReplicaSearchScreen here since we want the bottom tabs to be visible (they are not if it's its own route)
    // TODO <08-23-22, kalli>  Not ideal UX - maybe add a spinner? Not sure
    if (showResults) {
      return ReplicaSearchScreen(
        currentQuery: currentQuery,
        currentTab: currentTab,
      );
    }

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10.0, end: 10.0),
              child: SearchField(
                controller: _textEditingController,
                search: (query) async {
                  await replicaModel.setSearchTerm(query);
                  if (query != '') {
                    setState(() {
                      currentQuery = query;
                      showResults = true;
                    });
                  }
                },
                onClear: () async => await replicaModel.setSearchTerm(''),
              ),
            ),
            renderDiscoverPopup()
          ],
        ),
      ),
    );
  }

  Widget renderDiscoverPopup() {
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
}
