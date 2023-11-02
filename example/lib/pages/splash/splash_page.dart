import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import 'splash_page_event.dart';
import 'splash_page_view_model.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelListener<SplashPageViewModel, SplashPageEvent>(
      onEvent: (context, event) {
        event.when(
          loaded: (event) =>
              Navigator.of(context).pushReplacementNamed(event.route),
        );
      },
      child: const Scaffold(
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
    );
  }
}
