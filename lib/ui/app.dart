import 'package:flutter/services.dart';
import 'package:lantern/event/EventManager.dart';
import 'package:lantern/model/session.dart';
import 'package:lantern/model/vpn_model.dart';
import 'package:lantern/package_store.dart';

import 'home.dart';

class LanternApp extends StatefulWidget {
  LanternApp({Key key}) : super(key: key);

  @override
  _LanternAppState createState() => _LanternAppState();
}

class _LanternAppState extends State<LanternApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => VpnModel()),
        Provider(create: (context) => SessionModel()),
        Provider(create: (context) => EventManager("lantern_event_channel")),
        Provider(create: (context) => MethodChannel("lantern_method_channel")),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lantern Messenger',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', "US"),
          const Locale('es'),
        ],
        theme: buildTheme(),
        home: I18n(child: HomePage(), initialLocale: Locale("en", "US")),
      ),
    );
  }

  ThemeData buildTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.grey,
      appBarTheme: AppBarTheme(brightness: Brightness.light),
      accentColor: Colors.black,
      textTheme: Theme.of(context).textTheme.copyWith(
            headline1: Theme.of(context)
                .textTheme
                .headline1
                .copyWith(color: Colors.black),
            headline2: Theme.of(context)
                .textTheme
                .headline2
                .copyWith(color: Colors.black),
            headline3: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(color: Colors.black),
            headline4: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: Colors.black),
            headline5: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.black),
            headline6: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.black),
            subtitle1: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: Colors.black),
            subtitle2: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(color: Colors.black),
            bodyText1: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.black),
            bodyText2: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.black),
            button: Theme.of(context)
                .textTheme
                .button
                .copyWith(color: Colors.black),
            caption: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: Colors.black),
            overline: Theme.of(context)
                .textTheme
                .overline
                .copyWith(color: Colors.black),
          ),
    );
  }
}
