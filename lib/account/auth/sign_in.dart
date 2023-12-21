import 'package:email_validator/email_validator.dart';
import '../../common/common.dart';

@RoutePage<void>(name: 'SignIn')
class SignIn extends StatefulWidget {
  final AuthFlow authFlow;

  const SignIn({
    super.key,
    this.authFlow = AuthFlow.signIn,
  });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _emailFormKey = GlobalKey<FormState>();
  late final _emailController = CustomTextEditingController(
    formKey: _emailFormKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _emailController.text = sessionModel.userEmail.value ?? "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.authFlow.isReset ? 'reset_password'.i18n : 'sign_in'.i18n,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 24),
            Form(
              key: _emailFormKey,
              child: CTextField(
                controller: _emailController,
                label: widget.authFlow.isReset
                    ? "lantern_pro_email".i18n
                    : "enter_email".i18n,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: SvgPicture.asset(ImagePaths.email),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Button(
                disabled: _emailController.text.isEmpty ||
                    _emailFormKey?.currentState?.validate() == false,
                text: widget.authFlow.isReset ? "next".i18n : 'continue'.i18n,
                onPressed:
                    widget.authFlow.isReset ? onNextTap : openCreatePassword,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.authFlow.isSignIn &&
                sessionModel.hasUserSignedInNotifier.value == false)
              AppTextButton(
                text: 'create_account'.i18n.toUpperCase(),
                onPressed: openPlans,
              )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SvgPicture.asset(
          ImagePaths.lantern_logo,
          height: 42,
        ),
        const SizedBox(width: 15),
        SvgPicture.asset(
          ImagePaths.free_logo,
          height: 25,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFormKey.currentState?.dispose();
    super.dispose();
  }

  ///Widget methods
  void openCreatePassword() {
    context.pushRoute(SignInPassword(email: _emailController.text));
  }

  Future<void> onNextTap() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      context.loaderOverlay.show();
      await sessionModel
          .startRecoveryByEmail(_emailController.text.validateEmail);
      context.loaderOverlay.hide();
      openVerification();
    } catch (e) {
      print(e.localizedDescription);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: 'Error while seeding email');
    }
  }

  void openVerification() {
    context.pushRoute(
        Verification(email: _emailController.text, authFlow: AuthFlow.reset));
  }

  void returnToSignIn() {
    context.popRoute();
  }

  Future<void> openPlans() async {
    await context.pushRoute(const PlansPage());
  }
}
