import 'package:shared_preferences/shared_preferences.dart';
import 'package:view_model/view_model.dart';

import 'login_page_event.dart';
import 'login_page_state.dart';

class LoginPageViewModel extends ViewModel<LoginPageState, LoginPageEvent> {
  LoginPageViewModel() : super(initialState: LoginPageState.initialState());

  static const _correctEmail = 'email@email.com';
  static const _correctPassword = '123456';
  String _email = '';
  String _password = '';
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

  Future<void> login() async {
    emitEvent(LoadingLoginEvent.start());
    await Future.delayed(const Duration(seconds: 2));

    if (_correctEmail != _email) {
      emitEvent(LoadingLoginEvent.stop());
      return emitState(state.emailNotFound());
    }

    if (_correctPassword != _password) {
      emitEvent(LoadingLoginEvent.stop());
      return emitState(state.incorrectPassword());
    }
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLogged', true);

    emitEvent(LoadingLoginEvent.stop());
    emitEvent(NavigateLoginEvent());
  }
}
