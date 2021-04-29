import '../package_store.dart';
import 'model.dart';

class SessionModel extends Model {
  SessionModel() : super('session');

  Widget proUser(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('prouser', builder: builder);
  }

  Widget yinbiEnabled(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('yinbienabled', builder: builder);
  }

  Widget shouldShowYinbiBadge(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('should_show_yinbi_badge', builder: builder);
  }

  Widget proxyAll(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('proxyAll', builder: builder);
  }

  Widget language(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('lang', builder: builder);
  }

  Future<void> switchProxyAll<T>(bool on) async {
    methodChannel.invokeMethod('switchProxyAll', <String, dynamic>{
      'on': on,
    });
  }
}
