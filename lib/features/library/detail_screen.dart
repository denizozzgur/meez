import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:viral_meme_app/core/utils/export_helper.dart';
import 'package:viral_meme_app/core/utils/export_platform.dart';
import '../../data/models/sticker_pack.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../core/theme/app_theme.dart';
import 'dart:convert';
import '../../shared/widgets/branded_background.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class DetailScreen extends StatefulWidget {
  final List<StickerAsset> stickers;
  final int initialIndex;

  const DetailScreen({super.key, required this.stickers, required this.initialIndex});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Split lists
  List<StickerAsset> _aiStickers = [];
  List<StickerAsset> _memes = [];
  
  // Controllers
  late PageController _stickerController;
  late PageController _memeController;
  
  int _currentStickerIndex = 0;
  int _currentMemeIndex = 0;

  @override
  void initState() {
    super.initState();
    // Sort items
    _aiStickers = widget.stickers.where((s) => s.type != StickerType.meme).toList();
    _memes = widget.stickers.where((s) => s.type == StickerType.meme).toList();

    // Determine initial indices based on the selected item
    final initialItem = widget.stickers[widget.initialIndex];
    if (initialItem.type == StickerType.meme) {
        _currentMemeIndex = _memes.indexOf(initialItem);
        if (_currentMemeIndex == -1) _currentMemeIndex = 0;
    } else {
        _currentStickerIndex = _aiStickers.indexOf(initialItem);
        if (_currentStickerIndex == -1) _currentStickerIndex = 0;
    }

    _stickerController = PageController(initialPage: _currentStickerIndex, viewportFraction: 1.0);
    _memeController = PageController(initialPage: _currentMemeIndex, viewportFraction: 1.0);
  }

  Future<void> _saveImage(StickerAsset item) async {
      try {
          if (item.imageUrl.isEmpty) return;
          
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saving...")));
          
          final tempDir = await getTemporaryDirectory();
          final path = '${tempDir.path}/detail_sticker_${item.id}.png';
          
          // Handle base64 data URLs vs network URLs
          if (item.imageUrl.startsWith("data:image")) {
            // Decode base64 and write to file
            final base64String = item.imageUrl.split(',').last;
            final bytes = base64Decode(base64String);
            await File(path).writeAsBytes(bytes);
          } else if (item.imageUrl.startsWith("http")) {
            // Download from network
            await Dio().download(item.imageUrl, path);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: BrandedBackground(
          child: Stack(
            children: [
                // Content (Rendered First / Behind Header)
                SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 50, top: 120),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // --- SECTION 1: STICKERS ---
                        if (_aiStickers.isNotEmpty) ...[
                            SizedBox(
                                height: 450, 
                                child: PageView.builder(
                                    controller: _stickerController,
                                    itemCount: _aiStickers.length,
                                    onPageChanged: (i) => setState(() => _currentStickerIndex = i),
                                    itemBuilder: (context, index) => _buildCard(_aiStickers[index], index == _currentStickerIndex)
                                ),
                            ),
                            const SizedBox(height: 20),
                            _buildActiveItemDetails(_aiStickers[_currentStickerIndex]),
                        ],

                        const SizedBox(height: 48),

                        // --- SECTION 2: MEMES ---
                        if (_memes.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("🔥 Memes", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                            ),
                            const SizedBox(height: 24),
                             SizedBox(
                                height: 400, 
                                child: PageView.builder(
                                    controller: _memeController,
                                    itemCount: _memes.length,
                                    onPageChanged: (i) => setState(() => _currentMemeIndex = i),
                                    itemBuilder: (context, index) => _buildCard(_memes[index], index == _currentMemeIndex)
                                ),
                            ),
                            const SizedBox(height: 20),
                            _buildActiveItemDetails(_memes[_currentMemeIndex]),
                        ],
                    ],
                ),
              ),

               // Back Button & Header (Rendered Last / On Top)
               Positioned(
                 top: 0,
                 left: 0,
                 right: 0,
                 child: SafeArea(
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.arrow_back, color: Colors.white),
                           onPressed: () => Navigator.pop(context),
                         ),
                         // Public Badge
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(20),
                             border: Border.all(color: Colors.white.withOpacity(0.2))
                           ),
                           child: Row(
                             children: [
                               const Icon(Icons.public, color: AppColors.accentBlue, size: 14),
                               const SizedBox(width: 6),
                               Text("Public Pack", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.bold))
                             ],
                           ),
                         ),
                         const SizedBox(width: 40) // Balance title
                       ],
                     ),
                   ),
                 ),
               ),
            ],
          )
      ),
    );
  }

  Widget _buildCard(StickerAsset sticker, bool isFocused) {
        Widget imageContent;
        if (sticker.imageUrl.startsWith("data:image")) {
            try {
                final base64String = sticker.imageUrl.split(',').last;
                imageContent = Image.memory(base64Decode(base64String), fit: BoxFit.contain);
            } catch(e) {
                imageContent = const Icon(Icons.error, color: Colors.white);
            }
        } else if (sticker.imageUrl.startsWith("http")) {
            imageContent = Image.network(sticker.imageUrl, fit: BoxFit.contain);
        } else {
            imageContent = const Center(child: Text("🔥", style: TextStyle(fontSize: 100)));
        }

        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20), 
            child: Hero(
                tag: sticker.id,
                child: imageContent,
            ),
        );
  }

  Widget _buildActiveItemDetails(StickerAsset item) {
      // Logic to hide caption if it's "sticker" or empty
      String displayCaption = item.caption;
      if (displayCaption.toLowerCase() == 'sticker' || displayCaption.toLowerCase() == 'meme' || displayCaption.isEmpty) {
          displayCaption = ""; 
      }

      // Identify active list and controller to show dots
      int count = 0;
      int currentIndex = 0;
      
      if (item.type == StickerType.meme) {
          count = _memes.length;
          currentIndex = _currentMemeIndex;
      } else {
          count = _aiStickers.length;
          currentIndex = _currentStickerIndex;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
            children: [
                 // Pagination Dots
                 if (count > 1) 
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(count, (index) {
                            final isActive = index == currentIndex;
                            return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 8 : 6,
                                height: isActive ? 8 : 6,
                                decoration: BoxDecoration(
                                    color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle
                                ),
                            );
                        }),
                    ),
                 
                 const SizedBox(height: 24),

                 if (displayCaption.isNotEmpty)
                     AnimatedSwitcher(
                       duration: const Duration(milliseconds: 300),
                       child: Text(
                         displayCaption,
                         key: ValueKey(item.id),
                         textAlign: TextAlign.center,
                         style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                       ),
                    ),
                    
                const SizedBox(height: 32),
                
                // Primary CTA: Add Pack (Consistent with other screens)
                GestureDetector(
                  onTapUp: (details) async {
                       // Create a temp pack wrapper since DetailScreen handles individual assets but export needs a pack
                       // We use the current stickers list to form a pack
                       final pack = StickerPack(
                           id: "temp_${DateTime.now().millisecondsSinceEpoch}", 
                           title: "Meez Pack", 
                           stickers: widget.stickers, 
                           createdAt: DateTime.now(), 
                           coverImageId: widget.stickers.first.imageUrl, 
                           author: "You"
                       );
                       final origin = details.globalPosition & const Size(1, 1);
                       
                       String? error = await ExportHelper.exportPack(
                          pack, 
                          MeezExportPlatform.whatsapp,
                          sharePositionOrigin: origin
                       );
                       
                       if (error != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                       } else if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Launching WhatsApp...")));
                       }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18), 
                        SizedBox(width: 8),
                        Text("Add to WhatsApp", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Secondary Actions: Share Link & Save
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Share Link
                    _SecondaryAction(
                      icon: Icons.link,
                      label: "Share Link",
                      onTap: () async {
                         await Clipboard.setData(ClipboardData(text: "https://meez.app/p/${item.id}"));
                         if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied to clipboard! 🔗")));
                         }
                      }
                    ),
                    
                    const SizedBox(width: 32),

                    // Animate (New)
                    Stack(
                        clipBehavior: Clip.none,
                        children: [
                            _SecondaryAction(
                                icon: Icons.movie_filter_rounded,
                                label: "Animate",
                                onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                            backgroundColor: const Color(0xFF1E293B),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            actionsAlignment: MainAxisAlignment.center,
                                            title: Column(
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        decoration: BoxDecoration(
                                                            color: AppColors.accentBlue.withOpacity(0.15),
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(color: AppColors.accentBlue.withOpacity(0.5))
                                                        ),
                                                        child: const Text("COMING SOON", style: TextStyle(color: AppColors.accentBlue, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5))
                                                    ),
                                                    const SizedBox(height: 16),
                                                    const Text("Animate Your Stickers\nWith AI", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                                                ]
                                            ),
                                            content: const Text("Give motions to your stickers using AI.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15)),
                                            actions: [
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 8.0),
                                                  child: TextButton(
                                                      onPressed: () => Navigator.pop(context), 
                                                      child: const Text("Close", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))
                                                  ),
                                                )
                                            ],
                                        )
                                    );
                                }
                            ),
                            Positioned(
                                top: -8,
                                right: -4,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: AppColors.accentBlue, 
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.black, width: 1.5) // Outline for contrast
                                    ),
                                    child: const Text("SOON", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                )
                            )
                        ],
                    ),
                    
                    const SizedBox(width: 32),
                    
                    // Save
                    _SecondaryAction(
                      icon: Icons.download_rounded,
                      label: "Save Image",
                      onTap: () => _saveImage(item)
                    ),
                  ],
                )
            ],
        ),
      );
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

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15))
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12))
        ],
      ),
    );
  }
}
