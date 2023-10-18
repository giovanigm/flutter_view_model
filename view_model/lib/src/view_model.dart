import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class ViewModel<State, Event> {
  ViewModel({required State initialState}) {
    _state = initialState;
  }

  late State _state;

  Event? _event;

  bool _stateEmitted = false;

  late final _stateController = StreamController<State>.broadcast();

  late final _eventController = StreamController<Event>.broadcast();

  State get state => _state;

  Event? get lastEvent => _event;

  Stream<State> get stateStream => _stateController.stream;

  Stream<Event> get eventStream => _eventController.stream;

  bool isClosed = false;

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
        debugPrint('Cannot emit new events after calling close');
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
    isClosed = true;
  }
}
