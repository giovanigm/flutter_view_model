sealed class CounterEvent {
  T when<T>({
    required T Function() evenNumber,
    required T Function() oddNumber,
    required T Function(LoggoutCounterEvent) logout,
  }) {
    return switch (this) {
      EvenCounterEvent() => evenNumber(),
      OddCounterEvent() => oddNumber(),
      LoggoutCounterEvent value => logout(value),
    };
  }
}

class EvenCounterEvent extends CounterEvent {}

class OddCounterEvent extends CounterEvent {}

class LoggoutCounterEvent extends CounterEvent {
  final String route = '/login';
}
