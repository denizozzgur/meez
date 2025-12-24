import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Haptic feedback utility for premium feel
class HapticHelper {
  /// Light tap feedback (for buttons, toggles)
  static void lightTap() {
    HapticFeedback.lightImpact();
  }
  
  /// Medium tap feedback (for important actions)
  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy tap feedback (for destructive actions, confirmations)
  static void heavyTap() {
    HapticFeedback.heavyImpact();
  }
  
  /// Selection feedback (for picker changes)
  static void selection() {
    HapticFeedback.selectionClick();
  }
  
  /// Success feedback (for completed actions)
  static void success() {
    HapticFeedback.mediumImpact();
  }
  
  /// Error feedback (for failed actions)
  static void error() {
    HapticFeedback.heavyImpact();
  }
}

/// Rate app prompt manager
class RateAppManager {
  static const String _packCountKey = 'pack_count';
  static const String _hasRatedKey = 'has_rated';
  static const String _lastPromptKey = 'last_rate_prompt';
  static const int _promptThreshold = 3; // Show after 3 packs created
  
  /// Increment pack count when user creates a pack
  static Future<void> onPackCreated() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_packCountKey) ?? 0;
    await prefs.setInt(_packCountKey, count + 1);
  }
  
  /// Check if we should show the rate prompt
  static Future<bool> shouldShowRatePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Already rated? Don't show
    if (prefs.getBool(_hasRatedKey) == true) return false;
    
    // Check pack count
    int count = prefs.getInt(_packCountKey) ?? 0;
    if (count < _promptThreshold) return false;
    
    // Check if we prompted recently (within 7 days)
    int? lastPrompt = prefs.getInt(_lastPromptKey);
    if (lastPrompt != null) {
      int daysSincePrompt = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(lastPrompt)
      ).inDays;
      if (daysSincePrompt < 7) return false;
    }
    
    return true;
  }
  
  /// Mark that we showed the prompt
  static Future<void> markPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Mark that user rated the app
  static Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
  }
  
  /// Show the rate app dialog
  static Future<void> showRateDialog(BuildContext context) async {
    await markPromptShown();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Text("🎉", style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              "Enjoying Meez?",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          "You've created ${ _promptThreshold}+ sticker packs! If you're having fun, would you mind leaving a quick review? It really helps!",
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              // Rate Now button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticHelper.success();
                    markAsRated();
                    Navigator.pop(context);
                    // TODO: Open App Store review page
                    // StoreRedirect.redirect();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("⭐ Rate Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              // Maybe Later
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Maybe Later", style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Share helper for social media
class SocialShareHelper {
  /// Share sticker pack to Instagram Stories
  static Future<void> shareToInstagram(String imageBase64, String caption) async {
    // For now, use system share sheet
    // Full Instagram Stories integration requires additional setup
    HapticHelper.lightTap();
    // Will be implemented with share_plus
  }
}
