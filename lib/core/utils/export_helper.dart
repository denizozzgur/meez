import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/sticker_pack.dart';
import 'package:viral_meme_app/core/utils/export_platform.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ExportHelper {
  static const MethodChannel _channel = MethodChannel('com.meez.app/whatsapp_stickers');

  /// Main entry point to export a pack
  static Future<String?> exportPack(StickerPack pack, MeezExportPlatform platform, {Rect? sharePositionOrigin}) async {
    if (platform == MeezExportPlatform.whatsapp) {
       return await _sendToWhatsAppNative(pack);
    }
    
    // Fallback for other platforms
    try {
      return await _shareImages(pack, sharePositionOrigin: sharePositionOrigin);
    } catch (e) {
      return "General export error: $e";
    }
  }

  /// Send sticker pack to WhatsApp using native iOS API (Pasteboard + URL scheme)
  static Future<String?> _sendToWhatsAppNative(StickerPack pack) async {
      try {
          if (pack.stickers.length < 3) {
              return "WhatsApp requires at least 3 stickers per pack.\nPlease generate more stickers.";
          }
          if (pack.stickers.length > 30) {
              return "WhatsApp allows max 30 stickers per pack.";
          }

          // 1. Prepare Tray Icon (Base64 PNG, 96x96)
          String trayImageUrl = "";
          if (pack.coverImageId.isNotEmpty) {
              try {
                  final coverSticker = pack.stickers.firstWhere((s) => s.id == pack.coverImageId);
                  trayImageUrl = coverSticker.imageUrl;
              } catch (_) {}
          }
          if (trayImageUrl.isEmpty && pack.stickers.isNotEmpty) {
              trayImageUrl = pack.stickers.first.imageUrl;
          }
          
          if (trayImageUrl.isEmpty) return "Could not determine tray icon.";

          final trayBytesRaw = await _getImageBytes(trayImageUrl);
          if (trayBytesRaw == null) return "Could not load tray icon.";
          
          final trayImage = img.decodeImage(trayBytesRaw);
          if (trayImage == null) return "Invalid tray image data.";
          
          final resizedTray = img.copyResize(trayImage, width: 96, height: 96);
          final trayPngBytes = img.encodePng(resizedTray);
          final trayBase64 = base64Encode(trayPngBytes);

          // 2. Prepare Stickers (Base64 WebP, 512x512)
          final List<Map<String, dynamic>> stickersData = [];
          
          for (int i = 0; i < pack.stickers.length && i < 30; i++) {
             final sticker = pack.stickers[i];
             
             final bytes = await _getImageBytes(sticker.imageUrl);
             if (bytes == null) continue;
             
             final image = img.decodeImage(bytes);
             if (image == null) continue;
             
             // Resize to 512x512
             final resized = img.copyResize(image, width: 512, height: 512);
             
             // Encode to PNG first
             final pngBytes = img.encodePng(resized);
             
             // Convert to WebP
             final webpBytes = await FlutterImageCompress.compressWithList(
               pngBytes,
               minHeight: 512,
               minWidth: 512,
               quality: 80,
               format: CompressFormat.webp,
             );
             
             final stickerBase64 = base64Encode(webpBytes);
             
             stickersData.add({
                 "image_data": stickerBase64,
                 "emojis": ["😀", "✨"],
             });
          }

          if (stickersData.length < 3) {
              return "Could not process at least 3 stickers.";
          }

          // 3. Build payload matching WhatsApp's expected JSON structure
          final cleanId = pack.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
          final payload = {
              "identifier": "meez_$cleanId",
              "name": pack.title,
              "publisher": "Meez AI",
              "tray_image": trayBase64,
              "publisher_email": "support@meez.app",
              "publisher_website": "https://meez.app",
              "privacy_policy_website": "https://meez.app/privacy",
              "license_agreement_website": "https://meez.app/license",
              "stickers": stickersData,
          };

          // 4. Call native iOS code via MethodChannel
          await _channel.invokeMethod('sendStickerPackToWhatsApp', payload);
          
          return null; // Success
      } on PlatformException catch (e) {
          debugPrint("WhatsApp native error: ${e.message}");
          return e.message ?? "WhatsApp export failed";
      } catch (e) {
          debugPrint("WhatsApp export error: $e");
          return "WhatsApp export error: $e";
      }
  }

  /// Share images via system share sheet (Fallback for non-WhatsApp)
  static Future<String?> _shareImages(StickerPack pack, {Rect? sharePositionOrigin}) async {
      try {
          final tempDir = await getTemporaryDirectory();
          final List<XFile> files = [];

          for (final sticker in pack.stickers) {
              try {
                  final bytes = await _getImageBytes(sticker.imageUrl);
                  if (bytes != null) {
                      final path = '${tempDir.path}/${sticker.id}.png';
                      await File(path).writeAsBytes(bytes);
                      files.add(XFile(path));
                  }
              } catch (_) {}
          }
          
          if (files.isEmpty) {
              return "No valid images found for export.";
          }
          
          await Share.shareXFiles(
              files,
              text: "Check out my sticker pack '${pack.title}' from Meez! 🎨",
              sharePositionOrigin: sharePositionOrigin,
          );
          
          return null; 
      } catch (e) {
          return "Share error: $e";
      }
  }

  /// Get image bytes from URL, base64, asset, or local file
  static Future<Uint8List?> _getImageBytes(String imageUrl) async {
      try {
          if (imageUrl.startsWith("data:image")) {
              final base64String = imageUrl.split(',').last;
              return base64Decode(base64String);
          } 
          else if (imageUrl.startsWith("http")) {
              final response = await Dio().get(
                  imageUrl,
                  options: Options(responseType: ResponseType.bytes),
              );
              return Uint8List.fromList(response.data as List<int>);
          } 
          else if (imageUrl.startsWith("assets/")) {
              final byteData = await rootBundle.load(imageUrl);
              return byteData.buffer.asUint8List();
          }
          else {
              String path = imageUrl;
              if (path.startsWith('file://')) {
                  path = path.substring(7);
              }
              
              final file = File(path);
              if (await file.exists()) {
                  return await file.readAsBytes();
              } else {
                  return null;
              }
          }
      } catch (e) {
          debugPrint("Error getting image bytes: $e");
          return null;
      }
  }
}
