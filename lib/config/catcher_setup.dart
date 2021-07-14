import 'dart:io';

import 'package:catcher/catcher.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sentry/sentry.dart';

// ignore: avoid_redundant_argument_values
ReportMode reportMode = SilentReportMode();

final CatcherOptions catcherOptions = CatcherOptions(
  reportMode,
  [
    ConsoleHandler(
      enableApplicationParameters: true,
      enableDeviceParameters: true,
      enableCustomParameters: true,
      enableStackTrace: true,
    ),
    // Requires the SentryClient import, put this in pubspec sentry: ^5.1.0
    SentryHandler(
      SentryClient(SentryOptions(
          dsn:
              'https://4753d78f885f4b79a497435907ce4210@o75725.ingest.sentry.io/5850353')),
      printLogs: true,
    ),
  ],
);

// String catcherScreenShots = catcherScreenshotDirectory() as String;

// Future<String> catcherScreenshotDirectory() async {
//   var externalDir = await getExternalStorageDirectory() as Directory;
//   return externalDir.path.toString();
// }
