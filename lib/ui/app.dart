import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/event/EventManager.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/session_model.dart';
import 'package:lantern/model/vpn_model.dart';
import 'package:lantern/package_store.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:sizer/sizer.dart';

import 'home.dart';

final router = AppRouter();

class LanternApp extends StatelessWidget {
  LanternApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => MessagingModel()),
        Provider(create: (context) => VpnModel()),
        Provider(create: (context) => AudioPlayer()),
        Provider(create: (context) => SessionModel()),
        Provider(create: (context) => EventManager('lantern_event_channel')),
        Provider(
            create: (context) => const MethodChannel('lantern_method_channel')),
      ],
      child: FutureBuilder(
          future: Localization.loadTranslations(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            return GlobalLoaderOverlay(
              child: I18n(
                initialLocale: const Locale('en', 'US'),
                child: Sizer(
                  builder: (context, orientation, deviceType) {
                    return MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      theme: buildTheme(context),
                      title: 'Lantern Messenger',
                      localizationsDelegates: [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      routeInformationParser: router.defaultRouteParser(),
                      routerDelegate: router.delegate(
                        navigatorObservers: () => [
                          BotToastNavigatorObserver(),
                        ],
                      ),
                      builder: BotToastInit(),
                      supportedLocales: [
                        const Locale('ar', 'EG'),
                        const Locale('fr', 'FR'),
                        const Locale('en', 'US'),
                        const Locale('fa', 'IR'),
                        const Locale('th', 'TH'),
                        const Locale('ms', 'MY'),
                        const Locale('ru', 'RU'),
                        const Locale('ur', 'IN'),
                        const Locale('zh', 'CN'),
                        const Locale('zh', 'HK'),
                        const Locale('es', 'ES'),
                        const Locale('tr', 'TR'),
                        const Locale('vi', 'VN'),
                        const Locale('my', 'MM'),
                      ],
                    );
                    // return MaterialApp(

                    //   onGenerateRoute: (RouteSettings settings) {
                    //     return MaterialPageRoute<dynamic>(
                    //       builder: (context) {
                    //         return LoaderOverlay(
                    //           useDefaultLoading: true,
                    //           child: I18n(
                    //             initialLocale: const Locale('en', 'US'),
                    //             child: HomePage(settings.name!, settings.arguments),
                    //           ),
                    //         );
                    //       },
                    //       settings: settings,
                    //     );
                    //   },
                    //
                    // );
                  },
                ),
              ),
            );
          }),
    );
  }

  ThemeData buildTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.grey,
      appBarTheme:
          const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
      accentColor: Colors.black,
      textTheme: Theme.of(context).textTheme.copyWith(
            headline1: Theme.of(context)
                .textTheme
                .headline1
                ?.copyWith(color: Colors.black),
            headline2: Theme.of(context)
                .textTheme
                .headline2
                ?.copyWith(color: Colors.black),
            headline3: Theme.of(context)
                .textTheme
                .headline3
                ?.copyWith(color: Colors.black),
            headline4: Theme.of(context)
                .textTheme
                .headline4
                ?.copyWith(color: Colors.black),
            headline5: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(color: Colors.black),
            headline6: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(color: Colors.black),
            subtitle1: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(color: Colors.black),
            subtitle2: Theme.of(context)
                .textTheme
                .subtitle2
                ?.copyWith(color: Colors.black),
            bodyText1: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.black),
            bodyText2: Theme.of(context)
                .textTheme
                .bodyText2
                ?.copyWith(color: Colors.black),
            button: Theme.of(context)
                .textTheme
                .button
                ?.copyWith(color: Colors.black),
            caption: Theme.of(context)
                .textTheme
                .caption
                ?.copyWith(color: Colors.black),
            overline: Theme.of(context)
                .textTheme
                .overline
                ?.copyWith(color: Colors.black),
          ),
    );
  }
}
