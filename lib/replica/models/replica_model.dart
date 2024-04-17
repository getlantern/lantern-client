import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
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

  Future<void> setSearchTab<T>(int searchTab) async {
    return methodChannel.invokeMethod('setSearchTab', <String, dynamic>{
      'searchTab': searchTab.toString(),
    });
  }

  Future<void> setShowNewBadge(bool showNewBadge) async {
    return methodChannel.invokeMethod('setShowNewBadge', {
      'showNewBadge': showNewBadge,
    });
  }

  Widget getShowNewBadgeWidget(ValueWidgetBuilder<bool> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>(
        '/showNewBadge',
        defaultValue: true,
        builder: builder,
      );
    }
    return ffiValueBuilder<bool>(
      '/showNewBadge',
      ffiReplicaBadge,
      defaultValue: false,
      builder: builder,
    );
  }

  Widget getSearchTermWidget(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        '/searchTerm',
        defaultValue: '',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      '/searchTerm',
      ffiSearchTerm,
      defaultValue: '',
      builder: builder,
    );
  }

  Widget getSearchTabWidget(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        '/searchTab',
        defaultValue: '',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      '/searchTab',
      ffiSearchTab,
      defaultValue: '',
      builder: builder,
    );
  }

  Future<bool> getShowNewBadge() async {
    return methodChannel
        .invokeMethod('get', '/showNewBadge')
        .then((value) => value??false);
  }

  Future<String> getSearchTerm() async {
    return methodChannel
        .invokeMethod('get', '/searchTerm')
        .then((value) => value.toString());
  }

  Future<String> getSearchTab() async {
    return methodChannel
        .invokeMethod('get', '/searchTab')
        .then((value) => value.toString());
  }
}
