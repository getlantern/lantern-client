//Enum this is mange current flow of auth
enum AuthFlow {
  signIn,
  reset,
  createAccount,
  verifyEmail,
  proCodeActivation,
  changeEmail,
  updateAccount,
  restoreAccount
}

extension AuthFlowExtension on AuthFlow {
  bool get isSignIn => this == AuthFlow.signIn;

  bool get isReset => this == AuthFlow.reset;

  bool get isCreateAccount => this == AuthFlow.createAccount;

  bool get isVerifyEmail => this == AuthFlow.verifyEmail;

  bool get isProCodeActivation => this == AuthFlow.proCodeActivation;
  bool get isUpdateAccount => this == AuthFlow.updateAccount;
  bool get isRestoreAccount => this == AuthFlow.restoreAccount;
}
