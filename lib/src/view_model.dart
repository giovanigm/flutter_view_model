import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class ViewModel<State, Effect> {
  ViewModel({required State initialState}) {
    _state = initialState;
  }

  late State _state;

  Effect? _effect;

  late final _stateController = StreamController<State>.broadcast();

  late final _effectController = StreamController<Effect>.broadcast();

  State get state => _state;

  Effect? get lastEffect => _effect;

  Stream<State> get stateStream => _stateController.stream;

  Stream<Effect> get effectStream => _effectController.stream;

  bool isClosed = false;

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

  @mustCallSuper
  Future<void> close() async {
    await _stateController.close();
    await _effectController.close();
    isClosed = true;
  }
}
