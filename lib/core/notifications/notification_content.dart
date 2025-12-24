
/// Defines the structure and content for smart notifications
class NotificationItem {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final int? weekday; // 1 = Monday, 7 = Sunday
  final int hour;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.weekday,
    required this.hour,
  });
}

class NotificationContent {
  // IDs start from 100 to avoid conflict with other potential notifications
  
  static const List<NotificationItem> timeBased = [
    NotificationItem(
      id: 101,
      weekday: 1, // Monday
      hour: 9, 
      title: "Monday Mood ☕️",
      body: "Pazartesi sendromunu sticker'a çevir. Hemen oluştur!",
      payload: "theme_exhausted",
    ),
    NotificationItem(
      id: 102,
      weekday: 5, // Friday
      hour: 18,
      title: "Weekend Mode 🎉",
      body: "Hafta bitti! Party ve Slay stickerlarını hazırla.",
      payload: "theme_party",
    ),
    NotificationItem(
      id: 103,
      weekday: 7, // Sunday
      hour: 21,
      title: "Sunday Anxiety 😅",
      body: "Yarına hazır mısın? Durumu kabullen ve stickerını yap.",
      payload: "theme_resigned",
    ),
  ];

  static const List<NotificationItem> inspiration = [
    NotificationItem(
      id: 201,
      hour: 19, // Default evening inspiration
      title: "Günün Trendi: Side Eye 👀",
      body: "Tam o anlık bir sticker. Şimdi oluştur.",
      payload: "theme_sideeye",
    ),
    NotificationItem(
      id: 202,
      hour: 12, // Lunch time
      title: "Rizz Seviyen Kaç? 😏",
      body: "Flörtöz bir sticker seti oluşturmak için tıkla.",
      payload: "theme_rizz",
    ),
    NotificationItem(
      id: 203,
      hour: 15, // Afternoon slump
      title: "Modun mu düştü? 😴",
      body: "Kendini 'Dead' stickerı ile ifade et.",
      payload: "theme_dead",
    ),
    NotificationItem(
      id: 204,
      hour: 20,
      title: "Mood: Main Character ✨",
      body: "Kendi hikayenin başrolü sensin. Stickerını yap.",
      payload: "theme_main_character",
    ),
  ];
  
  static const NotificationItem reactivation = NotificationItem(
    id: 999,
    hour: 18,
    title: "Seni AI ile çizdik... 🤖",
    body: "Şaka şaka 😄 Ama çok havalı bir stickerın olabilir. Denemek ister misin?",
    payload: "open_app",
  );
}
