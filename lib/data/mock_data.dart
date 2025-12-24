
import 'package:uuid/uuid.dart';
import 'models/sticker_pack.dart';
import 'models/user_profile.dart';
import '../core/services/storage_service.dart';

const uuid = Uuid();

class MockData {
  static UserProfile get currentUser => UserProfile(
    id: StorageService().userId,
    lifeContexts: ['Work', 'Coffee', 'Tired'],
    humorTone: 'Sarcastic',
    preferredMood: '🫠',
  );

  static String generateFunnyName() {
    final adjs = ['Silly', 'Grumpy', 'Lazy', 'Happy', 'Spicy', 'Salty', 'Dramatic', 'Chill'];
    final nouns = ['Panda', 'Cactus', 'Unicorn', 'Potato', 'Barista', 'Cat', 'Dinosaur', 'Alien'];
    final time = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return "${(adjs..shuffle()).first}_${(nouns..shuffle()).first}_$time";
  }

  // Fallback mocks if storage is empty, or just for testing
  static final StickerPack mondayMorningPack = StickerPack(
    id: uuid.v4(),
    title: 'Monday Morning',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    coverImageId: 's1',
    stickers: [
      StickerAsset(id: 's1', imageUrl: 'assets/images/mock/Monday_Facepalm.png', caption: 'Send help', type: StickerType.reaction),
      StickerAsset(id: 's2', imageUrl: 'assets/images/mock/Coffee_Sip.png', caption: 'Loading...', type: StickerType.reaction),
      StickerAsset(id: 's3', imageUrl: 'assets/images/mock/Blank_Stare.png', caption: 'In a meeting', type: StickerType.reaction),
    ],
  );

  static final StickerPack relationshipsPack = StickerPack(
    id: uuid.v4(),
    title: 'Relationships',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    coverImageId: 's4',
    stickers: [
      StickerAsset(id: 's4', imageUrl: 'assets/images/mock/Side_Eye.png', caption: 'Really?', type: StickerType.reaction),
      StickerAsset(id: 's5', imageUrl: 'assets/images/mock/Fake_Smile.png', caption: 'Fine.', type: StickerType.reaction),
      StickerAsset(id: 's6', imageUrl: 'assets/images/mock/Look_Away.png', caption: 'Seen.', type: StickerType.reaction),
    ],
  );

  static final StickerPack turkishInternetPack = StickerPack(
    id: uuid.v4(),
    title: 'Turkish Internet',
    createdAt: DateTime.now().subtract(const Duration(days: 0)),
    coverImageId: 's7',
    stickers: [
      StickerAsset(id: 's7', imageUrl: 'assets/images/mock/Hand_Gesture.png', caption: 'Aynen aynen', type: StickerType.meme),
      StickerAsset(id: 's8', imageUrl: 'assets/images/mock/Shocked_Face.png', caption: 'Oha', type: StickerType.reaction),
      StickerAsset(id: 's9', imageUrl: 'assets/images/mock/Laughing.png', caption: 'KSJDHFSK', type: StickerType.text),
      StickerAsset(id: 's7_2', imageUrl: 'assets/images/mock/Hand_Gesture.png', caption: 'Aynen aynen 2', type: StickerType.meme),
      StickerAsset(id: 's8_2', imageUrl: 'assets/images/mock/Shocked_Face.png', caption: 'Oha 2', type: StickerType.reaction),
      StickerAsset(id: 's9_2', imageUrl: 'assets/images/mock/Laughing.png', caption: 'KSJDHFSK 2', type: StickerType.text),
      StickerAsset(id: 's7_3', imageUrl: 'assets/images/mock/Hand_Gesture.png', caption: 'Aynen aynen 3', type: StickerType.meme),
      StickerAsset(id: 's8_3', imageUrl: 'assets/images/mock/Shocked_Face.png', caption: 'Oha 3', type: StickerType.reaction),
      StickerAsset(id: 's9_3', imageUrl: 'assets/images/mock/Laughing.png', caption: 'KSJDHFSK 3', type: StickerType.text),
      StickerAsset(id: 's7_4', imageUrl: 'assets/images/mock/Hand_Gesture.png', caption: 'Aynen aynen 4', type: StickerType.meme),
    ],
  );

  static List<StickerPack> getAllPacks() {
    final stored = StorageService().getPacks();
    return stored;
  }
  
  static void addPack(StickerPack pack) {
      StorageService().savePack(pack);
  }

  static void deletePack(String id) {
      StorageService().deletePack(id);
  }

  static List<StickerPack> get starterPacks => getAllPacks();

  static List<StickerPack> get communityPacks => [
    turkishInternetPack,
    mondayMorningPack,
    relationshipsPack,
    turkishInternetPack // Duplicate for scrolling
  ];
}
