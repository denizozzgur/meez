import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../main/main_screen.dart';

/// Modern celebratory screen with clean design.
/// Shown after trial starts successfully.
class TrialStartedScreen extends StatefulWidget {
  final int trialDays;
  final int freeGenerations;
  final VoidCallback onContinue;

  const TrialStartedScreen({
    super.key,
    this.trialDays = 3,
    this.freeGenerations = 5,
    required this.onContinue,
  });

  @override
  State<TrialStartedScreen> createState() => _TrialStartedScreenState();
}

class _TrialStartedScreenState extends State<TrialStartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _fadeController.forward();
    
    // Auto-continue after delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _navigateToHome();
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Sticker visual - showing actual sticker examples
                Container(
                  width: 200,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sticker 1 (left, tilted)
                      Positioned(
                        left: 0,
                        child: Transform.rotate(
                          angle: -0.15,
                          child: _buildStickerPreview('😎'),
                        ),
                      ),
                      // Sticker 2 (center, front)
                      Positioned(
                        child: _buildStickerPreview('🔥', isMain: true),
                      ),
                      // Sticker 3 (right, tilted)
                      Positioned(
                        right: 0,
                        child: Transform.rotate(
                          angle: 0.15,
                          child: _buildStickerPreview('💯'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Welcome to Meez Pro!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Your free trial is now active',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Clean info cards - NO emojis inside
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoCard(
                      value: '${widget.trialDays}',
                      label: 'Free Days',
                    ),
                    const SizedBox(width: 16),
                    _buildInfoCard(
                      value: '${widget.freeGenerations}',
                      label: 'Free Packs',
                    ),
                  ],
                ),
                
                const Spacer(flex: 2),
                
                // CTA button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Your First Sticker',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Helper text
                Text(
                  'Cancel anytime in Settings',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 13,
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickerPreview(String emoji, {bool isMain = false}) {
    final size = isMain ? 70.0 : 55.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: isMain ? 36 : 28),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String value,
    required String label,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
