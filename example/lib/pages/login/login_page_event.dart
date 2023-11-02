sealed class LoginPageEvent {
  T when<T>({
    required T Function() startLoading,
    required T Function() stopLoading,
    required T Function(NavigateLoginEvent) navigate,
  }) {
    return switch (this) {
      LoadingLoginEvent value => value.started ? startLoading() : stopLoading(),
      NavigateLoginEvent value => navigate(value),
    };
  }
}

class LoadingLoginEvent extends LoginPageEvent {
  final bool started;

  factory LoadingLoginEvent.start() => LoadingLoginEvent._(started: true);
  factory LoadingLoginEvent.stop() => LoadingLoginEvent._(started: false);

  LoadingLoginEvent._({this.started = false});
}

class NavigateLoginEvent extends LoginPageEvent {
  final String route = '/counter';
}
