import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:viral_meme_app/core/theme/app_theme.dart';

import 'package:viral_meme_app/data/models/sticker_pack.dart';
import 'package:viral_meme_app/shared/widgets/premium_glass_card.dart';
import 'package:viral_meme_app/shared/widgets/branded_background.dart';
import 'package:viral_meme_app/shared/widgets/production_widgets.dart';
import 'package:viral_meme_app/features/library/packs_screen.dart';
import 'package:viral_meme_app/features/library/detail_screen.dart';
import 'package:viral_meme_app/core/api/api_client.dart';
import 'package:viral_meme_app/core/utils/export_helper.dart';
import 'package:viral_meme_app/core/utils/export_platform.dart';
import 'package:viral_meme_app/core/utils/production_helpers.dart';
import 'package:viral_meme_app/core/services/rating_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final Set<String> _likedPackIds = {};
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  
  List<StickerPack> _allPacks = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _sortOrder = 'New'; // Default to newest first

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    // Auto-refresh every 5 seconds to show new generations immediately
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _loadFeed(quiet: true);
    });
  }

  Future<void> _loadFeed({bool quiet = false}) async {
    try {
      // Add timeout to prevent UI blocking on physical devices
      final packs = await ApiClient().getCommunityFeed().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("Community Feed timeout - returning empty list");
          return [];
        },
      );
      print("Community Feed loaded: ${packs.length} packs");
      if (mounted) {
        setState(() {
          _allPacks = packs;
          _isLoading = false;
          _hasError = packs.isEmpty && !quiet;
        });
      }
    } catch (e) {
      print("Community Feed error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = !quiet;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleLike(String id) {
      HapticHelper.lightTap();
      setState(() {
          if (_likedPackIds.contains(id)) {
              _likedPackIds.remove(id);
          } else {
              _likedPackIds.add(id);
          }
      });
  }

  void _showReportDialog(StickerPack pack) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Report Pack", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Why are you reporting \"${pack.title}\"?", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
            const SizedBox(height: 16),
            _reportOption("Inappropriate content", Icons.block),
            _reportOption("Spam or misleading", Icons.warning_amber),
            _reportOption("Copyright violation", Icons.copyright),
            _reportOption("Other", Icons.more_horiz),
          ],
        ),
      ),
    );
  }

  Widget _reportOption(String label, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Thanks for reporting. We'll review this pack."),
            backgroundColor: Colors.green.shade700,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    var filteredPacks = _allPacks.where((p) {
        if (_searchQuery.isEmpty) return true;
        return p.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
               p.stickers.any((s) => s.caption.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    // Sort Logic
    if (_sortOrder == 'New') {
        // Sort by createdAt - newest first
        filteredPacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortOrder == 'Trending') {
        // Sort by likes count - highest first
        // Include local likes (toggle state) in the count
        filteredPacks.sort((a, b) {
            final likesA = a.likes + (_likedPackIds.contains(a.id) ? 1 : 0);
            final likesB = b.likes + (_likedPackIds.contains(b.id) ? 1 : 0);
            return likesB.compareTo(likesA);
        });
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by MainScreen gradient
      appBar: AppBar(
        title: const Text("Community Board", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: [
            PopupMenuButton<String>(
              onSelected: (value) => setState(() => _sortOrder = value),
              offset: const Offset(0, 40),
              color: const Color(0xFF1E293B),
              constraints: const BoxConstraints(minWidth: 140),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
              itemBuilder: (context) => [
                 const PopupMenuItem(
                    value: "Trending", 
                    child: Row(children: [Icon(Icons.whatshot, color: Colors.orange, size: 20), SizedBox(width: 8), Text("Trending", style: TextStyle(color: Colors.white))])
                 ),
                 const PopupMenuItem(
                    value: "New", 
                    child: Row(children: [Icon(Icons.new_releases, color: Colors.blue, size: 20), SizedBox(width: 8), Text("New", style: TextStyle(color: Colors.white))])
                 ),
              ],
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentBlue.withOpacity(0.5))
                ),
                child: Row(
                  children: [
                    Text(_sortOrder, style: const TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: AppColors.accentBlue, size: 16)
                  ],
                ),
              ),
            )
        ],
      ),
      body: BrandedBackground( 
        child: Column(
          children: [
            // Search Bar
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: Colors.white.withOpacity(0.1))
                   ),
                   child: TextField(
                       controller: _searchController,
                       onChanged: (val) => setState(() => _searchQuery = val.trim()),
                       style: const TextStyle(color: Colors.white),
                       decoration: InputDecoration(
                           border: InputBorder.none,
                           hintText: "Search stickers...",
                           hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                           icon: Icon(Icons.search, color: Colors.white.withOpacity(0.5))
                       ),
                   )
               ),
            ),

            // List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadFeed,
                color: AppColors.accentBlue,
                backgroundColor: const Color(0xFF1E293B),
                child: _isLoading 
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 3,
                      itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: PackSkeleton(),
                      ),
                    )
                  : _hasError
                      ? ErrorStateWidget(
                          message: "Couldn't load community packs.\nCheck your connection and try again.",
                          onRetry: _loadFeed,
                        )
                      : filteredPacks.isEmpty 
                          ? EmptyStateWidget(
                              icon: "✨",
                              title: "Be the First!",
                              subtitle: "Create a sticker pack and share\\nit with the community",
                              actionLabel: "Create Stickers",
                              onAction: () => Navigator.of(context).pop(),
                            )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          itemCount: filteredPacks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                     final pack = filteredPacks[index];
                     final isLiked = _likedPackIds.contains(pack.id);
                                          return PremiumGlassCard(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER: Minimal - Title + Author + Upvote
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Title & Author (Stacked)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                         Text(pack.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                         const SizedBox(height: 2),
                                         Text("by ${pack.author}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  // Upvote Badge (Reddit-style toggle)
                                  GestureDetector(
                                    onTap: () => _toggleLike(pack.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isLiked ? Colors.orange.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: isLiked ? Colors.orange.withOpacity(0.4) : Colors.white.withOpacity(0.1))
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.local_fire_department, color: isLiked ? Colors.orange : Colors.white54, size: 16),
                                          const SizedBox(width: 4),
                                          Text("${pack.likes + (isLiked ? 1 : 0)}", style: TextStyle(color: isLiked ? Colors.orange : Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                   
                   // VISUAL: Sticker Grid / Preview
                   SizedBox(
                     height: 160,
                     child: ListView.builder(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       scrollDirection: Axis.horizontal,
                       itemCount: pack.stickers.length,
                       itemBuilder: (ctx, i) {
                          final sticker = pack.stickers[i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(
                                    stickers: pack.stickers,
                                    initialIndex: i,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 140,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: _buildStickerImage(sticker),
                                ),
                              ),
                            ),
                          );
                       }
                     ),
                   ),
                   
                   // ACTIONS: Primary CTA
                   Padding(
                     padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                     child: Row(
                       children: [
                         // WhatsApp Button
                          Expanded(
                           child: GestureDetector(
                            onTapUp: (details) async {
                                 final origin = details.globalPosition & const Size(1, 1);
                                 
                                 String? error = await ExportHelper.exportPack(
                                    pack, 
                                    MeezExportPlatform.whatsapp,
                                    sharePositionOrigin: origin
                                 );
                                 
                                 if (error != null && mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Export Error"),
                                        content: Text(error),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("OK"),
                                          )
                                        ],
                                      ),
                                    );
                                 } else if (mounted) {
                                    // Successful export - check if we should show rating popup
                                    final ratingService = RatingService();
                                    final shouldShowRating = await ratingService.onSuccessfulExport();
                                    if (shouldShowRating && mounted) {
                                      await RatingService.showRatingPopup(context);
                                    }
                                 }
                            },
                             child: Container(
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
                                   Text("Add to WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                 ],
                               ),
                             ),
                           ),
                         ),
                         const SizedBox(width: 10),
                         // Copy Link Button
                         GestureDetector(
                           onTap: () {
                               HapticHelper.lightTap();
                               Clipboard.setData(ClipboardData(text: 'Check out this sticker pack "${pack.title}" here: https://meez.app/p/community/${pack.id}'));
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied!")));
                           },
                           child: Container(
                             width: 44, height: 44,
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.08),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: const Icon(Icons.link, color: Colors.white70, size: 20),
                           ),
                         ),
                         const SizedBox(width: 8),
                         // Report Button
                         GestureDetector(
                           onTap: () => _showReportDialog(pack),
                           child: Container(
                             width: 44, height: 44,
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.08),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Icon(Icons.flag_outlined, color: Colors.white.withOpacity(0.5), size: 20),
                           ),
                         ),
                       ],
                     ),
                   )
                 ],
               ),
             );
          },
        ),
      ),
    ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildStickerImage(StickerAsset sticker) {
      if (sticker.imageUrl.startsWith("http")) {
          return Image.network(sticker.imageUrl, fit: BoxFit.contain);
      } else if (sticker.imageUrl.startsWith("data:image")) {
          return Image.memory(base64Decode(sticker.imageUrl.split(',').last), fit: BoxFit.contain);
      } 
      return const Text("🔥", style: TextStyle(fontSize: 40));
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ExportOption({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1))
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white54)
          ],
        ),
      ),
    );
  }
}
