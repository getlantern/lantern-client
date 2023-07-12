import 'dart:io';

class AdHelper {
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return '***REMOVED***';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
