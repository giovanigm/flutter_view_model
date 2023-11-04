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
  final String route = '/main';
}
