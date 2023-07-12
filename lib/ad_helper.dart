import 'dart:io';

class AdHelper {
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2685698271254859/9922829329';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
