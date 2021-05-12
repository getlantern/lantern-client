import 'package:intl/intl.dart';
import 'package:lantern/package_store.dart';

class LanguageScreen extends StatelessWidget {
  static const languages = [
    'ms_MY',
    'en_US',
    'es_ES',
    'fr_FR',
    'vi_VN',
    'tr_TR',
    'ru_RU',
    'ur_IN',
    'ar_EG',
    'fa_IR',
    'th_TH',
    'my_MM',
    'zh_CN',
    'zh_HK',
  ];

  LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'language'.i18n,
      body: sessionModel
          .language((BuildContext context, String currentLang, Widget? child) {
        return ListView.builder(
          itemCount: languages.length,
          itemBuilder: (BuildContext context, int index) {
            var lang = languages[index];
            return RadioListTile<String>(
              title: Text(
                  toBeginningOfSentenceCase(
                      lang.displayLanguage(context, lang))!,
                  style: lang == currentLang
                      ? tsSelectedTitleItem()
                      : tsTitleItem()),
              value: lang,
              groupValue: currentLang,
              onChanged: (String? value) async {
                await sessionModel.setLanguage(lang);
                Navigator.pop(context);
              },
            );
          },
        );
      }),
    );
  }
}
