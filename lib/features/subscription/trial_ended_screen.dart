import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/subscription_service.dart';
import '../../core/services/storage_service.dart';
import 'package:viral_meme_app/features/onboarding/splash_screen.dart';
/// Blocking subscription screen shown when trial ends.
/// User must subscribe to continue - cannot be dismissed.
/// Uses RevenueCat for purchases.
class TrialEndedScreen extends StatefulWidget {
  const TrialEndedScreen({super.key});

  /// Show as blocking modal - cannot be dismissed without subscribing
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => const TrialEndedScreen(),
    );
    return result ?? false;
  }

  @override
  State<TrialEndedScreen> createState() => _TrialEndedScreenState();
}

class _TrialEndedScreenState extends State<TrialEndedScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String _selectedPlan = 'yearly';

  void _handleSubscribe() async {
    setState(() => _isLoading = true);
    
    // Retry fetching offerings if null
    if (_subscriptionService.yearlyPackage == null) {
      await _subscriptionService.fetchOfferings();
    }
    
    final package = _selectedPlan == 'yearly' 
        ? _subscriptionService.yearlyPackage 
        : _subscriptionService.monthlyPackage;
    
    if (package != null) {
      final success = await _subscriptionService.purchase(package);
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      // Fallback: If RevenueCat not configured, just close
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to connect to store. Please try again later.')),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleRestore() async {
    setState(() => _isLoading = true);
    final restored = await _subscriptionService.restorePurchases();
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (restored) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No purchases to restore')),
        );
      }
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Reset App?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete all your stickers and reset the app. Use this if you are stuck or want to start over.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await StorageService().clearAllData();
      
      // Navigate to Splash to restart flow
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  // Get price from RevenueCat or use fallback
  String _getMonthlyPrice() {
    final pkg = _subscriptionService.monthlyPackage;
    return pkg?.storeProduct.priceString ?? '\$3.99/month';
  }

  String _getYearlyPrice() {
    final pkg = _subscriptionService.yearlyPackage;
    return pkg?.storeProduct.priceString ?? '\$24.99/year';
  }
  
  // Re-implementing build to add delete button
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji header
            const Text('✨', style: TextStyle(fontSize: 48)),
            
            const SizedBox(height: 16),
            
            // Title - encouraging
            const Text(
              'Loving Your Stickers?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Message
            Text(
              'Your free trial has ended.\nSubscribe to keep creating!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Plans with dynamic pricing
            _buildPlanOption(
              id: 'yearly',
              title: 'Yearly',
              price: _getYearlyPrice(),
              badge: 'Best Value',
            ),
            const SizedBox(height: 8),
            _buildPlanOption(
              id: 'monthly',
              title: 'Monthly',
              price: _getMonthlyPrice(),
            ),
            
            const SizedBox(height: 20),
            
            // CTA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Start Subscription',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Restore & Reset Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : _handleRestore,
                  child: Text(
                    'Restore',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ),
                Text('•', style: TextStyle(color: Colors.white.withOpacity(0.2))),
                TextButton(
                  onPressed: _isLoading ? null : _deleteAllData,
                  child: Text(
                    'Reset App',
                    style: TextStyle(
                      color: Colors.redAccent.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption({
    required String id,
    required String title,
    required String price,
    String? badge,
  }) {
    final isSelected = _selectedPlan == id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accentBlue.withOpacity(0.12) 
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accentBlue : Colors.white.withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 12),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            
            const Spacer(),
            
            // Price
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
