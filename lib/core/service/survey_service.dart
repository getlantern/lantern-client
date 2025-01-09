import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

import '../utils/common.dart';

enum SurveyScreens {
  homeScreen,
  plansScreen
}

//This class use spot check service for survey
class SurveyService {
  final SpotCheck _spotCheck = SpotCheck(
      domainName: "lantern.surveysparrow.com",
      targetToken: "tar-87GWRfobkr3uxkKVog9C6V",
      userDetails: {});

  void trackScreen(SurveyScreens screen) {
    _spotCheck.trackScreen(screen.name);
  }

  Widget surveyWidget() {
    return _spotCheck;
  }
}
