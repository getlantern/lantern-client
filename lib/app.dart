import 'package:bot_toast/bot_toast.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final globalRouter = AppRouter(navigatorKey);

class LanternApp extends StatelessWidget {
  LanternApp({Key? key}) : super(key: key);

  final translations = Localization.loadTranslations();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => EventManager('lantern_event_channel')),
        Provider(
            create: (context) => EventManager('connectivity_event_channel')),
        Provider(
            create: (context) => const MethodChannel('lantern_method_channel')),
      ],
      // We typically don't use FutureBuilder, but it's okay here
      child: FutureBuilder(
          future: translations,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return GlobalLoaderOverlay(
              overlayColor: Colors.black,
              overlayOpacity: 0.6,
              child: I18n(
                initialLocale: const Locale('en', 'US'),
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    brightness: Brightness.light,
                    primarySwatch: Colors.grey,
                    appBarTheme: const AppBarTheme(
                        systemOverlayStyle: SystemUiOverlayStyle.light),
                    accentColor: Colors.black,
                  ),
                  title: 'app_name'.i18n,
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routeInformationParser: globalRouter.defaultRouteParser(),
                  routerDelegate: globalRouter.delegate(
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
                ),
              ),
            );
          }),
    );
  }
}
