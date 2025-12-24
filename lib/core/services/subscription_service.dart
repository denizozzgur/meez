import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RevenueCat-powered subscription service.
/// 
/// Handles:
/// - Subscription purchases (iOS + Android)
/// - Trial logic (local, 3 days OR 5 generations)
/// - Entitlement checking
/// 
/// Setup:
/// 1. Create account at revenuecat.com
/// 2. Add your API keys below
/// 3. Configure products in RevenueCat dashboard
class SubscriptionService {
  // RevenueCat API Keys
  static const String _iosApiKey = 'appl_MTjnATBlmICSYSeYbMmYWzKSVXM';
  static const String _androidApiKey = 'YOUR_ANDROID_API_KEY_HERE'; // Add when you set up Android
  
  // Entitlement ID - must match RevenueCat dashboard
  static const String _entitlementId = 'Meez Pro';
  
  // Trial config (local tracking)
  static const String _keyTrialStartDate = 'meez_trial_start';
  static const String _keyTrialPlan = 'meez_trial_plan';
  static const String _keyGenerationCount = 'meez_generation_count';
  static const String _keyTrialStarted = 'meez_trial_started';
  
  static const int maxFreeGenerations = 5;
  static const int trialDurationDays = 3;
  
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;

  /// Initialize RevenueCat SDK
  Future<void> init() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    try {
      // Configure RevenueCat
      final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
      
      if (apiKey.contains('YOUR_')) {
        debugPrint('⚠️ RevenueCat API key not configured! Using mock mode.');
        _isInitialized = true;
        return;
      }
      await Purchases.configure(PurchasesConfiguration(apiKey));
      
      // Get initial customer info and offerings
      await fetchOfferings();
      
      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo = info;
      });
      
      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('❌ RevenueCat init error: $e');
      _isInitialized = true; // Continue with local-only mode
    }
  }

  /// Manually fetch offerings (retry mechanism)
  Future<void> fetchOfferings() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _offerings = await Purchases.getOfferings();
      
      // Debug: log available offerings
      debugPrint('📦 RevenueCat offerings loaded:');
      debugPrint('   All offerings: ${_offerings?.all.keys.toList()}');
      debugPrint('   Current offering: ${_offerings?.current?.identifier}');
      debugPrint('   Target offering ($_offeringId): ${_offerings?.getOffering(_offeringId)?.identifier}');
      debugPrint('   Monthly package: ${monthlyPackage?.storeProduct.identifier}');
      debugPrint('   Yearly package: ${yearlyPackage?.storeProduct.identifier}');
    } catch (e) {
      debugPrint('❌ RevenueCat fetch error: $e');
    }
  }

  // ============================================================
  // SUBSCRIPTION STATUS
  // ============================================================
  
  /// Check if user has active "pro" entitlement
  bool get isSubscribed {
    if (_customerInfo == null) return false;
    return _customerInfo!.entitlements.active.containsKey(_entitlementId);
  }

  /// Get current offerings (products) from RevenueCat
  Offerings? get offerings => _offerings;

  // Custom offering identifier from RevenueCat dashboard
  static const String _offeringId = 'ofrng1265619eba';

  /// Get the offering by ID, fallback to current/default
  Offering? get currentOffering => 
      _offerings?.getOffering(_offeringId) ?? _offerings?.current;

  /// Get monthly package
  Package? get monthlyPackage => currentOffering?.monthly;

  /// Get yearly package
  Package? get yearlyPackage => currentOffering?.annual;

  /// Get subscription expiration/renewal date
  DateTime? get subscriptionExpirationDate {
    if (_customerInfo == null) return null;
    final entitlement = _customerInfo!.entitlements.active[_entitlementId];
    if (entitlement == null) return null;
    final dateStr = entitlement.expirationDate;
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Get the active product identifier (e.g., "meez.pro.monthly")
  String? get activeProductId {
    if (_customerInfo == null) return null;
    final entitlement = _customerInfo!.entitlements.active[_entitlementId];
    return entitlement?.productIdentifier;
  }

  /// Get formatted plan name for display ("Monthly Pro" or "Yearly Pro")
  String get activePlanName {
    final productId = activeProductId;
    if (productId == null) return 'Meez Pro';
    if (productId.contains('yearly') || productId.contains('annual')) {
      return 'Yearly Pro';
    } else if (productId.contains('monthly')) {
      return 'Monthly Pro';
    }
    return 'Meez Pro';
  }

  /// Get formatted renewal date string
  String get renewalDateFormatted {
    final date = subscriptionExpirationDate;
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return 'Renews ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ============================================================
  // TRIAL LOGIC (Local, independent of RevenueCat)
  // ============================================================

  bool get hasTrialStarted => _prefs?.getBool(_keyTrialStarted) ?? false;

  String? get trialPlan => _prefs?.getString(_keyTrialPlan);

  Future<void> startTrial(String planId) async {
    if (_prefs == null) return;
    
    // Always reset count when starting/restarting trial
    await _prefs!.setBool(_keyTrialStarted, true);
    await _prefs!.setString(_keyTrialPlan, planId);
    await _prefs!.setString(_keyTrialStartDate, DateTime.now().toIso8601String());
    await _prefs!.setInt(_keyGenerationCount, 0);
    
    debugPrint('🎉 Trial started! Plan: $planId, Generations reset to 0, Max: $maxFreeGenerations');
  }
  
  /// Check and log current trial status (for debugging)
  void debugTrialStatus() {
    debugPrint('===== Trial Status =====');
    debugPrint('Trial Started: $hasTrialStarted');
    debugPrint('Is Subscribed: $isSubscribed');
    debugPrint('Is Trial Active: $isTrialActive');
    debugPrint('Generation Count: $generationCount / $maxFreeGenerations');
    debugPrint('Can Generate: $canGenerate');
    debugPrint('========================');
  }

  bool get isTrialActive {
    if (!hasTrialStarted) return false;
    if (isSubscribed) return false;
    return isWithinTrialDays && hasRemainingGenerations;
  }

  bool get isWithinTrialDays {
    final startDateStr = _prefs?.getString(_keyTrialStartDate);
    if (startDateStr == null) return false;
    
    final startDate = DateTime.parse(startDateStr);
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    return daysSinceStart < trialDurationDays;
  }

  bool get hasRemainingGenerations {
    return generationCount < maxFreeGenerations;
  }

  int get remainingTrialDays {
    final startDateStr = _prefs?.getString(_keyTrialStartDate);
    if (startDateStr == null) return trialDurationDays;
    
    final startDate = DateTime.parse(startDateStr);
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    return (trialDurationDays - daysSinceStart).clamp(0, trialDurationDays);
  }

  int get generationCount => _prefs?.getInt(_keyGenerationCount) ?? 0;

  int get remainingFreeGenerations => 
      (maxFreeGenerations - generationCount).clamp(0, maxFreeGenerations);

  bool get canGenerate {
    if (isSubscribed) return true;
    return isTrialActive;
  }

  Future<void> incrementGenerationCount() async {
    if (_prefs == null) return;
    final current = generationCount;
    final newCount = current + 1;
    await _prefs!.setInt(_keyGenerationCount, newCount);
    debugPrint('🎯 Generation count: $current -> $newCount (max: $maxFreeGenerations)');
  }
  
  /// Reset generation count for trial (for testing/debugging)
  Future<void> resetTrialGenerations() async {
    if (_prefs == null) return;
    await _prefs!.setInt(_keyGenerationCount, 0);
    debugPrint('🔄 Trial generations reset to 0');
  }

  // ============================================================
  // PURCHASES
  // ============================================================

  /// Purchase a package
  Future<bool> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      _customerInfo = result;
      return isSubscribed;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Purchase cancelled by user');
      } else {
        debugPrint('Purchase error: $e');
      }
      return false;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      return isSubscribed;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }

  /// Log in user (for cross-device sync)
  Future<void> login(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      _customerInfo = result.customerInfo;
    } catch (e) {
      debugPrint('Login error: $e');
    }
  }

  /// Log out user
  Future<void> logout() async {
    try {
      _customerInfo = await Purchases.logOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  void dispose() {
    // No cleanup needed for RevenueCat
  }
}
