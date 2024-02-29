import 'package:flutter/cupertino.dart';

import '../../common/common.dart';
import '../../common/ui/password_criteria.dart';

@RoutePage<void>(name: 'ResetPassword')
class ResetPassword extends StatefulWidget {
  final String? email;
  final String? code;

  const ResetPassword({
    super.key,
    this.email,
    this.code,
  });

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool obscureText = false;
  final _passwordFormKey = GlobalKey<FormState>();
  late final _passwordController = CustomTextEditingController(
    formKey: _passwordFormKey,
  );
  final _confirmPasswordFormKey = GlobalKey<FormState>();
  late final _confirmPasswordController = CustomTextEditingController(
    formKey: _confirmPasswordFormKey,
    validator: (value) {
      if (value!.isEmpty) {
        return "Confirm Password is required";
      }
      if (value != _passwordController.text) {
        return "Confirm Password is not match";
      }
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: const AppBarProHeader(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              HeadingText(title: 'reset_password'.i18n),
              const SizedBox(height: 24),
              Form(
                key: _passwordFormKey,
                child: CTextField(
                  controller: _passwordController,
                  label: "new_password".i18n,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: obscureText,
                  maxLines: 1,
                  prefixIcon: SvgPicture.asset(ImagePaths.lock),
                  suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      child: obscureText
                          ? const Icon(CupertinoIcons.eye_slash_fill)
                          : SvgPicture.asset(ImagePaths.eye)),
                  // suffix: SvgPicture.asset(ImagePaths.eye),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 14),
              Form(
                key: _confirmPasswordFormKey,
                child: CTextField(
                  controller: _confirmPasswordController,
                  label: "confirm_new_password".i18n,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: obscureText,
                  maxLines: 1,
                  prefixIcon: SvgPicture.asset(ImagePaths.lock),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    child: obscureText
                        ? const Icon(CupertinoIcons.eye_slash_fill)
                        : SvgPicture.asset(ImagePaths.eye),
                  ),
                  // suffix: SvgPicture.asset(ImagePaths.eye),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 24),
              PasswordCriteriaWidget(
                  textEditingController: _confirmPasswordController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Button(
                  disabled:
                      (!_confirmPasswordController.text.isPasswordValid()),
                  text: 'reset_password'.i18n,
                  onPressed: onResetPasswordTap,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onResetPasswordTap() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.completeRecoveryByEmail(
          widget.email!, _passwordController.text, widget.code!);
      context.loaderOverlay.hide();
      showPasswordSuccessDialog();
    } catch (e) {
      mainLogger.e(e);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  void showPasswordSuccessDialog() {
    CDialog(
      icon: const CAssetImage(path: ImagePaths.check_green_large),
      title: "password_has_been_updated".i18n,
      description: "password_has_been_updated_message".i18n,
      barrierDismissible: false,
      dismissText: "continue".i18n,
      agreeText: "sign_in".i18n,
      includeCancel: true,
      dismissAction: () async {
        Future.delayed(const Duration(milliseconds: 300), () {
          context.router.popUntilRoot();
        });
      },
      agreeAction: () async {
        print("agree");
        Future.delayed(const Duration(milliseconds: 300), () {
          context.router.pushAndPopUntil(
            SignIn(),
            predicate: (route) => route.isFirst,
          );
        });
        return true;
      },
    ).show(context);
  }
}
