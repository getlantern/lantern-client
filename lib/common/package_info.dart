import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';

Future<PackageInfo> getPackageInfo() async => await PackageInfo.fromPlatform();
var build = '';
var version = '';

Widget getBuildNumber() {
  getPackageInfo().then((value) => build = value.buildNumber);
  return CText('Build $build', style: tsOverline.copiedWith(color: pink4));
}

Widget getVersion() {
  getPackageInfo().then((value) => version = value.version);
  return CText('Version $version', style: tsOverline.copiedWith(color: pink4));
}
