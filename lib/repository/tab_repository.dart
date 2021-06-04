import 'package:lantern/package_store.dart';
import 'package:pedantic/pedantic.dart';

abstract class TabInterface {
  void tabListener();
}

class TabRepository with TabInterface {
  TabRepository({required this.pageController}) {
    _methodChannel = const MethodChannel('messaging_method_channel');
  }
  final PageController pageController;

  late final MethodChannel _methodChannel;

  @override
  void tabListener() {
    if (pageController.page == 0.0) return;
    unawaited(_methodChannel.invokeMethod('cleanCurrentConversationContact'));
  }
}
