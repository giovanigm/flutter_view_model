import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [ViewModel] can manage the `State` of a View and send `Events` to it.
///
/// Every [ViewModel] requires an initial state which will be the
/// state of the [ViewModel] before [emitState] has been called.
///
/// The current state of a [ViewModel] can be accessed via the [state] getter
/// and the last event emitted can be accessed via the [lastEvent] getter.
///
/// ```dart
/// class CounterViewModel extends ViewModel<int, void> {
///   CounterViewModel() : super(initialState: 0);
///
///   void increment() => emitState(state + 1);
/// }
/// ```
abstract class ViewModel<State, Event> {
  ViewModel({required State initialState}) {
    _state = initialState;
  }

  late State _state;

  Event? _event;

  late final _stateController = StreamController<State>.broadcast();

  late final _eventController = StreamController<Event>.broadcast();

  /// The current [state]
  State get state => _state;

  /// The last event
  Event? get lastEvent => _event;

  /// The state stream
  Stream<State> get stateStream => _stateController.stream;

  /// The event stream
  Stream<Event> get eventStream => _eventController.stream;

  /// Whether the [ViewModel] is closed.
  ///
  /// A [ViewModel] is considered closed once [close] is called.
  bool isClosed = false;

  /// Emits a new [state]
  void emitState(State state) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new states after calling close');
        return;
      }
      if (state == _state) return;
      _state = state;
      _stateController.add(_state);
    } catch (error) {
      rethrow;
    }
  }

  /// Emits a new [event]
  void emitEvent(Event event) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new events after calling close');
        return;
      }
      _event = event;
      _eventController.add(event);
    } catch (error) {
      rethrow;
    }
  }

  /// Closes the [ViewModel]
  @mustCallSuper
  Future<void> close() async {
    await _stateController.close();
    await _eventController.close();
    isClosed = true;
  }
}
