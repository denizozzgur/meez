
enum StickerType { reaction, meme, text, sticker }

class StickerAsset {
  final String id;
  final String imageUrl; // URL or local path
  final String caption;
  final StickerType type;
  final String theme;
  final Map<String, dynamic> metadata; // Coordinates, face config for re-generation

  StickerAsset({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.type,
    this.theme = 'general',
    this.metadata = const {},
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'caption': caption,
        'type': type.name, // Save enum name
        'theme': theme,
        'metadata': metadata,
      };

  factory StickerAsset.fromJson(Map<String, dynamic> json) {
    StickerType stickerType;
    try {
      stickerType = StickerType.values.byName(json['type'] ?? 'sticker');
    } catch (_) {
      stickerType = StickerType.sticker; // Default for unknown types
    }
    
    return StickerAsset(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      caption: json['caption'] ?? '',
      type: stickerType,
      theme: json['theme'] ?? 'general',
      metadata: json['metadata'] ?? {},
    );
  }
}

class StickerPack {
  final String id;
  final String title;
  final String author;
  final int likes;
  final DateTime createdAt;
  final List<StickerAsset> stickers;
  final String coverImageId; // ID of the sticker to use as cover
  final bool isFavorite;
  final bool isPublic;

  StickerPack({
    required this.id,
    required this.title,
    this.author = 'Anonymous',
    this.likes = 0,
    required this.createdAt,
    required this.stickers,
    required this.coverImageId,
    this.isFavorite = false,
    this.isPublic = true,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'likes': likes,
    'createdAt': createdAt.toIso8601String(),
    'stickers': stickers.map((s) => s.toJson()).toList(),
    'coverImageId': coverImageId,
    'isFavorite': isFavorite,
    'isPublic': isPublic,
  };

  factory StickerPack.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      // Prioritize created_at (snake_case, ISO format) over createdAt (may be text like "2h ago")
      final dateStr = json['created_at'] ?? json['createdAt'];
      if (dateStr != null && dateStr is String && dateStr.contains('-') && dateStr.contains('T')) {
        createdAt = DateTime.parse(dateStr);
      } else {
        // Fallback for non-ISO formats like "Just now", "2h ago"
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }
    
    return StickerPack(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      author: json['author'] ?? 'Anonymous',
      likes: json['likes'] ?? 0,
      createdAt: createdAt,
      stickers: (json['stickers'] as List?)?.map((i) => StickerAsset.fromJson(i)).toList() ?? [],
      coverImageId: json['coverImageId'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      isPublic: json['isPublic'] ?? true,
    );
  }

  // Helper to create valid empty state
  factory StickerPack.empty() {
    return StickerPack(
        id: '',
        title: 'Untitled Pack',
        author: 'Anonymous',
        likes: 0,
        createdAt: DateTime.now(),
        stickers: [],
        coverImageId: '',
        isPublic: true,
    );
  }
}
