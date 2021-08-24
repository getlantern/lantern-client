import 'dart:typed_data';

import '../package_store.dart';
import 'model.dart';

class AuthModel extends Model {
  AuthModel() : super('auth');

  Widget username(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('username', builder: builder);
  }

  Future<void> createAccount(String password) {
    return methodChannel.invokeMethod('createAccount', <String, dynamic>{
      'password': password,
    });
  }

  Future<String> setUsername(String username) {
    return methodChannel.invokeMethod('setUsername', <String, dynamic>{
      'username': username,
    }).then((value) => value as String);
  }

  Future<void> signIn(String username, String password) {
    return methodChannel.invokeMethod('signIn', <String, dynamic>{
      'password': password,
      'username': username,
    });
  }
}
