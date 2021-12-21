import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';

class Language extends StatelessWidget {
  static const languages = [
    'en_US',
    'fa_IR',
    'zh_CN',
    'zh_HK',
    'ms_MY',
    'my_MM',
    'ru_RU',
    'tr_TR',
    'hi_IN',
    'ur_IN',
    'ar_EG',
    'vi_VN',
    'th_TH',
    'es_ES',
    'fr_FR',
  ];

  Language({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'language'.i18n,
      padVertical: true,
      body: sessionModel
          .language((BuildContext context, String currentLang, Widget? child) {
        return ListView.builder(
          itemCount: languages.length,
          itemBuilder: (BuildContext context, int index) {
            var lang = languages[index];
            return RadioListTile<String>(
              activeColor: pink4,
              contentPadding: const EdgeInsetsDirectional.all(0),
              tileColor: lang == currentLang ? grey2 : transparent,
              dense: true,
              title: CText(
                toBeginningOfSentenceCase(
                  lang.displayLanguage(context, lang),
                )!,
                style: tsBody1,
              ),
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
