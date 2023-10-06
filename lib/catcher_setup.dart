import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

final debugOption = Catcher2Options(
  SilentReportMode(),
  [
    ConsoleHandler(
      enableApplicationParameters: true,
      enableDeviceParameters: true,
      enableCustomParameters: true,
      enableStackTrace: true,
    ),
  ],
);

final releaseOption = Catcher2Options(
  SilentReportMode(),
  [
    ConsoleHandler(
      enableApplicationParameters: true,
      enableDeviceParameters: true,
      enableCustomParameters: true,
      enableStackTrace: true,
    ),
    SentryHandler(
      SentryClient(
        SentryOptions(
          dsn:
              'https://4753d78f885f4b79a497435907ce4210@o75725.ingest.sentry.io/5850353',
        ),
      ),
      printLogs: true,
    ),
  ],
);

Catcher2 setupCatcherAndRun(StatelessWidget root) {
  return Catcher2(
    rootWidget: root,
    debugConfig: debugOption,
    releaseConfig: releaseOption,
  );
}
