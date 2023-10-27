import 'package:example/view_model/splash/splash_event.dart';
import 'package:example/view_model/splash/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import '../../view_model/splash/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<SplashViewModel, SplashState, SplashEvent>(
      onEvent: (context, event) {
        event.when(
          loaded: (event) =>
              Navigator.of(context).pushReplacementNamed(event.route),
        );
      },
      builder: (context, state) => state.when(
        error: () => const Center(
          child: Text('Ops! Something went wrong'),
        ),
        loading: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80, width: 80, child: FlutterLogo()),
                SizedBox(height: 24),
                Text(
                  'Flutter View Model',
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
