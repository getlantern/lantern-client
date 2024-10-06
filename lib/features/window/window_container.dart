import 'package:lantern/app.dart';
import 'package:lantern/core/service/lantern_ffi_service.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class WindowNotifier extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    await windowManager.ensureInitialized();
    const double width = 360;
    const double height = 712;

    await windowManager.setSize(const Size(width, height));
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> close() async {
    await windowManager.hide();
    if (Platform.isMacOS) {
      await windowManager.setSkipTaskbar(true);
    }
  }
}

class WindowContainer extends StatefulWidget {
  const WindowContainer(this.child, {super.key});

  final Widget child;

  @override
  State<WindowContainer> createState() => _WindowContainerState();
}

class _WindowContainerState extends State<WindowContainer> with WindowListener {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<WindowNotifier>(context, listen: false).initialize(),
      builder: (context, snapshot) {
        return widget.child;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    if (isDesktop()) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await windowManager.setPreventClose(true);
        await windowManager.setResizable(false);
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
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
              LanternFFI.exit();
              await trayManager.destroy();
              await windowManager.destroy();
              exit(0);
            },
          ),
        ],
      ),
    );
  }
}
