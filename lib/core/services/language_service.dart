import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing sticker caption language preferences.
/// Detects device language and allows user override.
class LanguageService {
  static const String _prefsKey = 'caption_language';
  static const String _captionsEnabledKey = 'captions_enabled';
  
  /// Supported language codes for caption translation
  static const List<String> supportedLanguages = ['en', 'tr', 'es', 'de', 'fr'];
  
  /// Get language name for display
  static String getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'tr': return 'Türkçe';
      case 'es': return 'Español';
      case 'de': return 'Deutsch';
      case 'fr': return 'Français';
      default: return 'English';
    }
  }
  
  /// Detect device language and return supported code or 'en'
  static String detectDeviceLanguage() {
    final String deviceLocale = Platform.localeName.split('_').first.toLowerCase();
    
    if (supportedLanguages.contains(deviceLocale)) {
      return deviceLocale;
    }
    
    // Fallback to English
    return 'en';
  }
  
  /// Get the user's preferred language (or 'auto' for device language)
  static Future<String> getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    
    if (saved == null || saved == 'auto') {
      return detectDeviceLanguage();
    }
    
    return saved;
  }
  
  /// Save user's language preference
  static Future<void> setPreferredLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, languageCode);
  }
  
  /// Check if captions are enabled
  static Future<bool> areCaptionsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_captionsEnabledKey) ?? true; // Enabled by default
  }
  
  /// Enable/disable captions
  static Future<void> setCaptionsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_captionsEnabledKey, enabled);
  }
  
  /// Get the effective language code for API calls
  /// Returns empty string if captions are disabled
  static Future<String> getEffectiveLanguage() async {
    final captionsEnabled = await areCaptionsEnabled();
    if (!captionsEnabled) {
      return ''; // Backend will skip caption rendering
    }
    return await getPreferredLanguage();
  }
}
