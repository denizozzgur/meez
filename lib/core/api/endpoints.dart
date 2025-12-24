import 'dart:io';

class ApiConstants {
  // Dynamic base URL based on platform
  // Simulator can use localhost, physical device needs LAN IP
  static String get baseUrl {
    // Production Railway URL
    const String productionUrl = 'https://meez-production.up.railway.app/api/v1';
    
    // For local development, uncomment below and comment production:
    // const String lanIP = '192.168.1.187';
    // return 'http://$lanIP:8000/api/v1';
    
    return productionUrl;
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
