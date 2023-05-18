import 'package:lantern/common/common.dart';

const defaultTimeoutDuration = Duration(seconds: 10);

void onAPIcallTimeout({code, message}) {
  throw PlatformException(
    code: code,
    message: message,
  );
}