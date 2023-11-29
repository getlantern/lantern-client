import 'package:flutter/cupertino.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'ResetPassword')
class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

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
      title: 'reset_password'.i18n,
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
            const SizedBox(height: 24),
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
            SizedBox(
              width: double.infinity,
              child: Button(
                // disabled: _passwordController.text.isEmpty ||
                //     _passwordFormKey?.currentState?.validate() == false,
                text: 'reset_password'.i18n,
                onPressed: onResetPasswordTap,
              ),
            ),
            const SizedBox(height: 24),
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

  void onResetPasswordTap() {
    //Send user back to account screen
    context.router.popUntilRoot();
  }
}
