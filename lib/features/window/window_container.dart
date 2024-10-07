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
    }
  }

  Future<void> _initializeWindow() async {
    await windowManager.ensureInitialized();
    await windowManager.setSize(const Size(360, 712));
    await windowManager.setPreventClose(true);
    await windowManager.setFullScreen(false);
    await windowManager.setMaximizable(false);

    windowManager.waitUntilReadyToShow().then((_) async {
      await _setWindowResizable();
      await windowManager.show();
      await windowManager.focus();
    });
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
    // temporary workaround for distorted layout on Windows. The problem goes away
    // after the window is resized.
    // See https://github.com/leanflutter/window_manager/issues/464
    // and https://github.com/KRTirtho/spotube/issues/1553
    await Future<void>.delayed(const Duration(milliseconds: 100), () async {
      windowManager.getSize().then((Size value) {
        windowManager
            .setSize(
              Size(value.width + 1, value.height + 1),
            )
            .then((_) => setState(() => {}));
      });
      await windowManager.setResizable(false);
    });
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
