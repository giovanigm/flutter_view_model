import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import '../widgets/example_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'login_page_event.dart';
import 'login_page_state.dart';
import 'login_page_view_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<LoginPageViewModel, LoginPageState,
        LoginPageEvent>(
      onEvent: (context, event) {
        FocusScope.of(context).unfocus();
        event.when(
          startLoading: () => LoadingOverlay.of(context).open(),
          stopLoading: () => LoadingOverlay.of(context).close(),
          showError: (message) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message))),
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
                  onChanged: context.read<LoginPageViewModel>().setEmail,
                  errorText: state.emailTextError,
                  success: state.isValidEmail,
                ),
                const SizedBox(
                  height: 16,
                ),
                ExampleTextField(
                  hintText: "Password",
                  onChanged: context.read<LoginPageViewModel>().setPassword,
                  obscureText: true,
                  errorText: state.passwordTextError,
                  success: state.isValidPassword,
                ),
                const SizedBox(
                  height: 24,
                ),
                FilledButton(
                  onPressed: state.isValidPassword && state.isValidEmail
                      ? () async =>
                          await context.read<LoginPageViewModel>().login()
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
