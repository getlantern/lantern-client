
//Enum this is mange current flow of auth
enum AuthFlow { signIn, reset, createAccount }

extension AuthFlowExtension on AuthFlow {
  bool get isSignIn => this == AuthFlow.signIn;

  bool get isReset => this == AuthFlow.reset;

  bool get isCreateAccount => this == AuthFlow.createAccount;
}