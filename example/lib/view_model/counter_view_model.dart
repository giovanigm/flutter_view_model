import 'package:example/view_model/event/counter_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:view_model/view_model.dart';

class CounterViewModel extends ViewModel<int, CounterEvent> {
  CounterViewModel() : super(initialState: 0);

  void add() {
    final newState = state + 1;
    emitState(newState);
    emitEvent(newState % 2 == 0 ? EvenCounterEvent() : OddCounterEvent());
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    emitEvent(LoggoutCounterEvent(route: '/login'));
  }
}
