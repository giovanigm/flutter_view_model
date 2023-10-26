sealed class LoginEvent {
  T when<T>({
    required T Function(ErrorLoginEvent) error,
    required T Function() startLoading,
    required T Function() stopLoading,
    required T Function(NavigateLoginEvent) navigate,
  }) {
    return switch (this) {
      ErrorLoginEvent value => error(value),
      LoadingLoginEvent value => value.open ? startLoading() : stopLoading(),
      NavigateLoginEvent value => navigate(value),
    };
  }
}

class ErrorLoginEvent extends LoginEvent {
  final String message;

  ErrorLoginEvent({required this.message}) : super();
}

class LoadingLoginEvent extends LoginEvent {
  final bool open;

  factory LoadingLoginEvent.open() => LoadingLoginEvent._(open: true);
  factory LoadingLoginEvent.close() => LoadingLoginEvent._(open: false);

  LoadingLoginEvent._({this.open = false});
}

class NavigateLoginEvent extends LoginEvent {
  final String route;

  NavigateLoginEvent({required this.route});
}
