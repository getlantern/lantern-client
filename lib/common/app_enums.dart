//Enum this is mange current flow of auth
enum AuthFlow { signIn, reset, createAccount, verifyEmail }

enum AccountCreation { createAccount, proCodeActivation }

extension AuthFlowExtension on AuthFlow {
  bool get isSignIn => this == AuthFlow.signIn;

  bool get isReset => this == AuthFlow.reset;

  bool get isCreateAccount => this == AuthFlow.createAccount;

  bool get isVerifyEmail => this == AuthFlow.verifyEmail;
}
