import 'package:example/view_model/login/login_event.dart';
import 'package:example/view_model/login/login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:view_model/view_model.dart';

class LoginViewModel extends ViewModel<LoginState, LoginEvent> {
  LoginViewModel() : super(initialState: LoginState.initialState());

  String _email = '';
  String _password = '';
  late SharedPreferences _preferences;
  final RegExp _emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  void setEmail(String value) {
    _email = value;

    final validEmail = _emailRegExp.hasMatch(value);
    emitState(validEmail ? state.validEmail() : state.invalidEmail());
  }

  void setPassword(String value) {
    _password = value;

    final validPassword = value.length >= 6;
    emitState(validPassword ? state.validPassword() : state.invalidPassword());
  }

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

    if (email != _email) {
      emitEvent(LoadingLoginEvent.close());
      return emitState(state.emailNotFound());
    }

    if (password != _password) {
      emitEvent(LoadingLoginEvent.close());
      return emitState(state.incorrectPassword());
    }
    await _preferences.setBool('isLogged', true);

    emitEvent(LoadingLoginEvent.close());
    emitEvent(NavigateLoginEvent());
  }
}
