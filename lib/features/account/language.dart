import 'package:intl/intl.dart';
import 'package:lantern/core/localization/localization_constants.dart';
import 'package:lantern/core/utils/common.dart';

@RoutePage(name: 'Language')
class Language extends StatelessWidget {
  const Language({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'language'.i18n,
      padVertical: true,
      body: sessionModel
          .language((BuildContext context, String currentLang, Widget? child) {
        // Splint language by just code
        final countryCode = checkSupportedLanguages(currentLang);
        return ListView.builder(
          itemCount: languages.length,
          itemBuilder: (BuildContext context, int index) {
            var lang = languages[index];
            return RadioListTile<String>(
                activeColor: pink4,
                contentPadding: const EdgeInsetsDirectional.all(0),
                tileColor: lang == countryCode ? grey2 : transparent,
                dense: true,
                title: CText(
                  toBeginningOfSentenceCase(displayLanguage(lang))!,
                  style: tsBody1,
                ),
                value: lang,
                groupValue: countryCode,
                onChanged: (newLocal) => onLocalChange(newLocal!, context));
          },
        );
      }),
    );
  }

  Future<void> onLocalChange(String newLocal, BuildContext context) async {
    try {
      await sessionModel.setLanguage(newLocal);
      Navigator.pop(context);
    } catch (e, stack) {
      mainLogger.e("Error changing language: $e", stackTrace: stack);
    }
  }
}
