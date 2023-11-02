import 'package:shared_preferences/shared_preferences.dart';
import 'package:view_model/view_model.dart';

import 'counter_page_event.dart';

class CounterPageViewModel extends ViewModel<int, CounterPageEvent> {
  CounterPageViewModel() : super(initialState: 0);

  void add() {
    final newState = state + 1;
    emitState(newState);
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    emitEvent(LoggoutEvent());
  }
}
