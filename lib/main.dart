import 'package:flutter_driver/driver_extension.dart';
import 'package:lantern/common/common.dart';
import 'app.dart';

Future<void> main() async {
  // CI will be true only when running appium test
  var CI = const String.fromEnvironment('CI', defaultValue: 'false');
  print('CI is running $CI');
  if (CI == 'true') {
    enableFlutterDriverExtension();
  }
 
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final config = DdSdkExistingConfiguration(
    loggingConfiguration: LoggingConfiguration(),
    detectLongTasks: true,
  )..enableHttpTracking();

  await DatadogSdk.instance.attachToExisting(config);
  runApp(LanternApp());
  /*var applicationId = const String.fromEnvironment('DD_APPLICATION_ID');

  DatadogSdk.instance.sdkVerbosity = Verbosity.verbose;
  final configuration = DdSdkConfiguration(
    clientToken: const String.fromEnvironment('DD_CLIENT_TOKEN'),
    env: 'prod',
    site: DatadogSite.eu1,
    trackingConsent: TrackingConsent.granted,
    nativeCrashReportEnabled: true,
    loggingConfiguration: LoggingConfiguration(),
    rumConfiguration: applicationId != null ? RumConfiguration(applicationId: applicationId) : null,
  );
  await DatadogSdk.runApp(configuration, () async {
    runApp(LanternApp());
  });*/
}
