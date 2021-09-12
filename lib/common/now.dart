import 'dart:async';

import 'package:lantern/package_store.dart';

/// callback that receives the current time
abstract class _NowCallback {
  void onTime(DateTime now);
}

/**
 * A state that gets updated every second about the current time (now). This
 * gives us a convenient mechanism to animate anything that depends on the
 * current time, only firing at most every second and only rebuilding the widget
 * tree if the calculated value has changed.
 */
abstract class NowState<S, W extends StatefulWidget> extends State<W>
    with _NowCallback {
  static final _callbacks = <_NowCallback>{};

  static final _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    final now = DateTime.now();
    _callbacks.forEach((callback) => callback.onTime(now));
  });

  S value;

  NowState(this.value);

  @override
  void initState() {
    super.initState();
    // The below seems to be needed to keep the compiler from optimizing out the
    // static timer. If you remove the below reference to _timer.isActive, the
    // timer will not run.
    _timer.isActive;
    _callbacks.add(this);
  }

  @override
  void dispose() {
    _callbacks.remove(this);
    super.dispose();
  }

  @override
  void onTime(DateTime now) {
    final newValue = calculateValue(now);
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

  S calculateValue(DateTime now);
}
