import 'package:example/page/login_page.dart';
import 'package:example/page/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';

import 'page/counter_page.dart';

void main() {
  runApp(const MainApp());
}

final routes = {
  '/counter': (context) => const CounterPage(),
  '/login': (context) => const LoginPage(),
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
      home: const LoginPage(),
    );
  }
}
