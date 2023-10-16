// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class ViewModel<State, Event> {
  ViewModel({
    required State initialState,
    required Event initialEvent,
  }) {
    _state = initialState;
    _event = initialEvent;
  }

  late State _state;

  late Event _event;

  bool _stateEmitted = false;

  late final _stateController = StreamController<State>.broadcast();

  late final _eventController = StreamController<Event>.broadcast();

  State get state => _state;

  Event get event => _event;

  Stream<State> get stateStream => _stateController.stream;

  Stream<Event> get eventStream => _eventController.stream;

  bool get isClosed => _stateController.isClosed || _eventController.isClosed;

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

  void emitEvent(Event event) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new side effects after calling close');
        return;
      }
      _event = event;
      _eventController.add(event);
    } catch (error) {
      rethrow;
    }
  }

  @mustCallSuper
  Future<void> close() async {
    await _stateController.close();
    await _eventController.close();
  }
}
