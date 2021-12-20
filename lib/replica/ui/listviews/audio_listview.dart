import 'package:lantern/common/common.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/listitems/audio_listitem.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaAppListView renders a list of ReplicaAudioListItem
/// Looks like this docs/replica_audio_listview.png
class ReplicaAudioListView extends ReplicaCommonListView {
  ReplicaAudioListView({Key? key, required String searchQuery})
      : super(
            key: key,
            searchQuery: searchQuery,
            searchCategory: SearchCategory.Audio);
  @override
  State<StatefulWidget> createState() => _ReplicaAudioListViewState();
}

class _ReplicaAudioListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    return renderPaginatedListView((context, item, index) {
      return ReplicaAudioListItem(
        item: item,
        onTap: () {
          context.pushRoute(ReplicaAudioPlayerScreen(
              replicaLink: item.replicaLink, mimeType: item.primaryMimeType));
        },
        replicaApi: super.replicaApi,
      );
    });
  }
}
