import 'package:example/page/login/login_page.dart';
import 'package:example/page/widgets/loading_overlay.dart';
import 'package:example/view_model/login/login_view_model.dart';
import 'package:example/view_model/splash/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import 'page/counter/counter_page.dart';
import 'page/splash/splash_page.dart';
import 'view_model/counter/counter_view_model.dart';

void main() {
  runApp(const MainApp());
}

final routes = {
  '/counter': (context) => ViewModelProvider<CounterViewModel>(
        create: (_) => CounterViewModel(),
        child: const CounterPage(),
      ),
  '/login': (context) => ViewModelProvider<LoginViewModel>(
        create: (_) => LoginViewModel()..init(),
        child: const LoginPage(),
      ),
  '/': (context) => ViewModelProvider<SplashViewModel>(
        create: (_) => SplashViewModel()..load(),
        child: const SplashPage(),
      ),
};

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      builder: (context, child) =>
          LoadingOverlay(child: child ?? const Placeholder()),
      routes: routes,
      initialRoute: '/',
    );
  }
}
