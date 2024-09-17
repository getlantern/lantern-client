import 'package:flutter/gestures.dart';

import '../../common/common.dart';

@RoutePage(name: 'AuthLanding')
class AuthLanding extends StatelessWidget {
  const AuthLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      showAppBar: false,
      body: sessionModel.proUser((context, proUser, child) {
        return _buildBody(context, proUser);
      }),
    );
  }

  Widget _buildBody(BuildContext context, bool proUser) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(ImagePaths.lantern_logo),
            const SizedBox(height: 16),
            SvgPicture.asset(ImagePaths.lantern_logotype),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: Button(
                text: proUser ? 'update_pro_account'.i18n : 'sign_in'.i18n,
                onPressed: () => openSignIn(context, proUser),
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: Button(
                text: proUser ? 'sign_in'.i18n : 'get_lantern_pro'.i18n,
                secondary: true,
                onPressed: () => openPlans(context, proUser),
              ),
            ),
            const SizedBox(height: 32.0),
            if (!proUser)
              RichText(
                text: TextSpan(
                  text: 'try_lantern_pro'.i18n,
                  style: tsBody1.copyWith(
                      fontWeight: FontWeight.w400, color: grey5),
                  children: [
                    TextSpan(
                      text: "continue_for_free".i18n.toUpperCase(),
                      style: tsBody1.copyWith(
                          fontWeight: FontWeight.w500, color: pink5),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => openHomePage(context),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void openHomePage(BuildContext context) {
    context.router.maybePop();
  }

  void openSignIn(BuildContext context, bool proUser) {
    if (proUser) {
      context.router.popAndPush(SignIn(authFlow: AuthFlow.updateAccount));
    } else {
      context.router.popAndPush(SignIn(authFlow: AuthFlow.signIn));
    }
  }

  void openPlans(BuildContext context, bool proUser) {
    if (proUser) {
      context.router.popAndPush(SignIn(authFlow: AuthFlow.signIn));
    } else {
      context.router.popAndPush(const PlansPage());
    }
  }
}
