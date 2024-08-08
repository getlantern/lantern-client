import 'package:email_validator/email_validator.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../common/common.dart';

@RoutePage(name: "RestorePurchaseVerification")
class RestorePurchaseVerification extends StatefulWidget {
  final PurchaseDetails purchaseDetails;

  const RestorePurchaseVerification({super.key, required this.purchaseDetails});

  @override
  State<RestorePurchaseVerification> createState() =>
      _RestorePurchaseVerificationState();
}

class _RestorePurchaseVerificationState
    extends State<RestorePurchaseVerification> {
  final _emailFormKey = GlobalKey<FormState>();
  late final _emailController = CustomTextEditingController(
    formKey: _emailFormKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Restore Purchase",
      padHorizontal: true,
      padVertical: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        HeadingText(title: 'verification'.i18n),
        const SizedBox(height: 24),
        Form(
          key: _emailFormKey,
          child: CTextField(
            inputFormatters: [
              EmojiFilteringTextInputFormatter(),
            ],
            controller: _emailController,
            label: "enter_email".i18n,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: SvgPicture.asset(ImagePaths.email),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: CText(
            'warning_restore_purchase'.i18n,
            style: tsBody2.copiedWith(color: grey5),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Button(
            text: "verify".i18n,
            onPressed: _onVerifyTap,
            disabled: _emailController.text.isEmpty ||
                _emailFormKey?.currentState?.validate() == false,
          ),
        ),
      ],
    );
  }

  void _onVerifyTap() {}
}
