import 'package:flutter_view_model/flutter_view_model.dart';

class CounterPageViewModel extends ViewModel<int, void> {
  CounterPageViewModel() : super(initialState: 0);

  void add() {
    final newState = state + 1;
    emitState(newState);
  }
}
