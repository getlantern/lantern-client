import 'package:lantern/common/common.dart';

const RouteTransitionsBuilder defaultTransition = TransitionsBuilders.fadeIn;

const defaultTransitionMillis = 200;

const defaultTransitionDuration =
    Duration(milliseconds: defaultTransitionMillis);

ScrollPhysics get defaultScrollPhysics => const BouncingScrollPhysics();
