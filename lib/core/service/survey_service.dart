import 'package:path_provider/path_provider.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

import '../utils/common.dart';

enum SurveyScreens { homeScreen }

//This class use spot check service for survey
class SurveyService {
  final SpotCheck _spotCheck = SpotCheck(
    domainName: "lantern.surveysparrow.com",
    targetToken: "tar-avDLqWvShqjDf3fydPDpbQ",
    userDetails: {},
  );

  SurveyService() {
    _createConfigIfNeeded();
  }

  void trackScreen(SurveyScreens screen) {
    _spotCheck.trackScreen(screen.name);
  }

  Widget surveyWidget() {
    return _spotCheck;
  }

  Future<String> get _surveyConfigPath async {
    final cacheDir = await getApplicationCacheDirectory();
    final filePath = '${cacheDir.path}/survey_config.json';
    return filePath;
  }

  Future<void> _createConfigIfNeeded() async {
    final filePath = await _surveyConfigPath;
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);

      const surveyConfig = {
        "isShowSurvey": false,
        "lastSurveyDate": "",
        "vpnConnectCount": 0
      };
      final jsonString = jsonEncode(surveyConfig);
      await file.writeAsString(jsonString);
    }
  }

  Future<void> incrementVpnConnectCount() async {
    try {
      final filePath = await _surveyConfigPath;
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final surveyConfig = jsonDecode(content) as Map<String, dynamic>;
        // Increment the vpnConnectCount field
        surveyConfig['vpnConnectCount'] =
            (surveyConfig['vpnConnectCount'] ?? 0) + 1;
        final updatedJsonString = jsonEncode(surveyConfig);
        await file.writeAsString(updatedJsonString);
        appLogger.d('vpnConnectCount updated successfully.');
      } else {
        appLogger.d('File does not exist. No changes were made.');
      }
    } catch (e) {
      appLogger.d('Failed to update vpnConnectCount: $e');
    }
  }

  Future<bool> surveyAvailable() async {
    try {
      final filePath = await _surveyConfigPath;
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> surveyConfig = jsonDecode(content);
        final vpnConnectCount = surveyConfig['vpnConnectCount'] ?? 0;
        return vpnConnectCount >= 10;
      } else {
        appLogger.d('Survey config file does not exist.');
        return false;
      }
    } catch (e) {
      appLogger.e('Failed to check survey availability: $e');
      return false;
    }
  }
}
