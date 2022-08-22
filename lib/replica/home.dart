import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

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

  // Two ways to navigate to search screen:
  // - Click the magnifier icon next to the search bar
  // - Or, just click enter in the search bar
  Future<void> _navigateToSearchScreen(String query) async {
    await context.pushRoute(ReplicaSearchScreen(searchQuery: query));
  }

  @override
  Widget build(BuildContext context) {
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
                  if (query != '') {
                    await _navigateToSearchScreen(query);
                    await replicaModel.setSearchTerm(query);
                  }
                },
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
