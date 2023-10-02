import 'package:flutter/scheduler.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router.dart';
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

class LanternApp extends StatelessWidget {
  LanternApp({Key? key}) : super(key: key) {
    // Animate the visibility of the network warning notification bar. here in
    // Since this notification is visible on all screens and we want the
    // animation state to remain consistent across screens, we put the animation
    // controller here at the app level since the app contains all screens.
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

  final translations = Localization.ensureInitialized();
  late final AnimationController networkWarningAnimationController;
  late final Animation networkWarningAnimation;

  void networkWarningAnimationChanged() {
    networkWarningBarHeightRatio.value = networkWarningAnimation.value;
  }

  void toggleConnectivityWarningIfNecessary() {
    final shouldShowConnectivityWarning =
        !sessionModel.networkAvailable.value ||
            sessionModel.proxyAvailable.value != true;
    if (shouldShowConnectivityWarning != showConnectivityWarning) {
      showConnectivityWarning = shouldShowConnectivityWarning;
      if (showConnectivityWarning) {
        networkWarningAnimationController.forward();
      } else {
        networkWarningAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocal = View.of(context).platformDispatcher.locale;
    print('selected local: ${currentLocal.languageCode}');
    return FutureBuilder(
      future: translations,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return sessionModel.language(
          (context, lang, child) {
            Localization.locale = lang;
        return GlobalLoaderOverlay(
              overlayColor: Colors.black,
              overlayOpacity: 0.6,
              child: I18n(
                initialLocale: lang == '' || lang.startsWith('en')
                    ? const Locale('en', 'US')
                    : Locale(lang),
                child: MaterialApp.router(
                  locale: lang == '' || lang.startsWith('en')
                      ? const Locale('en', 'US')
                      : Locale(lang),
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
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
                  routeInformationParser: globalRouter.defaultRouteParser(),
                  routerDelegate: globalRouter.delegate(),
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
    );
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
