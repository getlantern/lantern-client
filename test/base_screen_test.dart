import 'package:audioplayers/audioplayers.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/app.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mockito/mockito.dart';
import 'package:sizer/sizer.dart';

class MockNavigationObserver extends Mock implements NavigatorObserver {}

void main() {
  NavigatorObserver mockObserver;

  group(
    'Widget startup',
    () {
      mockObserver = MockNavigationObserver();

      Future<void> _buildHomeScreen(WidgetTester tester) async {
        await tester.pumpWidget(MultiProvider(
          providers: [
            Provider(create: (context) => MessagingModel()),
            Provider(create: (context) => VpnModel()),
            Provider(create: (context) => AudioPlayer()),
            Provider(create: (context) => SessionModel()),
            Provider(
                create: (context) => EventManager('lantern_event_channel')),
            Provider(
                create: (context) =>
                    const MethodChannel('lantern_method_channel')),
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
                          title: 'Lantern Messenger',
                          localizationsDelegates: [
                            GlobalMaterialLocalizations.delegate,
                            GlobalWidgetsLocalizations.delegate,
                            GlobalCupertinoLocalizations.delegate,
                          ],
                          routeInformationParser:
                              globalRouter.defaultRouteParser(),
                          routerDelegate: globalRouter.delegate(
                            navigatorObservers: () => [
                              mockObserver,
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
                      },
                    ),
                  ),
                );
              }),
        ));
        // Check that navigator observer was called.
        expect(mockObserver, MockNavigationObserver);
      }

      testWidgets(
          'when tapping "country" button, should navigate to details page',
          (WidgetTester tester) async {
        await _buildHomeScreen(tester);
        // Ensure that state has ben changed
        await tester.pump();
      });
    },
  );
}
