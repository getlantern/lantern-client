import 'test_common.dart';




Widget wrapWithMaterialApp(Widget widget) {
  return MaterialApp(
    title: 'app_name'.i18n,
    home: widget,
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
      Locale('es', 'CU'),
      Locale('tr', 'TR'),
      Locale('vi', 'VN'),
      Locale('my', 'MM'),
    ],
  );
}
