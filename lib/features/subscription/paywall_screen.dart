import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/subscription_service.dart';
import '../main/main_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';
import 'trial_started_screen.dart';
import '../../shared/widgets/branded_background.dart';

/// Initial paywall - user must select plan to start free trial.
/// Uses Apple's introductory offer (free trial) which collects payment info upfront.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String _selectedPlan = 'yearly';

  void _startTrial() async {
    // Guard: If trial was already used, don't allow restart
    if (_subscriptionService.hasTrialStarted && !_subscriptionService.isTrialActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Free trial already used. Please subscribe to continue.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Get the selected package from RevenueCat
      final package = _selectedPlan == 'yearly' 
          ? _subscriptionService.yearlyPackage 
          : _subscriptionService.monthlyPackage;
      
      if (package != null) {
        // Trigger actual Apple purchase with free trial
        // This will show Apple's payment sheet and collect payment info
        final success = await _subscriptionService.purchase(package);
        
        if (success && mounted) {
          // Also mark local trial for backup tracking
          await _subscriptionService.startTrial(_selectedPlan);
          _navigateToTrialStarted();
        } else if (mounted) {
          setState(() => _isLoading = false);
          // Purchase was cancelled or failed - stay on paywall
        }
      } else {
        // RevenueCat not configured - fall back to local trial only
        await _subscriptionService.startTrial(_selectedPlan);
        if (mounted) _navigateToTrialStarted();
      }
    } catch (e) {
      debugPrint('Trial start error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  void _navigateToTrialStarted() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => TrialStartedScreen(
          trialDays: SubscriptionService.trialDurationDays,
          freeGenerations: SubscriptionService.maxFreeGenerations,
          onContinue: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          },
        ),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _handleRestore() async {
    setState(() => _isLoading = true);
    final restored = await _subscriptionService.restorePurchases();
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (restored) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No purchases to restore')),
        );
      }
    }
  }

  // Get price from RevenueCat or use fallback
  String _getMonthlyPrice() {
    final pkg = _subscriptionService.monthlyPackage;
    return pkg?.storeProduct.priceString ?? '\$3.99';
  }

  String _getYearlyPrice() {
    final pkg = _subscriptionService.yearlyPackage;
    return pkg?.storeProduct.priceString ?? '\$24.99';
  }

  // Get intro offer info (free trial)
  String? _getIntroOfferText(String planId) {
    final pkg = planId == 'yearly' 
        ? _subscriptionService.yearlyPackage 
        : _subscriptionService.monthlyPackage;
    
    final intro = pkg?.storeProduct.introductoryPrice;
    if (intro != null && intro.price == 0) {
      // Free trial
      final period = intro.periodNumberOfUnits;
      final unit = intro.periodUnit.name.toLowerCase();
      return '$period $unit free trial';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BrandedBackground(
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Sticker banner - showing actual sticker examples
              SizedBox(
                width: 200,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left sticker
                    Positioned(
                      left: 10,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: _buildStickerPreview('🔥'),
                      ),
                    ),
                    // Center sticker (front)
                    Positioned(
                      child: _buildStickerPreview('😂', isMain: true),
                    ),
                    // Right sticker
                    Positioned(
                      right: 10,
                      child: Transform.rotate(
                        angle: 0.12,
                        child: _buildStickerPreview('💯'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Create Unlimited\nStickers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Start with a free trial',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Plan cards - with dynamic pricing
              _buildPlanCard(
                id: 'yearly',
                title: 'Yearly',
                price: _getYearlyPrice(),
                period: '/year',
                badge: 'Best Value',
                subtext: _getIntroOfferText('yearly') ?? 'Save 50%',
              ),
              
              const SizedBox(height: 10),
              
              _buildPlanCard(
                id: 'monthly',
                title: 'Monthly',
                price: _getMonthlyPrice(),
                period: '/month',
                subtext: _getIntroOfferText('monthly'),
              ),
              
              const Spacer(flex: 1),
              
              // Trial info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.white.withOpacity(0.5), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '3 days free, then auto-renews',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startTrial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Start Free Trial',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Cancel anytime
              Text(
                'Cancel anytime. No charge until trial ends.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Restore purchases
              TextButton(
                onPressed: _isLoading ? null : _handleRestore,
                child: Text(
                  'Restore Purchases',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ),
              
              // Legal links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, decoration: TextDecoration.underline),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
                    child: Text(
                      'Terms of Service',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required String period,
    String? badge,
    String? subtext,
  }) {
    final isSelected = _selectedPlan == id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accentBlue.withOpacity(0.12) 
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 20,
              height: 20,
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
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 14),
            
            // Title & badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtext != null)
                    Text(
                      subtext,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerPreview(String emoji, {bool isMain = false}) {
    final size = isMain ? 60.0 : 48.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: isMain ? 30 : 24),
        ),
      ),
    );
  }
}
