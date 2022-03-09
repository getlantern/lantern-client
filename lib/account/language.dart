import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/i18n/localization_constants.dart';

class Language extends StatelessWidget {
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
                  displayLanguage(lang),
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
