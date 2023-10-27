import 'package:example/view_model/splash/splash_event.dart';
import 'package:example/view_model/splash/splash_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:view_model/view_model.dart';

class SplashViewModel extends ViewModel<SplashState, SplashEvent> {
  SplashViewModel() : super(initialState: LoadingSplashState());

  Future<void> load() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final preferences = await SharedPreferences.getInstance();
      final isUserLoggedIn =
          preferences.getBool('isLogged') == true ? true : false;
      emitEvent(isUserLoggedIn
          ? LoadedSplashEvent.userLogged()
          : LoadedSplashEvent.userNotLoggedIn());
    } catch (error) {
      emitState(ErrorSplashState());
    }
  }
}
