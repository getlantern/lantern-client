import 'package:path_provider/path_provider.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

import '../utils/common.dart';

enum SurveyScreens { homeScreen }

//This class use spot check service for survey
class SurveyService {
  // Need to have spot check for each region
  // Russia, Belarus, Ukraine, China, Iran, UAE, Myanmar

  final int _VPNCONNECTED_COUNT = 10;

  final SpotCheck _testingSpotCheck = SpotCheck(
    domainName: "lantern.surveysparrow.com",
    targetToken: AppSecret.testingSpotCheckTargetToken,
    userDetails: {},
    sparrowLang: Localization.locale.split('_').first,
  );

  final SpotCheck _russiaSpotCheck = SpotCheck(
      domainName: "lantern.surveysparrow.com",
      targetToken: AppSecret.russiaSpotCheckTargetToken,
      // Should Not Pass userDetails as const
      userDetails: {});

  final SpotCheck _iranSpotCheck = SpotCheck(
      domainName: "lantern.surveysparrow.com",
      targetToken: AppSecret.iranSpotCheckTargetToken,
      // Should Not Pass userDetails as const
      userDetails: {});

  final SpotCheck _ukraineSpotCheck = SpotCheck(
      domainName: "lantern.surveysparrow.com",
      targetToken: AppSecret.ukraineSpotCheckTargetToken,
      // Should Not Pass userDetails as const
      userDetails: {});
  final SpotCheck _belarusSpotCheck = SpotCheck(
      domainName: "lantern.surveysparrow.com",
      targetToken: AppSecret.belarusSpotCheckTargetToken,
      // Should Not Pass userDetails as const
      userDetails: {});

  final SpotCheck _chinaSpotCheck = SpotCheck(
      domainName: "lantern.surveysparrow.com",
      targetToken: AppSecret.chinaSpotCheckTargetToken,
      // Should Not Pass userDetails as const
      userDetails: {});

  final SpotCheck _UAEspotCheck = SpotCheck(
      domainName: "lantern.surveysparrow.com",
      targetToken: AppSecret.UAEspotCheckTargetToken,
      // Should Not Pass userDetails as const
      userDetails: {});

  final SpotCheck _myanmarSpotCheck = SpotCheck(
      domainName: "lantern.surveysparrow.com",
      targetToken: AppSecret.myanmarSpotCheckTargetToken,
      // Should Not Pass userDetails as const
      userDetails: {});

  SurveyService() {
    _createConfigIfNeeded();
  }

  void trackScreen(SurveyScreens screen) {
    switch (sessionModel.country.value?.toLowerCase()) {
      case 'ru':
        //Russia
        _russiaSpotCheck.trackScreen(screen.name);
        break;
      case 'ir':
        //Iran
         _iranSpotCheck.trackScreen(screen.name);
        break;
      case 'by':
        //Belarus
        _belarusSpotCheck.trackScreen(screen.name);
        break;
      case 'ua':
        //Ukraine
        _ukraineSpotCheck.trackScreen(screen.name);
        break;
      case 'cn':
        //China
        _chinaSpotCheck.trackScreen(screen.name);
        break;
      case 'mm':
        //Myanmar
        _myanmarSpotCheck.trackScreen(screen.name);
        break;
      case 'uae':
        //UAE
        _UAEspotCheck.trackScreen(screen.name);
        break;
      // This is just for testing
      case 'in':
        _testingSpotCheck.trackScreen(screen.name);
        break;
    }
  }

  Widget surveyWidget() {
    switch (sessionModel.country.value?.toLowerCase()) {
      case 'ru':
        //Russia
        return _russiaSpotCheck;
      case 'ir':
        //Iran
        return _iranSpotCheck;
      case 'by':
        //Belarus
        return _belarusSpotCheck;
      case 'ua':
        //Ukraine
        return _ukraineSpotCheck;
      case 'cn':
        //China
        return _chinaSpotCheck;
      case 'mm':
        //Myanmar
        return _myanmarSpotCheck;
      case 'uae':
        //UAE
        return _UAEspotCheck;
      // This is just for testing
      case 'in':
        //UAE
        return _testingSpotCheck;
      default:
        return const SizedBox.shrink();
    }
  }

  Future<String> get _surveyConfigPath async {
    final cacheDir = await getApplicationCacheDirectory();
    final filePath = '${cacheDir.path}/survey_config.json';
    return filePath;
  }

  Future<void> _createConfigIfNeeded() async {
    final filePath = await _surveyConfigPath;
    final file = File(filePath);
    try {
      if (!await file.exists()) {
        await file.create(recursive: true);

        const surveyConfig = {"vpnConnectCount": 0};
        final jsonString = jsonEncode(surveyConfig);
        await file.writeAsString(jsonString);
        appLogger.d("Write init config done $filePath");
      }
    } catch (e) {
      appLogger.e("Error while creating config");
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
        appLogger.d('Survey config. ${surveyConfig.toString()}');
        if (vpnConnectCount >= _VPNCONNECTED_COUNT) {
          appLogger.d('Survey is available.');
          return true;
        }
        appLogger.d('Survey is not available.');
        return false;
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
