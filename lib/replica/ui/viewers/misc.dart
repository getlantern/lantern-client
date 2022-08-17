import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/viewers/layout.dart';

class ReplicaMiscViewer extends ReplicaViewerLayout {
  ReplicaMiscViewer({
    required ReplicaApi replicaApi,
    required ReplicaSearchItem item,
    required SearchCategory category,
  }) : super(replicaApi: replicaApi, item: item, category: category);

  @override
  State<StatefulWidget> createState() => _ReplicaMiscViewerState();
}

class _ReplicaMiscViewerState extends ReplicaViewerLayoutState {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool ready() => true;

  @override
  Widget body(BuildContext context) {
    return Text('Misc viewer');
  }
}
