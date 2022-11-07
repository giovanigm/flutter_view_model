// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class ViewModel<State, SideEffect> {
  ViewModel({
    required State initialState,
    required SideEffect initialSideEffect,
  }) {
    _state = initialState;
    _sideEffect = initialSideEffect;
  }

  late State _state;

  late SideEffect _sideEffect;

  bool _stateEmitted = false;

  late final _stateController = StreamController<State>.broadcast();

  late final _sideEffectController = StreamController<SideEffect>.broadcast();

  State get state => _state;

  SideEffect get sideEffect => _sideEffect;

  Stream<State> get stateStream => _stateController.stream;

  Stream<SideEffect> get sideEffectStream => _sideEffectController.stream;

  bool get isClosed =>
      _stateController.isClosed || _sideEffectController.isClosed;

  void emitState(State state) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new states after calling close');
        return;
      }
      if (state == _state && _stateEmitted) return;
      _state = state;
      _stateController.add(_state);
      _stateEmitted = true;
    } catch (error) {
      rethrow;
    }
  }

  void emitSideEffect(SideEffect sideEffect) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new side effects after calling close');
        return;
      }
      _sideEffect = sideEffect;
      _sideEffectController.add(sideEffect);
    } catch (error) {
      rethrow;
    }
  }

  @mustCallSuper
  Future<void> close() async {
    await _stateController.close();
    await _sideEffectController.close();
  }
}
