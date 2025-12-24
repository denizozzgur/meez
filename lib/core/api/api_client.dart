
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'endpoints.dart';

import 'package:viral_meme_app/data/models/sticker_pack.dart';

class ApiClient {
  final String _baseUrl;
  
  // Use localhost for emulator/simulator
  // Android Emulator: 10.0.2.2
  // iOS Simulator: 127.0.0.1
  // Physical Device: Use your computer's LAN IP
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? _getDefaultBaseUrl();
  
  static String _getDefaultBaseUrl() {
    // For physical device testing, change this to your computer's IP
    // Production: Use your actual backend URL
    const bool isPhysicalDevice = true; // Set to false for simulator
    if (isPhysicalDevice) {
      return 'http://192.168.1.187:8000'; // Your computer's LAN IP
    }
    return 'http://127.0.0.1:8000';
  }

  Future<Map<String, dynamic>> login() async {
    try {
      final response = await http.post(Uri.parse(ApiConstants.login));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Login failed');
    } catch (e) {
      print("API Error: $e");
      // Fallback for demo if offline
      return {"token": "offline_token", "user_id": "offline_user"};
    }
  }

  Future<String> submitGenerationJob(File imageFile, String userId, String tone, {String style = "random"}) async {
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.generatePack));
    request.fields['user_id'] = userId;
    request.fields['humor_tone'] = tone;
    request.fields['style'] = style;
    
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      final stream = await request.send();
      final response = await http.Response.fromStream(stream);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['job_id'];
      }
      throw Exception('Upload failed: ${response.statusCode}');
    } catch (e) {
      print("API Error: $e");
      // Return fake job ID for demo
      await Future.delayed(const Duration(seconds: 1));
      return "demo_job_${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  Future<String> submitTextGenerationJob(String userInput, {String tone = "random", String style = "random"}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.generateText),
        body: {
          'user_input': userInput,
          'humor_tone': tone,
          'style': style,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['job_id'];
      }
      throw Exception('Request failed: ${response.statusCode}');
    } catch (e) {
      print("API Error: $e");
      await Future.delayed(const Duration(seconds: 1));
      return "demo_job_${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  Future<Map<String, dynamic>> checkJobStatus(String jobId) async {
    if (jobId.startsWith("demo_job")) {
      return _mockStatusCheck(jobId);
    }

    try {
      final response = await http.get(Uri.parse(ApiConstants.generateStatus(jobId)));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Status check failed');
    } catch (e) {
      print("CheckStatus Error: $e");
      return _mockStatusCheck(jobId);
    }
  }

  Future<List<StickerPack>> getCommunityFeed() async {
    try {
      print("Fetching community feed from: ${ApiConstants.communityFeed}");
      final response = await http.get(Uri.parse(ApiConstants.communityFeed));
      print("Community feed response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Community feed parsed ${data.length} items");
        final packs = <StickerPack>[];
        for (var item in data) {
          try {
            packs.add(StickerPack.fromJson(item));
          } catch (e) {
            print("Error parsing pack: $e");
          }
        }
        print("Successfully created ${packs.length} StickerPack objects");
        return packs;
      }
      print("Community feed failed with status: ${response.statusCode}");
      return [];
    } catch (e) {
      print("Feed Error: $e");
      return [];
    }
  }

  Future<int?> likePack(String packId) async {
    try {
      final response = await http.post(Uri.parse(ApiConstants.likePack(packId)));
      if (response.statusCode == 200) {
          final data = json.decode(response.body);
          // Backend returns {"likes": new_count}
          return data['likes'] as int?;
      }
    } catch (e) {
      print("Like Error: $e");
    }
    return null;
  }

  Future<bool> deletePack(String packId) async {
    try {
      final response = await http.delete(Uri.parse(ApiConstants.deletePack(packId)));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Delete API Error: $e");
    }
    return false;
  }

  // Fallback for strict offline mode / demo
  Map<String, dynamic> _mockStatusCheck(String jobId) {
     final List<String> coolTitles = [
         "Meme God Starter Pack",
         "Certified Dank ✨",
         "Viral Material 📈",
         "Chaos Energy ⚡️",
         "The Vibe Curator 🎨"
     ];
     
     // Simple random pick based on job length or time
     final titleIndex = DateTime.now().second % coolTitles.length;
     final title = coolTitles[titleIndex];

     return {
       "status": "completed", 
       "progress": 100,
       "result": {
         "id": jobId,
         "title": title,
         "stickers": [
            {
                "id": "mock_1",
                "type": "reaction",
                "imageUrl": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbW51Z2EyOHE3amh4Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E/3oEjHAUOqG3lSS0f1C/giphy.gif",
                "caption": "LOL",
                "theme": "funny"
            },
            {
                "id": "mock_2",
                "type": "reaction",
                "imageUrl": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbW51Z2EyOHE3amh4Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2/26BGIqWh2R1fi5J72/giphy.gif", 
                "caption": "Side Eye",
                "theme": "sarcastic"
            },
            {
                "id": "mock_3",
                "type": "meme",
                "imageUrl": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbW51Z2EyOHE3amh4Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2/l0HlHJGHe3yAMjfFK/giphy.gif",
                "caption": "When the code works",
                "theme": "work"
            },
            {
                "id": "mock_4",
                "type": "reaction",
                "imageUrl": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbW51Z2EyOHE3amh4Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2/xT0CNqaX6JtXBV5Kww/giphy.gif",
                "caption": "Chaos Mode",
                "theme": "chaos"
            },
            {
                "id": "mock_5",
                "type": "reaction",
                "imageUrl": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbW51Z2EyOHE3amh4Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2/26FLdmIp6wJr91J4k/giphy.gif",
                "caption": "Party Time",
                "theme": "party"
            },
            {
                "id": "mock_6",
                "type": "meme",
                "imageUrl": "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbW51Z2EyOHE3amh4Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2Z2E2/3o7TKr3nzbh5WgCFxe/giphy.gif",
                "caption": "Love it",
                "theme": "love"
            }
         ]
       }
     };
  }
}
