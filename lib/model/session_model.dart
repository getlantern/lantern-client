import 'package:pedantic/pedantic.dart';

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
    return subscribedSingleValueBuilder<bool>('should_show_yinbi_badge',
        builder: builder);
  }

  Widget proxyAll(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('proxyAll', builder: builder);
  }

  Widget language(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('lang', builder: builder);
  }

  Future<void> switchProxyAll<T>(bool on) async {
    unawaited(methodChannel.invokeMethod('switchProxyAll', <String, dynamic>{
      'on': on,
    }));
  }

  Future<void> setLanguage(String lang) {
    return methodChannel.invokeMethod('setLanguage', <String, dynamic>{
      'lang': lang,
    });
  }

  Future<String> authorizeViaEmail(String emailAddress) {
    return methodChannel.invokeMethod('authorizeViaEmail', <String, dynamic>{
      'emailAddress': emailAddress,
    }).then((value) => value as String);
  }

  Future<String> validateRecoveryCode(String code) {
    return methodChannel.invokeMethod('validateRecoveryCode', <String, dynamic>{
      'code': code,
    }).then((value) => value as String);
  }

  Future<void> resendRecoveryCode() {
    return methodChannel
        .invokeMethod('resendRecoveryCode', <String, dynamic>{});
  }
}
