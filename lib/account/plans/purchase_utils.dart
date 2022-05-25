import 'package:lantern/common/common.dart';

List<Map<String, dynamic>> formatCachedPlans(String cachedPlans) {
  // transform the String cached in db to a workable format
  // ignore: omit_local_variable_types
  List<Map<String, dynamic>> plans = [];

  if (cachedPlans.isEmpty) return [];
  try {
    final plansMap = jsonDecode(cachedPlans) as Map;
    plansMap.forEach((key, value) => plans.add(value));
  } on FormatException catch (e) {
    print(e);
    return [];
  }
  return plans;
}

void onAPIcallTimeout({code, message}) {
  throw PlatformException(
    code: code,
    message: message,
  );
}

String localizeCachingError(error) =>
    (error as PlatformException).message.toString();

// TODO: we build a pollForUpdates logic instead of having a constant duration
const defaultTimeoutDuration = Duration(seconds: 10);
