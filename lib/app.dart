import 'package:animated_loading_border/animated_loading_border.dart';
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

class LanternApp extends StatefulWidget {
  const LanternApp({Key? key}) : super(key: key);

  @override
  State<LanternApp> createState() => _LanternAppState();
}

class _LanternAppState extends State<LanternApp>
    with SingleTickerProviderStateMixin {
  late final AnimationController networkWarningAnimationController;
  late final Animation networkWarningAnimation;

  @override
  void initState() {
    super.initState();
    sessionModel.networkAvailable
        .addListener(toggleConnectivityWarningIfNecessary);
    sessionModel.proxyAvailable
        .addListener(toggleConnectivityWarningIfNecessary);
    networkWarningAnimationController = AnimationController(
      duration: shortAnimationDuration,
      vsync: this,
    );
    networkWarningAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(networkWarningAnimationController)
      ..addListener(networkWarningAnimationChanged);
    toggleConnectivityWarningIfNecessary();
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
              routerDelegate: globalRouter.delegate(),
              routeInformationParser: globalRouter.defaultRouteParser(),
              theme: ThemeData(
                useMaterial3: false,
                fontFamily: _getLocaleBasedFont(currentLocal),
                brightness: Brightness.light,
                primarySwatch: Colors.grey,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                ),
                colorScheme:
                    ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
              ),
              title: 'app_name'.i18n,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
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
