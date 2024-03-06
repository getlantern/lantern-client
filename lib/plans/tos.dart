import 'package:flutter/gestures.dart';
import 'package:lantern/common/common.dart';

class TOS extends StatelessWidget {
  const TOS({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'by_creating_an_account'.i18n,
            style: tsFloatingLabel,
          ),
          const TextSpan(
            text: ' ',
          ),
          TextSpan(
            text: 'terms_of_service'.i18n,
            style: tsFloatingLabel!.copiedWith(
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => openTermsOfService(context),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  void openTermsOfService(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.pushRoute(AppWebview(url: termsOfService));
  }
}
