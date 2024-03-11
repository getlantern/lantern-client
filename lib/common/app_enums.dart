//Enum this is mange current flow of auth
enum AuthFlow { signIn, reset, createAccount, verifyEmail,proCodeActivation,changeEmail }



extension AuthFlowExtension on AuthFlow {
  bool get isSignIn => this == AuthFlow.signIn;

  bool get isReset => this == AuthFlow.reset;

  bool get isCreateAccount => this == AuthFlow.createAccount;

  bool get isVerifyEmail => this == AuthFlow.verifyEmail;
  bool get isproCodeActivation => this == AuthFlow.proCodeActivation;
}
