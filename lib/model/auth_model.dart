import 'dart:typed_data';

import '../package_store.dart';
import 'model.dart';

class AuthModel  extends Model {
  AuthModel() : super('auth');

  Future<void> register(int lanternUserID, String username, String password) {
    return methodChannel.invokeMethod('register', <String, dynamic>{
      'lanternUserID': lanternUserID,
      'password': password,
      'username': username,
    });
  }


  Future<void> signIn(String username, String password) {
    return methodChannel.invokeMethod('signIn', <String, dynamic>{
      'password': password,
      'username': username,
    });
  }

}
