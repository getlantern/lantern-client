import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lantern/catcher_setup.dart';
import 'package:lantern/replica/logic/common.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await ReplicaCommon.init();
  setupCatcherAndRun(LanternApp());
}
