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
    const href = 'https://s3.amazonaws.com/lantern/Lantern-TOS.pdf';
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(href)) {
          CDialog(
            title: 'open_url'.i18n,
            description: 'are_you_sure_you_want_to_open'.i18n.fill([href]),
            agreeText: 'continue'.i18n,
            agreeAction: () async {
              await launch(href);
              return true;
            },
          ).show(context);
        }
        ;
      },
      child: Container(
        padding: const EdgeInsetsDirectional.only(bottom: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CText(
              'are_you_sure_you_want_to_open'.i18n.fill([copy]),
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
}
