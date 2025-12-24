import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/sticker_pack.dart';

/// Service to manage favorite sticker packs
class FavoritesService {
  static const String _favoritesKey = 'favorite_pack_ids';
  static final FavoritesService _instance = FavoritesService._internal();
  
  factory FavoritesService() => _instance;
  FavoritesService._internal();
  
  Set<String> _favoriteIds = {};
  
  /// Initialize favorites from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_favoritesKey);
    if (saved != null) {
      _favoriteIds = saved.toSet();
    }
  }
  
  /// Check if a pack is favorited
  bool isFavorite(String packId) {
    return _favoriteIds.contains(packId);
  }
  
  /// Toggle favorite status
  Future<bool> toggleFavorite(String packId) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_favoriteIds.contains(packId)) {
      _favoriteIds.remove(packId);
    } else {
      _favoriteIds.add(packId);
    }
    
    await prefs.setStringList(_favoritesKey, _favoriteIds.toList());
    return _favoriteIds.contains(packId);
  }
  
  /// Get all favorite pack IDs
  Set<String> get favoriteIds => Set.from(_favoriteIds);
  
  /// Get count of favorites
  int get count => _favoriteIds.length;
}
