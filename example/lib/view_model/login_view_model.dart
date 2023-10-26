import 'package:example/view_model/event/login_event.dart';
import 'package:example/view_model/state/login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:view_model/view_model.dart';

class LoginViewModel extends ViewModel<LoginState, LoginEvent> {
  LoginViewModel() : super(initialState: InitialLoginState());

  String _email = '';
  String _password = '';
  late SharedPreferences _preferences;

  void setEmail(String value) => _email = value;
  void setPassword(String value) => _password = value;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('email', 'email@email.com');
    await _preferences.setString('password', '123456');
  }

  Future<void> login() async {
    emitEvent(LoadingLoginEvent.open());
    await Future.delayed(const Duration(seconds: 2));

    final email = _preferences.getString('email');
    final password = _preferences.getString('password');

    if (email != _email || password != _password) {
      emitEvent(LoadingLoginEvent.close());
      return emitEvent(ErrorLoginEvent(message: "Invalid email or password!"));
    }

    emitEvent(LoadingLoginEvent.close());
    emitEvent(NavigateLoginEvent(route: '/counter'));
  }
}
