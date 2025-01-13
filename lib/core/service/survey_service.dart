import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

import '../utils/common.dart';

enum SurveyScreens { homeScreen, plansScreen, vpnTap }

//This class use spot check service for survey
class SurveyService {
  final SpotCheck _spotCheck = SpotCheck(
    domainName: "lantern.surveysparrow.com",
    targetToken: "tar-avDLqWvShqjDf3fydPDpbQ",
    userDetails: {},
  );

  void trackScreen(SurveyScreens screen) {
    _spotCheck.trackScreen(screen.name);
  }

  Widget surveyWidget() {
    return _spotCheck;
  }
}
