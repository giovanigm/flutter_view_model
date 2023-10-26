import 'package:example/page/widgets/loading_overlay.dart';
import 'package:example/view_model/event/login_event.dart';
import 'package:example/view_model/login_view_model.dart';
import 'package:example/view_model/state/login_state.dart';
import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import 'widgets/example_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider(
      create: (_) => LoginViewModel()..init(),
      child: ViewModelConsumer<LoginViewModel, LoginState, LoginEvent>(
          onEvent: (context, event) {
        event.when(
          error: (event) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(event.message),
              duration: const Duration(seconds: 1),
            ),
          ),
          startLoading: () => LoadingOverlay.of(context).open(),
          stopLoading: () => LoadingOverlay.of(context).close(),
          navigate: (event) =>
              Navigator.of(context).pushReplacementNamed(event.route),
        );
      }, builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
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
                ),
                const SizedBox(
                  height: 16,
                ),
                ExampleTextField(
                  hintText: "Password",
                  onChanged: context.read<LoginViewModel>().setPassword,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 24,
                ),
                FilledButton(
                  onPressed: () async {
                    await context.read<LoginViewModel>().login();
                  },
                  child: const Text('Login'),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
