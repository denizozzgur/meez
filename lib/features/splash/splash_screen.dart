import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../main/main_screen.dart';
import '../subscription/paywall_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/subscription_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/favorites_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateController;
  final SubscriptionService _subscriptionService = SubscriptionService();

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Initialize and navigate
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    try {
      final storage = StorageService();
      await storage.init();
      await Future.wait([
        FavoritesService().init(),
        SubscriptionService().init(),
      ]);
    } catch (e) {
      debugPrint("Init error: $e");
    }
    
    // Wait for splash to show
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Check subscription status - go to paywall if trial not started
      final destination = _subscriptionService.hasTrialStarted 
          ? const MainScreen() 
          : const PaywallScreen();
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Color(0xFF020617)],
                ),
              ),
            ),
          ),
          
          // Animated orbs
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    50 * math.cos(_rotateController.value * 2 * math.pi),
                    50 * math.sin(_rotateController.value * 2 * math.pi),
                  ),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentPurple.withOpacity(0.15),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -50,
            left: -50,
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    -30 * math.cos(_rotateController.value * 2 * math.pi),
                    30 * math.sin(_rotateController.value * 2 * math.pi),
                  ),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentBlue.withOpacity(0.15),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withOpacity(0.2),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.auto_awesome,
                        size: 120,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    'AI Sticker Maker',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 80),
                
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
