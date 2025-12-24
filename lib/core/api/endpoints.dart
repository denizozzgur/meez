import 'dart:io';

class ApiConstants {
  // Dynamic base URL based on platform
  // Simulator can use localhost, physical device needs LAN IP
  static String get baseUrl {
    // For physical device testing: use your computer's LAN IP
    // For production: replace with your actual backend URL
    const String lanIP = '192.168.1.187';
    const String localHost = '127.0.0.1';
    
    // Check if running on physical device vs simulator
    // Platform.isIOS is true for both, but we can't easily detect simulator at runtime
    // So we'll use LAN IP which works for both (simulator can also reach LAN IP)
    return 'http://$lanIP:8000/api/v1';
  }

  // Auth
  static String get login => '$baseUrl/auth/login';

  // Upload
  static String get uploadImage => '$baseUrl/upload/image';

  // Generation
  static String get generatePack => '$baseUrl/generate/pack';
  static String get generateText => '$baseUrl/generate/text';
  static String generateStatus(String jobId) => '$baseUrl/generate/status/$jobId';

  // Trends
  static String get dailyTrends => '$baseUrl/trends/daily';
  static String get communityFeed => '$baseUrl/community/feed';
  static String likePack(String id) => '$baseUrl/community/like/$id';
  static String deletePack(String id) => '$baseUrl/community/pack/$id';

  // Export
  static String export(String platform) => '$baseUrl/export/$platform';
}
