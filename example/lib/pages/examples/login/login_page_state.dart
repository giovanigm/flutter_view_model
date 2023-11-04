class LoginPageState {
  const LoginPageState._({
    this.emailTextError,
    this.passwordTextError,
    this.isValidEmail = false,
    this.isValidPassword = false,
  });

  final String? emailTextError;
  final String? passwordTextError;
  final bool isValidEmail;
  final bool isValidPassword;

  factory LoginPageState.initialState() {
    return const LoginPageState._();
  }

  LoginPageState invalidEmail() => LoginPageState._(
        emailTextError: 'Invalid email',
        passwordTextError: passwordTextError,
        isValidEmail: false,
        isValidPassword: isValidPassword,
      );

  LoginPageState invalidPassword() => LoginPageState._(
        emailTextError: emailTextError,
        passwordTextError: 'Password must have at least 6 characters',
        isValidEmail: isValidEmail,
        isValidPassword: false,
      );

  LoginPageState validPassword() => LoginPageState._(
        isValidEmail: isValidEmail,
        emailTextError: emailTextError,
        isValidPassword: true,
        passwordTextError: null,
      );

  LoginPageState validEmail() => LoginPageState._(
        isValidEmail: true,
        emailTextError: null,
        isValidPassword: isValidPassword,
        passwordTextError: passwordTextError,
      );
}
