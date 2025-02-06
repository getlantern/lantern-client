import '../../features/replica/common.dart';
import '../utils/common.dart';

abstract class AdsProvider {
  Future<void> loadAd(VoidCallback adLoadedCallback);

  Future<void> showAd();

  Future<void> dispose();

  bool isAdReady();
}



var adsLogger = Logger(
  printer: PrettyPrinter(
    printEmojis: true,
    methodCount: 0,
    colors: true,
  ),
  level: Level.debug,
);
