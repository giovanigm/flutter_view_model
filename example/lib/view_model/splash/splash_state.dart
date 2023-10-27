sealed class SplashState {
  T when<T>({
    required T Function() error,
    required T Function() loading,
  }) {
    return switch (this) {
      LoadingSplashState() => loading(),
      ErrorSplashState() => error(),
    };
  }
}

class LoadingSplashState extends SplashState {}

class ErrorSplashState extends SplashState {}
