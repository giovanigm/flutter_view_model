import 'package:flutter_view_model/flutter_view_model.dart';

import 'splash_page_event.dart';

class SplashPageViewModel extends ViewModel<void, SplashPageEvent> {
  SplashPageViewModel() : super(initialState: null);

  Future<void> load() async {
    await Future.delayed(const Duration(seconds: 2));
    emitEvent(LoadedSplashEvent());
  }
}
