sealed class LoginPageEvent {
  T when<T>({
    required T Function() startLoading,
    required T Function() stopLoading,
    required T Function(String message) showError,
    required T Function() onAuthenticated,
  }) {
    return switch (this) {
      LoadingLoginEvent value => value.started ? startLoading() : stopLoading(),
      AuthenticationErrorLoginEvent value => showError(value.message),
      AuthenticatedLoginEvent _ => onAuthenticated(),
    };
  }
}

class LoadingLoginEvent extends LoginPageEvent {
  final bool started;

  factory LoadingLoginEvent.start() => LoadingLoginEvent._(started: true);
  factory LoadingLoginEvent.stop() => LoadingLoginEvent._(started: false);

  LoadingLoginEvent._({this.started = false});
}

class AuthenticationErrorLoginEvent extends LoginPageEvent {
  final String message;

  AuthenticationErrorLoginEvent(this.message);
}

class AuthenticatedLoginEvent extends LoginPageEvent {}
