import 'package:lantern/core/utils/common.dart';

class PrivacyDisclosure extends StatelessWidget {
  const PrivacyDisclosure({super.key});

  @override
  Widget build(BuildContext context) {
    return FullScreenDialog(
      widget: Padding(
        padding: const EdgeInsetsDirectional.only(start: 33, end: 33),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsetsDirectional.only(top: 38),
                child: CText(
                  'privacy_disclosure_title'.i18n,
                  style: tsSubtitle1.copiedWith(fontSize: 24.0),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 24, bottom: 24),
                child: CText(
                  'privacy_disclosure_body'.i18n,
                  style: tsBody2.copiedWith(fontSize: 14.0, lineHeight: 24.0),
                ),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(bottom: 38),
                child: Button(
                  width: 200,
                  text: 'privacy_disclosure_accept'.i18n,
                  onPressed: () async => await sessionModel.acceptTerms(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
