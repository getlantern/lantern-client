import 'package:lantern/app.dart';
import 'package:lantern/core/service/lantern_ffi_service.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:window_manager/window_manager.dart';

class WindowContainer extends StatefulWidget {
  const WindowContainer(this.child, {super.key});

  final Widget child;

  @override
  State<WindowContainer> createState() => _WindowContainerState();
}

class _WindowContainerState extends State<WindowContainer> with WindowListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    if (isDesktop()) {
      windowManager.addListener(this);
      _initializeWindow();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await windowManager.setPreventClose(true);
        await _setWindowResizable();
      });
    }
  }

  Future<void> _initializeWindow() async {
    await windowManager.ensureInitialized();
    await windowManager.setSize(const Size(360, 712));
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void dispose() {
    if (isDesktop()) windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _setWindowResizable() async {
    if (!Platform.isWindows) {
      await windowManager.setResizable(false);
      return;
    }
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (!isPreventClose) return;
    await showDialog(
      context: globalRouter.navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: Text('confirm_close_window'.i18n),
        actions: [
          TextButton(
            child: Text('No'.i18n),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes'.i18n),
            onPressed: () async {
              await windowManager.hide();
              if (Platform.isMacOS) {
                await windowManager.setSkipTaskbar(true);
              }
              LanternFFI.exit();
              exit(0);
            },
          ),
        ],
      ),
    );
  }
}
