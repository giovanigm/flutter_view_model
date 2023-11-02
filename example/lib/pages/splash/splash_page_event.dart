sealed class SplashPageEvent {
  T when<T>({
    required T Function(LoadedSplashEvent) loaded,
  }) {
    return switch (this) {
      LoadedSplashEvent value => loaded(value),
    };
  }
}

class LoadedSplashEvent extends SplashPageEvent {
  final String route;

  LoadedSplashEvent._({required this.route});

  factory LoadedSplashEvent.userLogged() =>
      LoadedSplashEvent._(route: '/counter');

  factory LoadedSplashEvent.userNotLoggedIn() =>
      LoadedSplashEvent._(route: '/login');
}
