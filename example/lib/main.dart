import 'package:flutter/material.dart';
import 'package:flutter_view_model/flutter_view_model.dart';

import 'pages/main/main_page.dart';
import 'pages/splash/splash_page.dart';
import 'pages/splash/splash_page_view_model.dart';
import 'pages/widgets/loading_overlay.dart';

void main() {
  runApp(const MainApp());
}

final routes = {
  '/main': (_) => const MainPage(),
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
      theme: ThemeData.light(useMaterial3: true).copyWith(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      builder: (context, child) =>
          LoadingOverlay(child: child ?? const Placeholder()),
      routes: routes,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
