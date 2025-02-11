import 'package:path_provider/path_provider.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

import '../utils/common.dart';

enum SurveyScreens { homeScreen }

enum SurveyCountry {
  russia('ru'),
  belarus('by'),
  ukraine('ua'),
  china('cn'),
  iran('ir'),
  uae('ae'),
  myanmar('mm'),
  testing('testing');

  const SurveyCountry(this.countryCode);

  final String countryCode;
}

//This class use spot check service for survey
class SurveyService {
  // Need to have spot check for each region
  // Russia, Belarus, Ukraine, China, Iran, UAE, Myanmar

  SpotCheck? spotCheck;
  final int _VPNCONNECTED_COUNT = 10;

  SurveyService() {
    if (Platform.isWindows || Platform.isLinux) {
      return;
    }
    _createConfigIfNeeded();
    _countryListener();
  }

  void _countryListener() {
    if (isDesktop()) {
      if (sessionModel.configNotifier.value != null) {
        createSpotCheckByCountry(sessionModel.configNotifier.value!.country.toLowerCase());
        return;
      }
    }
    if (sessionModel.country.value!.isNotEmpty) {
      createSpotCheckByCountry(sessionModel.country.value!.toLowerCase());
      return;
    }
    sessionModel.country.addListener(() {
      final country = sessionModel.country.value;
      if (country != null && country.isNotEmpty) {
        appLogger.d('Country found  $country');
        createSpotCheckByCountry(country.toLowerCase());
        sessionModel.country
            .removeListener(() {}); // Remove listener after getting value
      }
    });
  }

  //Create method to create spot check by country
  //argument by string and use enum for country
  //make sure when create country should not be null or empty
  SpotCheck createSpotCheckByCountry(String country) {
    appLogger.d('Create spot check for country $country');
    if (spotCheck != null) {
      return spotCheck!;
    }
    final surveyCountry = SurveyCountry.values.firstWhere(
      (e) => e.countryCode == country,
      orElse: () => SurveyCountry.testing,
    );
    String targetToken;
    switch (surveyCountry) {
      case SurveyCountry.russia:
        targetToken = AppSecret.russiaSpotCheckTargetToken;
        break;
      case SurveyCountry.belarus:
        targetToken = AppSecret.belarusSpotCheckTargetToken;
        break;
      case SurveyCountry.ukraine:
        targetToken = AppSecret.ukraineSpotCheckTargetToken;
        break;
      case SurveyCountry.china:
        targetToken = AppSecret.chinaSpotCheckTargetToken;
        break;
      case SurveyCountry.iran:
        targetToken = AppSecret.iranSpotCheckTargetToken;
        break;
      case SurveyCountry.uae:
        targetToken = AppSecret.UAEspotCheckTargetToken;
        break;
      case SurveyCountry.myanmar:
        targetToken = AppSecret.myanmarSpotCheckTargetToken;
        break;
      default:
        targetToken = AppSecret.testingSpotCheckTargetToken;
        appLogger.d('${country.toUpperCase()} not found, using testing token');
        break;
    }
    spotCheck = SpotCheck(
        domainName: "lantern.surveysparrow.com",
        targetToken: targetToken,
        userDetails: {});
    return spotCheck!;
  }

  void trackScreen(SurveyScreens screen) {
    appLogger.d('Track screen $screen');
    spotCheck?.trackScreen(screen.name);
  }

  Widget surveyWidget() {
    if (Platform.isWindows || Platform.isLinux) {
      return const SizedBox();
    }
    return spotCheck!;
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
      final content = await readSurveyConfig();
      final surveyConfig = jsonDecode(content.$2) as Map<String, dynamic>;
      // Increment the vpnConnectCount field
      surveyConfig['vpnConnectCount'] =
          (surveyConfig['vpnConnectCount'] ?? 0) + 1;
      final updatedJsonString = jsonEncode(surveyConfig);
      await content.$1.writeAsString(updatedJsonString);
      appLogger.i('vpnConnectCount updated successfully.');
    } catch (e) {
      appLogger.i('Failed to update vpnConnectCount: $e');
    }
  }

  Future<bool> surveyAvailable() async {
    try {
      final content = await readSurveyConfig();
      final Map<String, dynamic> surveyConfig = jsonDecode(content.$2);
      final vpnConnectCount = surveyConfig['vpnConnectCount'] ?? 0;
      appLogger.i('Survey config. ${surveyConfig.toString()}');
      if (vpnConnectCount >= _VPNCONNECTED_COUNT) {
        appLogger.d('Survey is available.');
        return true;
      }
      appLogger.i('Survey is not available.');
      return false;
    } catch (e) {
      appLogger.e('Failed to check survey availability: $e');
      return false;
    }
  }

  //this read survey config method will return file and string
  Future<(File, String)> readSurveyConfig() async {
    final filePath = await _surveyConfigPath;
    final file = File(filePath);
    final content = await file.readAsString();
    return (file, content);
  }
}
