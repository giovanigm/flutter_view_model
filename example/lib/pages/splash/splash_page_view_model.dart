import 'package:flutter_view_model/flutter_view_model.dart';

import 'splash_page_effect.dart';

class SplashPageViewModel extends ViewModel<void, SplashPageEffect> {
  SplashPageViewModel() : super(initialState: null);

  Future<void> load() async {
    await Future.delayed(const Duration(seconds: 2));
    emitEffect(LoadedSplashEffect());
  }
}
