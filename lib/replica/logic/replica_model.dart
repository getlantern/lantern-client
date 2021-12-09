import 'package:lantern/common/model.dart';

class ReplicaModel extends Model {
  ReplicaModel() : super('replica');

  Future<String> getReplicaAddr() {
    return methodChannel.invokeMethod(
        'getReplicaAddr', <String, dynamic>{}).then((value) => value as String);
  }

  Future<void> downloadFile(
    String url,
    String displayName,
  ) {
    return methodChannel
        .invokeMethod('downloadFile', {'url': url, 'displayName': displayName});
  }
}
