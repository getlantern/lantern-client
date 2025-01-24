import 'package:flutter/gestures.dart';
import 'package:lantern/core/utils/common.dart';

class TOS extends StatelessWidget {
  const TOS({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'by_clicking_continue'.i18n,
            style: tsFloatingLabel,
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: 'terms_of_service'.i18n,
            style: tsFloatingLabel!.copiedWith(
                decoration: TextDecoration.underline, color: onSwitchColor),
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
    context.pushRoute(AppWebview(url: termsOfService, title: 'TOS'));
  }
}
