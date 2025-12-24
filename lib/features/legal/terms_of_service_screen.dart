import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/branded_background.dart';

/// Terms of Service page - scrollable legal text
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Terms of Service", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BrandedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Last updated: December 2025", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            const SizedBox(height: 24),
            
            _sectionTitle("1. Acceptance of Terms"),
            _paragraph("By downloading, installing, or using Meez (\"the App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, do not use the App."),

            _sectionTitle("2. Description of Service"),
            _paragraph("Meez is an AI-powered sticker creation app that allows you to:"),
            _simpleBullet("Create personalized stickers from photos using artificial intelligence"),
            _simpleBullet("Export stickers to messaging apps like WhatsApp"),
            _simpleBullet("Browse and share sticker packs in the Community Board"),
            _simpleBullet("Subscribe for unlimited sticker creation"),

            _sectionTitle("3. User Accounts"),
            _simpleBullet("You are responsible for maintaining the confidentiality of your device and account"),
            _simpleBullet("You agree to accept responsibility for all activities that occur under your account"),
            _simpleBullet("You must be at least 13 years old to use this service"),

            _sectionTitle("4. Subscription Terms"),
            _simpleBullet("Meez offers subscription plans for unlimited access"),
            _simpleBullet("Payment is charged to your Apple ID account"),
            _simpleBullet("Subscriptions auto-renew unless cancelled 24 hours before the end of the current period"),
            _simpleBullet("You can manage and cancel subscriptions in your App Store account settings"),
            _simpleBullet("No refunds are provided for partial subscription periods"),

            _sectionTitle("5. Free Trial"),
            _simpleBullet("New users may receive a free trial period"),
            _simpleBullet("The free trial includes limited sticker generations"),
            _simpleBullet("After the trial ends, a subscription is required for continued use"),
            _simpleBullet("If you cancel during the trial, you won't be charged"),

            _sectionTitle("6. User Content"),
            _paragraph("You retain ownership of images you upload. By using the App, you grant us a license to process your images for sticker creation. You are solely responsible for the content you create and share."),
            _paragraph("You must not upload content that:"),
            _simpleBullet("Infringes on intellectual property rights"),
            _simpleBullet("Contains illegal, harmful, or offensive material"),
            _simpleBullet("Violates the privacy of others"),
            _simpleBullet("Contains malware or viruses"),

            _sectionTitle("7. Community Guidelines"),
            _paragraph("When sharing to the Community Board:"),
            _simpleBullet("You agree that your content may be visible to all users"),
            _simpleBullet("You must not share offensive, illegal, or inappropriate content"),
            _simpleBullet("We reserve the right to remove any content without notice"),
            _simpleBullet("Repeated violations may result in account termination"),

            _sectionTitle("8. Intellectual Property"),
            _simpleBullet("The App, including its design, features, and content, is protected by copyright and other intellectual property laws"),
            _simpleBullet("You may not copy, modify, or distribute the App without permission"),
            _simpleBullet("AI-generated stickers you create are yours to use personally"),

            _sectionTitle("9. Limitation of Liability"),
            _simpleBullet("The App is provided \"as is\" without warranties of any kind"),
            _simpleBullet("We are not liable for any indirect, incidental, or consequential damages"),
            _simpleBullet("Our total liability shall not exceed the amount you paid for the service in the past 12 months"),

            _sectionTitle("10. Termination"),
            _simpleBullet("We may terminate or suspend your access at any time for violations of these terms"),
            _simpleBullet("You may stop using the App at any time"),
            _simpleBullet("Upon termination, your right to use the App ceases immediately"),

            _sectionTitle("11. Changes to Terms"),
            _paragraph("We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the new terms."),

            _sectionTitle("12. Contact"),
            _paragraph("For questions about these Terms of Service:"),
            const SizedBox(height: 8),
            Text("denizozzgur@gmail.com", style: TextStyle(color: AppColors.accentBlue, fontSize: 14)),
            
            const SizedBox(height: 48),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _simpleBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
