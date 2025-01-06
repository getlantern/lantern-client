import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

enum SurveyScreens { homeScreen }

//This class use spot check service for survey
class SurveyService {
  final SpotCheck spotCheck = SpotCheck(
    domainName: "<your_domain>",
    targetToken: "<target_token>",
    userDetails: {},
  );

  void trackScreen(SurveyScreens screen) {
    spotCheck.trackScreen(screen.name);
  }
}
