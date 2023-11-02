import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import 'pages/counter/counter_page.dart';
import 'pages/counter/counter_page_view_model.dart';
import 'pages/login/login_page.dart';
import 'pages/login/login_page_view_model.dart';
import 'pages/splash/splash_page.dart';
import 'pages/splash/splash_page_view_model.dart';
import 'pages/widgets/loading_overlay.dart';

void main() {
  runApp(const MainApp());
}

final routes = {
  '/counter': (context) => ViewModelProvider<CounterPageViewModel>(
        create: (_) => CounterPageViewModel(),
        child: const CounterPage(),
      ),
  '/login': (context) => ViewModelProvider<LoginPageViewModel>(
        create: (_) => LoginPageViewModel(),
        child: const LoginPage(),
      ),
  '/': (context) => ViewModelProvider<SplashPageViewModel>(
        create: (_) => SplashPageViewModel()..load(),
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
