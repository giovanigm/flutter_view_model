import 'package:example/page/widgets/loading_overlay.dart';
import 'package:example/view_model/login/login_event.dart';
import 'package:example/view_model/login/login_state.dart';
import 'package:example/view_model/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import '../widgets/example_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<LoginViewModel, LoginState, LoginEvent>(
      onEvent: (context, event) {
        event.when(
          startLoading: () => LoadingOverlay.of(context).open(),
          stopLoading: () => LoadingOverlay.of(context).close(),
          navigate: (event) =>
              Navigator.of(context).pushReplacementNamed(event.route),
        );
      },
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const SizedBox(height: 80, width: 80, child: FlutterLogo()),
                const SizedBox(
                  height: 32,
                ),
                ExampleTextField(
                  hintText: "Email",
                  onChanged: context.read<LoginViewModel>().setEmail,
                  errorText: state.emailTextError,
                  success: state.isValidEmail,
                ),
                const SizedBox(
                  height: 16,
                ),
                ExampleTextField(
                  hintText: "Password",
                  onChanged: context.read<LoginViewModel>().setPassword,
                  obscureText: true,
                  errorText: state.passwordTextError,
                  success: state.isValidPassword,
                ),
                const SizedBox(
                  height: 24,
                ),
                FilledButton(
                  onPressed: state.isValidPassword && state.isValidPassword
                      ? () async => await context.read<LoginViewModel>().login()
                      : null,
                  style: FilledButton.styleFrom(
                    disabledBackgroundColor: Theme.of(context).disabledColor,
                  ),
                  child: const Text('Login'),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
