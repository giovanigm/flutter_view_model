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
/// class MyViewModel extends ViewModel<MyState, MyEvent> {
///   MyViewModel() : super(initialState: MyState());
///
///   void doSomething() {
///     emitState(MyState());
///     emitEvent(MyEvent());
///   }
/// }
/// ```
abstract class ViewModel<State, Effect> {
  ViewModel({required State initialState}) {
    _state = initialState;
  }

  late State _state;

  Effect? _effect;

  late final _stateController = StreamController<State>.broadcast();

  late final _effectController = StreamController<Effect>.broadcast();

  /// The current [state]
  State get state => _state;

  /// The last event
  Effect? get lastEffect => _effect;

  /// The state stream
  ///
  /// Will be canceled after [close] is called.
  Stream<State> get stateStream => _stateController.stream;

  /// The event stream
  ///
  /// Will be canceled after [close] is called.
  Stream<Effect> get effectStream => _effectController.stream;

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
  void emitEffect(Effect effect) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new effects after calling close');
        return;
      }
      _effect = effect;
      _effectController.add(effect);
    } catch (error) {
      rethrow;
    }
  }

  /// Closes the [ViewModel]
  @mustCallSuper
  Future<void> close() async {
    await _stateController.close();
    await _effectController.close();
    isClosed = true;
  }
}
