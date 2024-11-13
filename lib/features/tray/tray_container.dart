import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayContainer extends StatefulWidget {
  const TrayContainer(this.child, {super.key});

  final Widget child;

  @override
  State<TrayContainer> createState() => _TrayContainerState();
}

class _TrayContainerState extends State<TrayContainer> with TrayListener {
  @override
  void initState() {
    super.initState();
    _initializeTray();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onTrayIconMouseDown() async {
    windowManager.show();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  /// system tray methods
  Future<void> _initializeTray() async {
    trayManager.addListener(this);
    final vpnNotifier = context.read<VPNChangeNotifier>();
    await _updateTrayMenu();
    vpnNotifier.vpnStatus.addListener(_updateTrayMenu);
  }

  Future<void> _updateTrayMenu() async {
    final vpnNotifier = context.read<VPNChangeNotifier>();
    final isConnected = vpnNotifier.isConnected();
    trayManager.setIcon(getSystemTrayIconPath(context, isConnected));
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'status',
          disabled: true,
          label: isConnected ? 'status_on'.i18n : 'status_off'.i18n,
        ),
        MenuItem(
          key: 'status',
          label: isConnected ? 'disconnect'.i18n : 'connect'.i18n,
          onClick: (item) => vpnNotifier.toggleConnection(),
        ),
        MenuItem.separator(),
        MenuItem(
            key: 'show_window',
            label: 'show'.i18n,
            onClick: (item) {
              windowManager.focus();
              windowManager.setSkipTaskbar(false);
            }),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: 'exit'.i18n,
          onClick: (item) async {
            LanternFFI.exit();
            await trayManager.destroy();
            await windowManager.destroy();
            exit(0);
          },
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
