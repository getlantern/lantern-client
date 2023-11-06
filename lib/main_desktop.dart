import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:lantern/flutter_go.dart';
import 'package:flutter/services.dart';
import 'package:lantern/app.dart';
import 'package:lantern/app_desktop.dart';


Future<String> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await await Go.sendRequest('Builtin.GetPlatformVersion');
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    print("Platform version is $platformVersion");
    return platformVersion;
}

Future<void> main() async {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  WidgetsFlutterBinding.ensureInitialized();
  //await initPlatformState();
  runApp(DesktopApp());
}