import 'package:lantern/core/utils/common.dart';

const RouteTransitionsBuilder defaultTransition = TransitionsBuilders.fadeIn;

const RouteTransitionsBuilder popupTransition = TransitionsBuilders.slideBottom;

const defaultTransitionMillis = 200;

const shortAnimationMillis = 500;

const defaultAnimationMillis = 1000;

const longAnimationMillis = 3000;

const defaultTransitionDuration =
    Duration(milliseconds: defaultTransitionMillis);

const shortAnimationDuration = Duration(milliseconds: shortAnimationMillis);

const defaultAnimationDuration = Duration(milliseconds: defaultAnimationMillis);

const longAnimationDuration = Duration(milliseconds: longAnimationMillis);

const oneWeekInMillis =
    7 * 24 * 60 * 60 * 1000; // in 7d * 24h * 60m * 60s * 1000 from now

const twoWeeksInMillis =
    14 * 24 * 60 * 60 * 1000; // in 14d * 24h * 60m * 60s * 1000 from now

ScrollPhysics get defaultScrollPhysics => const BouncingScrollPhysics();

final spinner = Center(
  child: CircularProgressIndicator(
    color: white,
  ),
);

const defaultCurves = Curves.easeInOutCubic;
