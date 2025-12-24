
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/sticker_pack.dart';
import '../../data/mock_data.dart';

class StorageService {
  static const String keyPacks = 'meez_sticker_packs';
  static const String keyUserId = 'meez_user_id';
  static const String keyNickname = 'meez_nickname';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    
    // Ensure User Nickname Exists
    if (!_prefs!.containsKey(keyNickname)) {
        String newNickname = MockData.generateFunnyName(); // Use existing generator
        await _prefs!.setString(keyNickname, newNickname);
    }
    
    // Ensure User ID Exists
    if (!_prefs!.containsKey(keyUserId)) {
         // Simple unique ID for now
         String uid = "user_${DateTime.now().millisecondsSinceEpoch}";
         await _prefs!.setString(keyUserId, uid);
    }

    // Cleanup Mocks (Migration)
    // Removes persistent mocks if they exist specifically by Title
    List<StickerPack> current = getPacks();
    final mocks = ['Monday Morning', 'Relationships', 'Turkish Internet'];
    bool hasMocks = current.any((p) => mocks.contains(p.title));
    
    if (hasMocks) {
        current.removeWhere((p) => mocks.contains(p.title));
        await _savePacksList(current);
        print("Cleaned up mock packs.");
    }
  }
  
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // --- User Info ---
  String get nickname => _prefs?.getString(keyNickname) ?? 'Meez User';
  String get userId => _prefs?.getString(keyUserId) ?? 'unknown';

  // --- Sticker Packs ---
  
  /// Sync getter - returns empty if not initialized. Use getPacksAsync for guaranteed data.
  List<StickerPack> getPacks() {
    if (!_isInitialized || _prefs == null) {
      print("WARNING: StorageService.getPacks called before init. Returning empty.");
      return [];
    }
    return _getPacksInternal();
  }
  
  /// Async getter - awaits initialization first
  Future<List<StickerPack>> getPacksAsync() async {
    await _ensureInitialized();
    return _getPacksInternal();
  }
  
  List<StickerPack> _getPacksInternal() {
    final String? packsJson = _prefs?.getString(keyPacks);
    if (packsJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(packsJson);
      return decoded.map((item) => StickerPack.fromJson(item)).toList();
    } catch (e) {
      print("Error loading packs: $e");
      return [];
    }
  }

  Future<void> savePack(StickerPack pack) async {
    await _ensureInitialized();
    
    final List<StickerPack> currentPacks = getPacks();
    
    // Check if exists update, else insert at top
    final index = currentPacks.indexWhere((p) => p.id == pack.id);
    if (index != -1) {
      currentPacks[index] = pack;
    } else {
      currentPacks.insert(0, pack);
    }
    
    await _savePacksList(currentPacks);
    print("DEBUG: Pack saved to local storage: ${pack.title} (ID: ${pack.id})");
  }

  Future<void> deletePack(String packId) async {
    await _ensureInitialized();
    final List<StickerPack> currentPacks = getPacks();
    currentPacks.removeWhere((p) => p.id == packId);
    await _savePacksList(currentPacks);
  }

  Future<void> _savePacksList(List<StickerPack> packs) async {
    await _ensureInitialized();
    final String encoded = jsonEncode(packs.map((p) => p.toJson()).toList());
    await _prefs!.setString(keyPacks, encoded);
  }

  /// Clears all local data (stickers, user info, trial status)
  /// effectively resetting the app to a fresh install state.
  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _prefs!.clear();
    _isInitialized = false; // Force re-init on next app start
  }
}
