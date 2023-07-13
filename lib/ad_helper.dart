import 'dart:io';

class AdHelper {
  static List<String> notAdsSupportCountry=['CN'];

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return '***REMOVED***';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
