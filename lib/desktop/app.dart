import 'package:flutter/material.dart';
import 'package:lantern/account/account_tab.dart';
import 'package:lantern/account/developer_settings.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/messaging/chats.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/replica/replica_tab.dart';
import 'package:lantern/vpn/try_lantern_chat.dart';
import 'package:lantern/vpn/vpn_tab.dart';
import 'package:logger/logger.dart';
import 'package:lantern/core/router/router.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final globalRouter = AppRouter();

// This enum is used to manage the font families used in the application
enum AppFontFamily {
  semim('Samim'),
  roboto('Roboto');

  // the actual string value (the font family name) to each enum value
  const AppFontFamily(this.fontFamily);

  final String fontFamily;
}

class DesktopApp extends StatefulWidget {
  const DesktopApp({Key? key}) : super(key: key);

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {

  final translations = Localization.ensureInitialized();

  @override
  Widget build(BuildContext context) {
    final currentLocal = View.of(context).platformDispatcher.locale;
    return FutureBuilder(
      future: translations,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        var lang = 'en';
        return GlobalLoaderOverlay(
          overlayColor: Colors.black,
          overlayOpacity: 0.6,
          child: I18n(
            initialLocale: currentLocale(lang),
            child: MaterialApp.router(
              locale: currentLocale(lang),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
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
  }

  Locale currentLocale(String lang) {
    if (lang == '' || lang.startsWith('en')) {
      return const Locale('en', 'US');
    }
    final codes = lang.split('_');
    return Locale(codes[0], codes[1]);
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
