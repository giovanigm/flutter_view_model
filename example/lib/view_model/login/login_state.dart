class LoginState {
  const LoginState._(
      {this.emailTextError,
      this.passwordTextError,
      this.isValidEmail = false,
      this.isValidPassword = false});

  final String? emailTextError;
  final String? passwordTextError;
  final bool isValidEmail;
  final bool isValidPassword;

  factory LoginState.initialState() {
    return const LoginState._();
  }

  LoginState invalidEmail() => LoginState._(
        emailTextError: 'Invalid email',
        passwordTextError: passwordTextError,
        isValidEmail: false,
        isValidPassword: isValidPassword,
      );

  LoginState emailNotFound() => LoginState._(
        emailTextError: 'Email not found',
        passwordTextError: passwordTextError,
        isValidEmail: false,
        isValidPassword: isValidPassword,
      );

  LoginState invalidPassword() => LoginState._(
        emailTextError: emailTextError,
        passwordTextError: 'Password must have at least 6 characters',
        isValidEmail: isValidEmail,
        isValidPassword: false,
      );

  LoginState incorrectPassword() => LoginState._(
        emailTextError: emailTextError,
        passwordTextError: 'Incorrect password',
        isValidEmail: isValidEmail,
        isValidPassword: false,
      );

  LoginState validPassword() => LoginState._(
        isValidEmail: isValidEmail,
        emailTextError: null,
        isValidPassword: true,
        passwordTextError: null,
      );

  LoginState validEmail() => LoginState._(
        isValidEmail: true,
        emailTextError: null,
        isValidPassword: isValidPassword,
        passwordTextError: passwordTextError,
      );
}
