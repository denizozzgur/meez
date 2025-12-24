import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/subscription_service.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';
import '../../shared/widgets/branded_background.dart';
import 'paywall_screen.dart';
import 'trial_ended_screen.dart';
import 'package:viral_meme_app/features/onboarding/splash_screen.dart';
import '../../core/services/storage_service.dart';

/// Subscription management screen accessible from settings/profile.
/// Shows current subscription status and provides management options.
class SubscriptionSettingsScreen extends StatefulWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  State<SubscriptionSettingsScreen> createState() => _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState extends State<SubscriptionSettingsScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isRestoring = false;

  String get _statusText {
    if (_subscriptionService.isSubscribed) {
      return 'Active Subscription';
    } else if (_subscriptionService.isTrialActive) {
      return 'Free Trial';
    } else if (_subscriptionService.hasTrialStarted) {
      return 'Trial Ended';
    } else {
      return 'Not Subscribed';
    }
  }

  Color get _statusColor {
    if (_subscriptionService.isSubscribed) {
      return AppColors.accentGreen;
    } else if (_subscriptionService.isTrialActive) {
      return AppColors.accentBlue;
    } else {
      return Colors.orange;
    }
  }

  Future<void> _openSubscriptionManagement() async {
    // If subscribed, open App Store subscriptions
    if (_subscriptionService.isSubscribed) {
      final url = Uri.parse('https://apps.apple.com/account/subscriptions');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return;
    }
    
    // If trial is active, also go to App Store (they can manage)
    if (_subscriptionService.isTrialActive) {
      final url = Uri.parse('https://apps.apple.com/account/subscriptions');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return;
    }
    
    // Trial has ended - show subscription screen (NOT paywall with free trial)
    if (_subscriptionService.hasTrialStarted) {
      await TrialEndedScreen.show(context);
      setState(() {}); // Refresh UI in case they subscribed
      return;
    }
    
    // Never started trial - show paywall with trial option
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
  }

  Future<void> _restorePurchases() async {
    setState(() => _isRestoring = true);
    
    final restored = await _subscriptionService.restorePurchases();
    
    if (mounted) {
      setState(() => _isRestoring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(restored 
            ? 'Subscription restored successfully!' 
            : 'No purchases to restore'
          ),
        ),
      );
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete All Data?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete all your stickers, history, and reset the app as if it is brand new. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Deep Navy to match gradient start
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BrandedBackground(
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentBlue.withOpacity(0.2),
                      AppColors.accentPurple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _statusText,
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Meez Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_subscriptionService.isTrialActive) ...[
                      Text(
                        '${_subscriptionService.remainingTrialDays} days left • ${_subscriptionService.remainingFreeGenerations} generates left',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ] else if (_subscriptionService.isSubscribed) ...[
                      Text(
                        _subscriptionService.activePlanName,
                        style: TextStyle(
                          color: AppColors.accentGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subscriptionService.renewalDateFormatted.isNotEmpty 
                            ? _subscriptionService.renewalDateFormatted
                            : 'Unlimited sticker generation',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Actions
              Text(
                'Manage',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              // Manage Subscription (opens App Store OR Paywall)
              _buildActionTile(
                icon: Icons.settings,
                title: 'Manage Subscription',
                subtitle: _subscriptionService.isSubscribed || _subscriptionService.isTrialActive 
                    ? 'Change plan or cancel in App Store'
                    : 'View plans and subscribe', // Changed subtitle
                onTap: _openSubscriptionManagement,
              ),
              
              const SizedBox(height: 8),
              
              // Restore Purchases
              _buildActionTile(
                icon: Icons.refresh,
                title: 'Restore Purchases',
                subtitle: 'Restore previous subscription',
                onTap: _isRestoring ? null : _restorePurchases,
                trailing: _isRestoring 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : null,
              ),

              const SizedBox(height: 8),

              // Delete All Data (Danger Zone)
              _buildActionTile(
                icon: Icons.delete_forever,
                title: 'Delete All Data',
                subtitle: 'Clear all stickers and reset app',
                onTap: _deleteAllData,
                iconColor: Colors.redAccent,
                titleColor: Colors.redAccent,
              ),
              
              const Spacer(),
              
              // Legal links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())
                    ),
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('•', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())
                    ),
                    child: Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.accentBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.accentBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
