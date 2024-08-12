import 'package:email_validator/email_validator.dart';
import 'package:lantern/plans/utils.dart';
import '../../common/common.dart';

@RoutePage(name: "RestorePurchaseVerification")
class RestorePurchaseVerification extends StatefulWidget {
  const RestorePurchaseVerification({super.key});

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
      title: "lantern_pro_checkout".i18n,
      padHorizontal: true,
      padVertical: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[

        Center(child: CText("restore_purchase".i18n, style: tsHeading1)),
        const SizedBox(height: 16),
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
            text: "continue".i18n,
            onPressed: _onVerifyTap,
            disabled: _emailController.text.isEmpty ||
                _emailFormKey?.currentState?.validate() == false,
          ),
        ),
      ],
    );
  }

  Future<void> _onVerifyTap() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      context.loaderOverlay.show();
      final email = _emailController.text;
      await sessionModel.userEmailRequest(email.validateEmail);
      context.loaderOverlay.hide();
      context.pushRoute(Verification(
          email: email.validateEmail,
          authFlow: AuthFlow.restoreAccount,
          ));
    } catch (e) {
      context.loaderOverlay.hide();
      showError(context, description: e.localizedDescription);
    }
  }
}
