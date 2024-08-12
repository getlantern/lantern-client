import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
          dsn: dnsConfig(),
        ),
      ),
      printLogs: true,
      enableApplicationParameters: true,
    ),
  ],
);

Catcher2 setupCatcherAndRun(Widget root) {
  return Catcher2(
    rootWidget: root,
    debugConfig: debugOption,
    releaseConfig: releaseOption,
  );
}

String dnsConfig() {
  if (Platform.isAndroid) {
    return "https://4753d78f885f4b79a497435907ce4210@o75725.ingest.sentry.io/5850353";
  }
  if (Platform.isIOS) {
    return "https://c14296fdf5a6be272e1ecbdb7cb23f76@o75725.ingest.sentry.io/4506081382694912";
  }
  return "https://7397d9db6836eb599f41f2c496dee648@o75725.ingest.us.sentry.io/4507734480912384";
}
