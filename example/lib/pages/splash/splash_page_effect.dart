sealed class SplashPageEffect {
  T when<T>({
    required T Function(LoadedSplashEffect) loaded,
  }) {
    return switch (this) {
      LoadedSplashEffect value => loaded(value),
    };
  }
}

class LoadedSplashEffect extends SplashPageEffect {
  final String route = '/main';
}
