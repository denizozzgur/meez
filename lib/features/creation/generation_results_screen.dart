import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/sticker_pack.dart';
import '../../shared/widgets/branded_background.dart';
import '../../core/utils/export_helper.dart';
import '../../core/utils/export_platform.dart';
import '../../core/utils/production_helpers.dart';
import '../library/detail_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import '../../core/services/storage_service.dart';
import '../../data/mock_data.dart'; // Import MockData for updates

class GenerationResultsScreen extends StatefulWidget {
  final StickerPack pack;
  final VoidCallback? onHome;

  const GenerationResultsScreen({
    super.key, 
    required this.pack,
    this.onHome,
  });

  @override
  State<GenerationResultsScreen> createState() => _GenerationResultsScreenState();
}

class _GenerationResultsScreenState extends State<GenerationResultsScreen> {
  late bool _isPublic;
  late StickerPack _currentPack;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPack = widget.pack;
    _isPublic = widget.pack.isPublic;
    
    // Track pack creation for rate prompt
    _checkRatePrompt();
  }
  
  Future<void> _checkRatePrompt() async {
    await RateAppManager.onPackCreated();
    if (await RateAppManager.shouldShowRatePrompt()) {
      // Delay to let the screen load first
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) RateAppManager.showRateDialog(context);
      });
    }
  }

  Future<void> _saveImage() async {
      try {
          final sticker = _currentPack.stickers[_currentIndex];
          final url = sticker.imageUrl;
          if (url.isEmpty) return;
          
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saving...")));
          
          final tempDir = await getTemporaryDirectory();
          final path = '${tempDir.path}/sticker_${sticker.id}.png';
          
          // Handle base64 data URLs vs network URLs
          if (url.startsWith("data:image")) {
            // Decode base64 and write to file
            final base64String = url.split(',').last;
            final bytes = base64Decode(base64String);
            await File(path).writeAsBytes(bytes);
          } else if (url.startsWith("http")) {
            // Download from network
            await Dio().download(url, path);
          } else {
            throw Exception("Unsupported URL format");
          }
          
          await Gal.putImage(path);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to Photos! 📸")));
          }
      } catch (e) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e")));
          }
      }
  }

  void _togglePrivacy(bool value) async {
      setState(() {
          _isPublic = value;
          // Create updated pack
          _currentPack = StickerPack(
              id: _currentPack.id,
              title: _currentPack.title,
              createdAt: _currentPack.createdAt,
              stickers: _currentPack.stickers,
              coverImageId: _currentPack.coverImageId,
              isFavorite: _currentPack.isFavorite,
              isPublic: value
          );
      });
      
      // Persist Change to both storages
      await StorageService().savePack(_currentPack);
      MockData.addPack(_currentPack); // Upserts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Deep dark background
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
               // Header
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     // Back Button
                     Container(
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12)
                       ),
                       child: IconButton(
                         icon: const Icon(Icons.arrow_back, color: Colors.white),
                         onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                       ),
                     ),
                     
                     // Title
                     Expanded(
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
                         child: Text(_currentPack.title, 
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          )),
                       ),
                     ),
                     
                     // Animate Button (Top Right)
                     Container(
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12)
                       ),
                       child: IconButton(
                         onPressed: () {
                             showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1E293B),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset('assets/images/mock/float_5.png', height: 70),
                                        const SizedBox(height: 16),
                                        const Text("Animate Your Stickers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    content: const Text("Give motions to your stickers using AI.", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                                    actions: [
                                        Center(
                                          child: TextButton(
                                              onPressed: () => Navigator.pop(context), 
                                              child: const Text("Close", style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold))
                                          ),
                                        )
                                    ],
                                )
                            );
                         },
                         icon: const Icon(Icons.movie_filter, color: Colors.white),
                         tooltip: "Animate",
                       ),
                     ),
                   ],
                 ),
               ),
               
               // Sticker Carousel
               Expanded(
                 child: PageView.builder(
                   controller: PageController(viewportFraction: 0.8),
                   onPageChanged: (index) => setState(() => _currentIndex = index),
                   itemCount: _currentPack.stickers.length,
                   itemBuilder: (context, index) {
                     final sticker = _currentPack.stickers[index];
                     // Scaling Effect
                     final isActive = index == _currentIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: isActive ? 16 : 40),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: isActive ? AppColors.accentBlue : Colors.white.withOpacity(0.1), width: isActive ? 2 : 1),
                            boxShadow: isActive ? [BoxShadow(color: AppColors.accentBlue.withOpacity(0.2), blurRadius: 20)] : []
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Center(
                              child: Builder(
                                  builder: (context) {
                                    // Handle both network URLs and base64 data URLs
                                    if (sticker.imageUrl.startsWith("data:image")) {
                                      try {
                                        final base64String = sticker.imageUrl.split(',').last;
                                        return Image.memory(
                                          base64Decode(base64String),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 50)),
                                        );
                                      } catch(e) {
                                        return const Center(child: Icon(Icons.error, color: Colors.white24, size: 50));
                                      }
                                    } else if (sticker.imageUrl.startsWith("http")) {
                                      return Image.network(
                                        sticker.imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
                                        },
                                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 50)),
                                      );
                                    } else {
                                      return const Center(child: Icon(Icons.image_not_supported, color: Colors.white24, size: 50));
                                    }
                                  },
                                ),
                            ),
                        ),
                      );
                   },
                 ),
               ),
               
               // Bottom CTA Bar
               Container(
                 padding: const EdgeInsets.all(16) + const EdgeInsets.only(bottom: 16),
                 decoration: BoxDecoration(
                   color: const Color(0xFF0F172A).withOpacity(0.95),
                   border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))
                 ),
                  child: Row(
                    children: [
                      // Left Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            IconButton(
                              onPressed: () async {
                                 await StorageService().deletePack(_currentPack.id);
                                 MockData.deletePack(_currentPack.id);
                                 if (context.mounted) {
                                   Navigator.of(context).popUntil((route) => route.isFirst);
                                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pack deleted")));
                                 }
                              },
                              icon: const Icon(Icons.delete_outline, color: Colors.white),
                              tooltip: "Delete",
                            ),
                            IconButton(
                              onPressed: () {
                                 Clipboard.setData(ClipboardData(text: 'Check out my sticker pack "${_currentPack.title}" here: https://meez.app/p/${_currentPack.id}'));
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied! 🔗")));
                              },
                              icon: const Icon(Icons.copy, color: Colors.white),
                              tooltip: "Copy Link",
                            ),
                            IconButton(
                              onPressed: _saveImage,
                              icon: const Icon(Icons.download, color: Colors.white),
                              tooltip: "Save Image",
                            ),
                        ],
                      ),
                      
                      const Spacer(),

                      // Add to WhatsApp (Right)
                       GestureDetector(
                            onTapUp: (details) async {
                                 final origin = details.globalPosition & const Size(1, 1);
                                 
                                 String? error = await ExportHelper.exportPack(
                                    _currentPack, 
                                    MeezExportPlatform.whatsapp,
                                    sharePositionOrigin: origin
                                 );
                                 
                                 if (error != null && mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                 } else if (mounted) {
                                     // Success handling if needed
                                 }
                            },
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: const Color(0xFF25D366),
                              borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text("Add to WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))
                              ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
             ],
           ),
         ),
       ));
  }

  Widget _buildShareOption(IconData icon, String label, Color color, VoidCallback onTap) {
      return GestureDetector(
          onTap: onTap,
          child: Column(
              children: [
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))
              ],
          ),
      );
  }
}
