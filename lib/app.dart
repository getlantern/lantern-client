import 'package:animated_loading_border/animated_loading_border.dart';
import 'package:app_links/app_links.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lantern/core/router/router.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/messaging/messaging.dart';
import 'package:lantern/features/tray/tray_container.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:lantern/features/window/window_container.dart';

import 'common/ui/custom/internet_checker.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final globalRouter = sl<AppRouter>();
final networkWarningBarHeightRatio = ValueNotifier(0.0);
var showConnectivityWarning = false;

// This enum is used to manage the font families used in the application
enum AppFontFamily {
  semim('Samim'),
  roboto('Roboto');

  // the actual string value (the font family name) to each enum value
  const AppFontFamily(this.fontFamily);

  final String fontFamily;
}

class LanternApp extends StatefulWidget {
  const LanternApp({super.key});

  @override
  State<LanternApp> createState() => _LanternAppState();
}

class _LanternAppState extends State<LanternApp>
    with SingleTickerProviderStateMixin {
  late final AnimationController networkWarningAnimationController;
  late final Animation networkWarningAnimation;

  @override
  void initState() {
    _animateNetworkWarning();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initDeepLinks();
    });
    super.initState();
  }

  void _animateNetworkWarning() {
    if (isMobile()) {
      // sessionModel.proxyAvailable.addListener(toggleConnectivityWarningIfNecessary);
      networkWarningAnimationController = AnimationController(
        duration: shortAnimationDuration,
        vsync: this,
      );
      networkWarningAnimation = Tween(begin: 0.0, end: 1.0)
          .animate(networkWarningAnimationController)
        ..addListener(networkWarningAnimationChanged);
      toggleConnectivityWarningIfNecessary();
    }
  }

  Future<void> initDeepLinks() async {
    final appLinks = AppLinks();
    // Handle link when app is in warm state (front or background)
    appLinks.uriLinkStream.listen((Uri uri) {
      if (context.mounted) {
        if (uri.path.startsWith('/report-issue')) {
          final pathUrl = uri.toString();
          final segment = pathUrl.split('#');
          if (segment.length >= 2) {
            globalRouter.push(ReportIssue(description: '#${segment[1]}'));
          } else {
            globalRouter.push(ReportIssue());
          }
        }
      }
    });
  }

  void networkWarningAnimationChanged() {
    networkWarningBarHeightRatio.value = networkWarningAnimation.value;
  }

  Future<void> toggleConnectivityWarningIfNecessary() async {
    final hasConnection = await InternetConnection().hasInternetAccess;
    //Check if the device has internet connection
    //if not then proxy will not be available
    //We already showing on internet connection error
    if (!hasConnection) {
      return;
    }

    final vpnConnected = await vpnModel.isVpnConnected();

    /// If vpn is not connected then we should not show the connectivity warning
    if (!vpnConnected) {
      return;
    }
    final shouldShowConnectivityWarning =
        (sessionModel.proxyAvailable.value != null &&
            sessionModel.proxyAvailable.value == false);

    if (shouldShowConnectivityWarning != showConnectivityWarning) {
      showConnectivityWarning = shouldShowConnectivityWarning;
      if (showConnectivityWarning) {
        networkWarningAnimationController.forward();
      } else {

        networkWarningAnimationController.reverse();
      }
      // Update the state after running the animations.
    }
  }

  Widget _buildMaterialApp(
      BuildContext context, String lang, Locale currentLocal) {
    final app = MaterialApp.router(
      locale: currentLocale(lang),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: _getLocaleBasedFont(currentLocal),
        brightness: Brightness.light,
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
      ),
      themeMode: ThemeMode.system,
      title: 'app_name'.i18n,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: globalRouter.config(
        deepLinkBuilder: navigateToDeepLink,
      ),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('fr', 'FR'),
        Locale('en', 'US'),
        Locale('fa', 'IR'),
        Locale('th', 'TH'),
        Locale('ms', 'MY'),
        Locale('ru', 'RU'),
        Locale('ur', 'IN'),
        Locale('zh', 'CN'),
        Locale('zh', 'HK'),
        Locale('es', 'ES'),
        Locale('es', 'CU'),
        Locale('tr', 'TR'),
        Locale('vi', 'VN'),
        Locale('my', 'MM'),
      ],
    );
    if (isDesktop()) {
      return WindowContainer(
        TrayContainer(app),
      );
    }
    return app;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocal = View.of(context).platformDispatcher.locale;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => sl<BottomBarChangeNotifier>()),
        ChangeNotifierProvider(create: (context) => sl<VPNChangeNotifier>()),
        ChangeNotifierProvider(create: (context) => sl<InternetStatusProvider>()),
      ],
      child: sessionModel.language(
        (context, lang, child) {
          Localization.locale = lang.startsWith('en') ? "en_us" : lang;
          return GlobalLoaderOverlay(
            overlayColor: Colors.black.withOpacity(0.5),
            overlayWidgetBuilder: (_) => Center(
              child: AnimatedLoadingBorder(
                borderWidth: 5,
                borderColor: yellow3,
                cornerRadius: 100,
                child: SvgPicture.asset(
                  ImagePaths.lantern_logo,
                ),
              ),
            ),
            child: I18n(
              initialLocale: currentLocale(lang),
              child: _buildMaterialApp(context, lang, currentLocal),
            ),
          );
        },
      ),
    );
  }

  DeepLink navigateToDeepLink(PlatformDeepLink deepLink) {
    if (!Platform.isAndroid) {
      return DeepLink.defaultPath;
    }
    appLogger.d("DeepLink configuration: ${deepLink.configuration.toString()}");
    if (deepLink.path.toLowerCase().startsWith('/report-issue')) {
      appLogger.d("DeepLink uri: ${deepLink.uri.toString()}");
      final pathUrl = deepLink.uri.toString();
      final segment = pathUrl.split('#');
      //If deeplink doesn't have data it should send to report issue with empty description'
      if (segment.length >= 2) {
        final description = segment[1];
        return DeepLink(
            [const Home(), ReportIssue(description: '#$description')]);
      }
      return DeepLink([const Home(), ReportIssue()]);
    } else {
      return DeepLink.defaultPath;
    }
  }

  Locale currentLocale(String lang) {
    if (lang == '' || lang.startsWith('en')) {
      return const Locale('en', 'US');
    }
    final codes = lang.split('_');
    // Check if the split code has more than one part
    if (codes.length > 1) {
      return Locale(codes[0], codes[1]);
    } else {
      // If not, return default locale
      return const Locale('en', 'US');
    }
  }

  String _getLocaleBasedFont(Locale locale) {
    if (locale.languageCode == 'fa' ||
        locale.languageCode == 'ur' ||
        locale.languageCode == 'eg') {
      return AppFontFamily.semim.fontFamily; // Farsi font
    } else {
      return AppFontFamily
          .roboto.fontFamily; // Default font for other languages
    }
  }
}
