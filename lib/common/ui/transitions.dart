import 'package:lantern/common/common.dart';

const RouteTransitionsBuilder defaultTransition = TransitionsBuilders.fadeIn;

const defaultTransitionMillis = 200;

const defaultAnimationMillis = 1000;

const longAnimationMillis = 3000;

const defaultTransitionDuration =
    Duration(milliseconds: defaultTransitionMillis);

const defaultAnimationDuration = Duration(milliseconds: defaultAnimationMillis);

const longAnimationDuration = Duration(milliseconds: longAnimationMillis);

const twoWeeksInMillis =
    14 * 24 * 60 * 60 * 1000; // in 14d * 24h * 60m * 60s * 1000 from now

ScrollPhysics get defaultScrollPhysics => const BouncingScrollPhysics();

final spinner = Center(
  child: CircularProgressIndicator(
    color: white,
  ),
);

const defaultCurves = Curves.easeInOutCubic;
