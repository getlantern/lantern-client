import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

final replicaModel = ReplicaModel();

class ReplicaModel extends Model {
  ReplicaModel() : super('replica');

  Future<void> downloadFile(
    String url,
    String displayName,
  ) async {
    return methodChannel.invokeMethod('downloadFile', {
      'url': url,
      'displayName': displayName,
    });
  }

  Widget withReplicaApi(ValueWidgetBuilder<ReplicaApi> builder) {
    return sessionModel.replicaAddr((context, replicaAddr, child) {
      return builder(context, ReplicaApi(replicaAddr), child);
    });
  }

  Future<bool?> getSuppressUploadWarning() async {
    return methodChannel.invokeMethod('get', 'suppressUploadWarning');
  }

  Future<void> setSuppressUploadWarning(bool suppress) async {
    return methodChannel.invokeMethod('setSuppressUploadWarning', {
      'suppress': suppress,
    });
  }

  Future<void> setSearchTerm<T>(String searchTerm) async {
    return methodChannel.invokeMethod('setSearchTerm', <String, dynamic>{
      'searchTerm': searchTerm,
    });
  }

  Widget getSearchTermWidget(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      '/searchTerm',
      defaultValue: '',
      builder: builder,
    );
  }

  Future<String?> getSearchTerm() async {
    return methodChannel.invokeMethod('get', '/searchTerm');
  }
}
