import 'package:flutter/material.dart';
import 'dart:async';
import '../main/main_screen.dart';
import '../subscription/paywall_screen.dart';
import '../../core/services/subscription_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/favorites_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await StorageService().init();
      await SubscriptionService().init();
      await FavoritesService().init();
    } catch (e) {
      debugPrint("Init error: $e");
    }
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final dest = _subscriptionService.hasTrialStarted 
          ? const MainScreen() 
          : const PaywallScreen();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => dest),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 100,
              color: Color(0xFF38BDF8),
            ),
            const SizedBox(height: 24),
            Text(
              'Meez',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI Sticker Maker',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: Color(0xFF38BDF8),
            ),
          ],
        ),
      ),
    );
  }
}
