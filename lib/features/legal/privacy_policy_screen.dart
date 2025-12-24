import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/branded_background.dart';

/// Privacy Policy page - scrollable legal text
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Privacy Policy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            
            _sectionTitle("1. Information We Collect"),
            _paragraph("When you use Meez, we collect minimal information necessary to provide our services:"),
            _bulletPoint("Images you upload", "Photos you choose to convert into stickers are processed by our AI systems. We do not permanently store your original images."),
            _bulletPoint("Generated stickers", "Stickers you create may be stored temporarily to enable sharing and export features."),
            _bulletPoint("Usage data", "We collect anonymous usage statistics to improve our app, such as feature usage frequency and crash reports."),
            _bulletPoint("Device information", "Basic device identifiers for app functionality and analytics."),

            _sectionTitle("2. How We Use Your Information"),
            _paragraph("We use collected information to:"),
            _simpleBullet("Generate AI-powered stickers from your photos"),
            _simpleBullet("Enable sticker sharing to WhatsApp and other platforms"),
            _simpleBullet("Improve app performance and user experience"),
            _simpleBullet("Provide customer support"),
            _simpleBullet("Process subscription payments (handled by Apple)"),

            _sectionTitle("3. Data Sharing"),
            _paragraph("We do not sell your personal data. We may share data with:"),
            _bulletPoint("AI Service Providers", "Your images are processed by third-party AI services to generate stickers. These services are bound by strict data protection agreements."),
            _bulletPoint("Analytics Providers", "Anonymous usage data helps us improve the app."),
            _bulletPoint("Payment Processors", "Apple handles all subscription payments. We never see your payment details."),

            _sectionTitle("4. Community Content"),
            _paragraph("When you share sticker packs to the Community Board:"),
            _simpleBullet("Your pack becomes publicly visible to other users"),
            _simpleBullet("An anonymous username is generated for display"),
            _simpleBullet("You can report inappropriate content using the report button"),
            _simpleBullet("We reserve the right to remove content that violates our guidelines"),

            _sectionTitle("5. Data Retention"),
            _simpleBullet("Uploaded images are processed and deleted within 24 hours"),
            _simpleBullet("Generated stickers are retained while your account is active"),
            _simpleBullet("You can delete your packs from the History tab at any time"),
            _simpleBullet("Community content may be retained for moderation purposes"),

            _sectionTitle("6. Your Rights"),
            _paragraph("You have the right to:"),
            _simpleBullet("Access your data"),
            _simpleBullet("Delete your sticker packs"),
            _simpleBullet("Opt out of analytics (contact support)"),
            _simpleBullet("Request account deletion"),

            _sectionTitle("7. Children's Privacy"),
            _paragraph("Meez is not intended for children under 13. We do not knowingly collect data from children under 13. If you believe a child has provided us with personal information, please contact us."),

            _sectionTitle("8. Security"),
            _paragraph("We implement industry-standard security measures to protect your data. However, no method of transmission over the internet is 100% secure."),

            _sectionTitle("9. Changes to This Policy"),
            _paragraph("We may update this policy from time to time. We will notify you of significant changes through the app."),

            _sectionTitle("10. Contact Us"),
            _paragraph("If you have questions about this Privacy Policy, please contact us at:"),
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

  Widget _bulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, height: 1.6),
                  ),
                  TextSpan(
                    text: description,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
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
