import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';

final replicaModel = ReplicaModel();

class ReplicaModel extends Model {
  ReplicaModel() : super('replica');

  Future<void> downloadFile(
    String url,
    String displayName,
  ) {
    return methodChannel
        .invokeMethod('downloadFile', {'url': url, 'displayName': displayName});
  }

  Widget withReplicaApi(ValueWidgetBuilder<ReplicaApi> builder) {
    return sessionModel.replicaAddr((context, replicaAddr, child) {
      return builder(context, ReplicaApi(replicaAddr), child);
    });
  }
}
