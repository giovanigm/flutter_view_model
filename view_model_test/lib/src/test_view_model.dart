import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:view_model/view_model.dart';

class TestViewModel<State, SideEffect> extends Mock
    implements ViewModel<State, SideEffect> {
  TestViewModel();

  late State _state;

  late SideEffect _sideEffect;

  bool _stateEmitted = false;

  final _stateController = StreamController<State>.broadcast();
  final _sideEffectController = StreamController<SideEffect>.broadcast();

  void init({
    required State initialState,
    required SideEffect initialSideEffect,
  }) {
    _state = initialState;
    _sideEffect = initialSideEffect;
  }

  @override
  Stream<State> get stateStream => _stateController.stream;

  @override
  Stream<SideEffect> get sideEffectStream => _sideEffectController.stream;

  @override
  State get state => _state;

  @override
  SideEffect get sideEffect => _sideEffect;

  @override
  bool get isClosed =>
      _stateController.isClosed || _sideEffectController.isClosed;

  @override
  void emitState(State state) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new states after calling close');
      }
      if (state == _state && _stateEmitted) return;
      _state = state;
      _stateController.add(_state);
      _stateEmitted = true;
    } catch (error) {
      rethrow;
    }
  }

  @override
  void emitSideEffect(SideEffect sideEffect) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new side effects after calling close');
      }
      _sideEffect = sideEffect;
      _sideEffectController.add(sideEffect);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _stateController.close();
    await _sideEffectController.close();
  }
}
