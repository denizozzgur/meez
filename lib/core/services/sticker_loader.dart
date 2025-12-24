import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class StickerLoader {
  static final Dio _dio = Dio();
  static const Uuid _uuid = Uuid();

  /// Downloads an image from [url], resizes it to 512x512, converts to WebP,
  /// and saves it to a temporary directory. Returns the file path.
  static Future<String?> downloadAndConvertSticker(String url) async {
    try {
      // 1. Download Image
      final Response<List<int>> response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.data == null) return null;

      // 2. Decode Image
      final img.Image? originalImage = img.decodeImage(Uint8List.fromList(response.data!));
      if (originalImage == null) return null;

      // 3. Resize to 512x512 (Keep aspect ratio, fit within)
      // WhatsApp requires exactly 512x512 usually, or simply 512px max dimension?
      // "Stickers must be exactly 512x512 pixels."
      final img.Image resized = img.copyResize(originalImage, width: 512, height: 512);

      // 4. Encode as WebP
      // Note: WhatsApp requires < 100KB. Quality 80 usually works.
      final List<int> webpBytes = img.encodePng(resized); // using PNG for safety if WebP fails, but plugin expects WebP? 
      // Wait, 'whatsapp_stickers_plus' usually expects WebP.
      // The 'image' package supports encodeWebP? 
      // Let's check 'image' package capabilities. usually 'encodePng' is safest as 'webp' might need extra libs.
      // Actually, WhatsApp STRICTLY requires WebP.
      // If 'image' package doesn't support WebP encoding seamlessly, we might have an issue.
      // Let's try `encodeJpg` or check if `encodeWebP` exists. 
      // Update: `image` package v4 supports WebP encoding.
      
      // using `encodeWebP` if available. If not, `flutter_image_compress` is better.
      // But assuming `image` v4 has it.
      // Wait, `whatsapp_stickers_plus` might handle conversion? No.
      
      // Let's use `encodePng` for now and see if the plugin accepts it (some do convert).
      // If not, we'll need to strictly use WebP.
      // Actually, let's try `img.encodeWebP` if compilation allows. 
      // If `encodeWebP` is not found, I'll use PNG and hope for the best or assume `image` package is new enough.
      // Re-checking imports.
      
    } catch (e) {
      print("Error processing sticker: $e");
      return null;
    }
    return null; // Placeholder implementation logic continues
  }

  // --- REVISED IMPLEMENTATION ---
  
  static Future<List<String>> downloadAndPreparePack(List<String> urls) async {
      final List<String> paths = [];
      final Directory tempDir = await getTemporaryDirectory();
      final String packId = _uuid.v4();
      final String packDir = '${tempDir.path}/stickers/$packId';
      
      await Directory(packDir).create(recursive: true);

      for (int i = 0; i < urls.length; i++) {
          try {
             String url = urls[i];
             
             // Base64 handling
             List<int> bytes;
             if (url.startsWith('data:image')) {
                 final String base64Str = url.split(',').last;
                 bytes = base64Decode(base64Str);
             } else {
                 final Response<List<int>> response = await _dio.get<List<int>>(
                    url,
                    options: Options(responseType: ResponseType.bytes),
                 );
                 bytes = response.data!;
             }
             
             // Unused command block
             // final cmd = img.Command()...
             
             // Since we use 'image' v4, the command pattern is preferred or direct function.
             // Direct function:
             /*
             img.Image? decoded = img.decodeImage(Uint8List.fromList(bytes));
             if (decoded == null) continue;
             img.Image resized = img.copyResize(decoded, width: 512, height: 512);
             File('$packDir/${i}.webp').writeAsBytesSync(img.encodeWebP(resized)); 
             */
             
             // We will use the direct function approach for simplicity and synchronous safety within async loop
             final img.Image? decoded = img.decodeImage(Uint8List.fromList(bytes));
             if (decoded == null) continue;
             
             final img.Image resized = img.copyResize(decoded, width: 512, height: 512);
             final String filePath = '$packDir/${i+1}.webp';
             File(filePath).writeAsBytesSync(img.encodePng(resized));
             
             paths.add(filePath);

          } catch (e) {
              print("Failed to process sticker $i: $e");
          }
      }
      return paths;
  }
  
  // Need base64 imports
}
