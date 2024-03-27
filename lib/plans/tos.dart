import 'package:lantern/common/common.dart';
import 'package:url_launcher/url_launcher.dart';

class TOS extends StatelessWidget {
  const TOS({
    Key? key,
    required this.copy,
  }) : super(key: key);

  final String copy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onUrlTap(context),
      child: Container(
        padding: const EdgeInsetsDirectional.only(bottom: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CText(
              "${'by_clicking_tos'.i18n.fill([copy])} ",
              style: tsOverline,
            ),
            CText(
              'tos'.i18n,
              style: tsOverline.copiedWith(
                color: blue3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onUrlTap(BuildContext context) async {
    if (await canLaunchUrl(Uri.parse(AppSecret.tos))) {
      CDialog(
        title: 'open_url'.i18n,
        description: 'are_you_sure_you_want_to_open'.i18n.fill([AppSecret.tos]),
        agreeText: 'continue'.i18n,
        agreeAction: () async {
          await launchUrl(Uri.parse(AppSecret.tos));
          return true;
        },
      ).show(context);
    }
  }
}
