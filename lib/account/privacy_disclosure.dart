import 'package:lantern/common/common.dart';

class PrivacyDisclosure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FullScreenDialog(
      widget: Padding(
          padding: EdgeInsetsDirectional.only(
              start: 33, end: 33),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsetsDirectional.only(top: 38),
                child: CText(
                  'privacy_disclosure_title'.i18n,
                  style: tsSubtitle1.copiedWith(fontSize: 24.0),
                )),
                Padding(
                  padding: EdgeInsetsDirectional.only(top: 24, bottom: 24),
                  child: CText(
                    'privacy_disclosure_body'.i18n,
                    style: tsBody2.copiedWith(fontSize: 14.0, lineHeight: 24.0),
                  ),
                ),
                const Spacer(),
                Container(
                    margin: const EdgeInsetsDirectional.only(bottom: 38),
                    child: Button(
                      width: 200,
                      text: 'privacy_disclosure_accept'.i18n,
                      onPressed: () async => await sessionModel.acceptTerms(),
                    )),
              ])),
    );
  }
}
