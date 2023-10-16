import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:view_model/view_model.dart';

class TestViewModel<State, Event> extends Mock
    implements ViewModel<State, Event> {
  TestViewModel();

  late State _state;

  late Event _event;

  bool _stateEmitted = false;

  final _stateController = StreamController<State>.broadcast();
  final _eventController = StreamController<Event>.broadcast();

  void init({
    required State initialState,
    required Event initialEvent,
  }) {
    _state = initialState;
    _event = initialEvent;
  }

  @override
  Stream<State> get stateStream => _stateController.stream;

  @override
  Stream<Event> get eventStream => _eventController.stream;

  @override
  State get state => _state;

  @override
  Event get event => _event;

  @override
  bool get isClosed => _stateController.isClosed || _eventController.isClosed;

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
  void emitEvent(Event event) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new side effects after calling close');
      }
      _event = event;
      _eventController.add(event);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _stateController.close();
    await _eventController.close();
  }
}
