import 'package:lantern/desktop/account_tab.dart';
import 'package:lantern/account/developer_settings.dart';
import 'package:lantern/account/privacy_disclosure.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/desktop/ffi.dart';
import 'dart:ffi' as ffi; // For FFI
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';
import 'package:lantern/replica/replica_tab.dart';
import 'package:lantern/vpn/try_lantern_chat.dart';
import 'package:lantern/vpn/vpn_tab.dart';
import 'package:logger/logger.dart';

@RoutePage(name: 'DesktopHome')
class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({Key? key}) : super(key: key);

  @override
  _DesktopHomePageState createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  BuildContext? _context;

  _DesktopHomePageState();

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: buildBody(true),
        bottomNavigationBar: CustomBottomBar(
          selectedTab: selectedTab().toDartString(),
          isDevelop: true,
          isTesting: true,
        ),
      );
  }

  @override
  Widget buildBody(bool isOnboarded) {
    var tab = selectedTab().toDartString();
    switch (tab) {
      case TAB_VPN:
        return const VPNTab();
      case TAB_ACCOUNT:
        return AccountTab();
      case TAB_DEVELOPER:
        return DeveloperSettingsTab();
      default:
        assert(false, 'unrecognized tab $selectedTab');
        return Container();
    }
  }
}
