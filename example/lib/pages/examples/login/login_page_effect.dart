sealed class LoginPageEffect {
  T when<T>({
    required T Function() startLoading,
    required T Function() stopLoading,
    required T Function(String message) showError,
    required T Function() onAuthenticated,
  }) {
    return switch (this) {
      LoadingLoginEffect value =>
        value.started ? startLoading() : stopLoading(),
      AuthenticationErrorLoginEffect value => showError(value.message),
      AuthenticatedLoginEffect _ => onAuthenticated(),
    };
  }
}

class LoadingLoginEffect extends LoginPageEffect {
  final bool started;

  factory LoadingLoginEffect.start() => LoadingLoginEffect._(started: true);
  factory LoadingLoginEffect.stop() => LoadingLoginEffect._(started: false);

  LoadingLoginEffect._({this.started = false});
}

class AuthenticationErrorLoginEffect extends LoginPageEffect {
  final String message;

  AuthenticationErrorLoginEffect(this.message);
}

class AuthenticatedLoginEffect extends LoginPageEffect {}
