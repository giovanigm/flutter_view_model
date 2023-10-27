sealed class LoginEvent {
  T when<T>({
    required T Function() startLoading,
    required T Function() stopLoading,
    required T Function(NavigateLoginEvent) navigate,
  }) {
    return switch (this) {
      LoadingLoginEvent value => value.open ? startLoading() : stopLoading(),
      NavigateLoginEvent value => navigate(value),
    };
  }
}

class LoadingLoginEvent extends LoginEvent {
  final bool open;

  factory LoadingLoginEvent.open() => LoadingLoginEvent._(open: true);
  factory LoadingLoginEvent.close() => LoadingLoginEvent._(open: false);

  LoadingLoginEvent._({this.open = false});
}

class NavigateLoginEvent extends LoginEvent {
  final String route = '/counter';
}
