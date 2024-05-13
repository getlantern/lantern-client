import 'package:animated_loading_border/animated_loading_border.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:lantern/core/router/router.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/messaging/messaging.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final globalRouter = AppRouter();
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

class _TickerProviderImpl extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

class LanternApp extends StatefulWidget {
  LanternApp({Key? key}) : super(key: key) {
    // Animate the visibility of the network warning notification bar. here in
    // Since this notification is visible on all screens and we want the
    // animation state to remain consistent across screens, we put the animation
    // controller here at the app level since the app contains all screens.
  }

  @override
  State<LanternApp> createState() => _LanternAppState();
}

class _LanternAppState extends State<LanternApp> {
  final translations = Localization.ensureInitialized();
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
      sessionModel.networkAvailable
          .addListener(toggleConnectivityWarningIfNecessary);
      sessionModel.proxyAvailable
          .addListener(toggleConnectivityWarningIfNecessary);
      networkWarningAnimationController = AnimationController(
        duration: shortAnimationDuration,
        vsync: _TickerProviderImpl(),
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

  void toggleConnectivityWarningIfNecessary() {
    final shouldShowConnectivityWarning =
        !sessionModel.networkAvailable.value ||
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

  @override
  Widget build(BuildContext context) {
    final currentLocal = View.of(context).platformDispatcher.locale;
    print('selected local: ${currentLocal.languageCode}');
    return ChangeNotifierProvider(
      create: (context) => BottomBarChangeNotifier(),
      child: FutureBuilder(
        future: translations,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return sessionModel.language(
            (context, lang, child) {
              Localization.locale = lang;
              return GlobalLoaderOverlay(
                useDefaultLoading: false,
                overlayColor: Colors.black.withOpacity(0.5),
                overlayWidget: Center(
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
                  child: MaterialApp.router(
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
                      colorScheme: ColorScheme.fromSwatch()
                          .copyWith(secondary: Colors.black),
                    ),
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  DeepLink navigateToDeepLink(PlatformDeepLink deepLink) {
    logger.d("DeepLink configuration: ${deepLink.configuration.toString()}");
    if (deepLink.path.toLowerCase().startsWith('/report-issue')) {
      logger.d("DeepLink uri: ${deepLink.uri.toString()}");
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
