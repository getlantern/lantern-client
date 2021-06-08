import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

// TabStatus provides information about the active status of a tab.
class TabStatus {
  late final int _index;
  late final PageController _pageController;

  TabStatus(this._index, this._pageController);

  // active indicates whether or not this tab is the currently active one
  bool get active => _pageController.page == _index;
}

// TabStatusProvider provides the current TabStatus to child widgets
class TabStatusProvider extends Provider<TabStatus> {
  TabStatusProvider(
      {required PageController pageController,
      required int index,
      required Widget child})
      : super(
          create: (_) => TabStatus(index, pageController),
          child: child,
        );
}
