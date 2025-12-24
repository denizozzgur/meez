import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeezApp());
}

class MeezApp extends StatelessWidget {
  const MeezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meez',
      debugShowCheckedModeBanner: false,
      theme: GlassTheme.theme,
      home: const SplashScreen(),
    );
  }
}



