import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:view_model/view_model.dart';

class MockViewModel<State, SideEffect> extends Mock
    implements ViewModel<State, SideEffect> {
  MockViewModel() {
    when(() => stateStream).thenAnswer((_) => Stream<State>.empty());
    when(() => sideEffectStream).thenAnswer((_) => Stream<SideEffect>.empty());
    when(close).thenAnswer((_) => Future<void>.value());
  }

  void stub({
    required Stream<State> stateStream,
    required Stream<SideEffect> sideEffectStream,
    State? initialState,
    SideEffect? initialSideEffect,
  }) {
    if (initialState != null) {
      setInitialState(initialState);
    }
    if (initialSideEffect != null) {
      setInitialSideEffect(initialSideEffect);
    }
    setStateStream(stateStream);
    setSideEffectStream(sideEffectStream);
  }

  void setInitialState(State state) {
    when(() => this.state).thenReturn(state);
  }

  void setInitialSideEffect(SideEffect sideEffect) {
    when(() => this.sideEffect).thenReturn(sideEffect);
  }

  void setStateStream(Stream<State> stream) {
    final broadcastStream = stream.asBroadcastStream();
    when(() => stateStream).thenAnswer((_) => broadcastStream.map((state) {
          when(() => this.state).thenReturn(state);
          return state;
        }));
  }

  void setSideEffectStream(Stream<SideEffect> stream) {
    final broadcastStream = stream.asBroadcastStream();
    when(() => sideEffectStream)
        .thenAnswer((_) => broadcastStream.map((sideEffect) {
              when(() => this.sideEffect).thenReturn(sideEffect);
              return sideEffect;
            }));
  }
}
