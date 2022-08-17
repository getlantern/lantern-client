import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

/// ReplicaAppListView renders a list of ReplicaAudioListItem
/// Looks like this docs/replica_audio_listview.png
class ReplicaAudioListView extends ReplicaCommonListView {
  ReplicaAudioListView({
    Key? key,
    required ReplicaApi replicaApi,
    required String searchQuery,
  }) : super(
          key: key,
          replicaApi: replicaApi,
          searchQuery: searchQuery,
          searchCategory: SearchCategory.Audio,
        );

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
          context.pushRoute(
            ReplicaAudioViewer(
              replicaApi: widget.replicaApi,
              item: item,
              category: SearchCategory.Audio,
            ),
          );
        },
        replicaApi: widget.replicaApi,
      );
    });
  }
}
