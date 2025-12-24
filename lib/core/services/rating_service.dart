import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import '../theme/app_theme.dart';

/// Service to handle App Store rating prompts at optimal moments.
class RatingService {
  static const String _keyHasRated = 'meez_has_rated';
  static const String _keyFirstExportDone = 'meez_first_export_done';
  
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();
  
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }
  
  bool get hasRated => _prefs?.getBool(_keyHasRated) ?? false;
  bool get hasExportedBefore => _prefs?.getBool(_keyFirstExportDone) ?? false;
  
  /// Call this after successful WhatsApp export
  /// Returns true if rating popup should be shown
  Future<bool> onSuccessfulExport() async {
    await init();
    
    if (hasRated) return false;
    if (hasExportedBefore) return false;
    
    // Mark first export done
    await _prefs?.setBool(_keyFirstExportDone, true);
    return true; // Show rating popup
  }
  
  Future<void> markAsRated() async {
    await init();
    await _prefs?.setBool(_keyHasRated, true);
  }
  
  /// Show the rating popup with Apple-style design
  static Future<void> showRatingPopup(BuildContext context) async {
    final service = RatingService();
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _RatingPopup(),
    );
    
    if (result == true) {
      await service.markAsRated();
      
      // Try to open App Store review
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    }
  }
}

class _RatingPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            const Text(
              "Loving Meez?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              "Your stickers are on their way!\nMind leaving a quick rating?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rate Now button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Rate on App Store ⭐",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Maybe Later button
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Maybe Later",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
