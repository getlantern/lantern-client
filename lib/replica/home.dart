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
  late String currentQuery;

  @override
  void initState() {
    // TODO <08-22-22, kalli>  We can initialize this to prev search term if needed? This doesn't work currently
    Future.delayed(Duration.zero, () async {
      final value = await replicaModel.getSearchTerm();
      if (value != '') _textEditingController.initialValue = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // We are showing the ReplicaSearchScreen here since we want the bottom tabs to be visible (they are not if it's its own route)
    if (showResults) return ReplicaSearchScreen(searchQuery: currentQuery);

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
                  if (query != '') {
                    setState(() {
                      currentQuery = query;
                      showResults = true;
                    });
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
