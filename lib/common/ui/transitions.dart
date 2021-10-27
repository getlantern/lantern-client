import 'package:lantern/common/common.dart';

const RouteTransitionsBuilder defaultTransition = TransitionsBuilders.fadeIn;

const defaultTransitionMillis = 200;

const defaultAnimationMillis = 1000;

const defaultTransitionDuration =
    Duration(milliseconds: defaultTransitionMillis);

const defaultAnimationDuration = Duration(milliseconds: defaultAnimationMillis);

ScrollPhysics get defaultScrollPhysics => const BouncingScrollPhysics();

final spinner = Center(
  child: CircularProgressIndicator(
    color: white,
  ),
);
