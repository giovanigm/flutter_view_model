sealed class SplashEvent {
  T when<T>({
    required T Function(LoadedSplashEvent) loaded,
  }) {
    return switch (this) {
      LoadedSplashEvent value => loaded(value),
    };
  }
}

class LoadedSplashEvent extends SplashEvent {
  final String route;

  LoadedSplashEvent._({required this.route});

  factory LoadedSplashEvent.userLogged() =>
      LoadedSplashEvent._(route: '/counter');

  factory LoadedSplashEvent.userNotLoggedIn() =>
      LoadedSplashEvent._(route: '/login');
}
