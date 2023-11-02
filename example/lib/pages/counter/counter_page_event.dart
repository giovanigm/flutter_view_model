sealed class CounterPageEvent {
  T when<T>({
    required T Function(LoggoutEvent) logout,
  }) {
    return switch (this) {
      LoggoutEvent value => logout(value),
    };
  }
}

class LoggoutEvent extends CounterPageEvent {
  final String route = '/login';
}
