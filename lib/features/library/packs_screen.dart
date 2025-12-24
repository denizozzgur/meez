import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../data/mock_data.dart';
import '../../data/models/sticker_pack.dart';
import '../../core/services/storage_service.dart';
import 'package:viral_meme_app/core/api/api_client.dart';
import 'package:viral_meme_app/core/utils/export_helper.dart';
import 'package:viral_meme_app/core/utils/export_platform.dart' as platforms;
import 'package:viral_meme_app/core/utils/production_helpers.dart';
import 'package:viral_meme_app/features/legal/privacy_policy_screen.dart';
import 'package:viral_meme_app/features/legal/terms_of_service_screen.dart';
import 'package:viral_meme_app/features/subscription/subscription_settings_screen.dart';
import 'detail_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PacksScreen extends StatefulWidget {
  final StickerPack? extraPack;
  final VoidCallback? onGoToCreate;
  final VoidCallback? onGoToCommunity;

  const PacksScreen({super.key, this.extraPack, this.onGoToCreate, this.onGoToCommunity});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen> {
  // Track liked packs locally
  final Set<String> _likedPackIds = {};
  List<StickerPack> _packs = [];

  @override
  void initState() {
    super.initState();
    _loadPacks();
  }

  Future<void> _loadPacks() async {
    try {
      // Load from persistent storage (async ensures init)
      var localPacks = await StorageService().getPacksAsync();
      
      // Also sync with MockData for session consistency
      for (var pack in localPacks) {
        if (!MockData.getAllPacks().any((p) => p.id == pack.id)) {
          MockData.addPack(pack);
        }
      }
      
      if (widget.extraPack != null && !localPacks.any((p) => p.id == widget.extraPack!.id)) {
        localPacks.insert(0, widget.extraPack!);
        await StorageService().savePack(widget.extraPack!);
      }
      
      if (mounted) setState(() { _packs = localPacks; });
      _syncWithBackend();
    } catch (e) {
      debugPrint('Error loading packs: $e');
      if (mounted) setState(() { _packs = []; });
    }
  }

  Future<void> _syncWithBackend() async {
      try {
          final communityPacks = await ApiClient().getCommunityFeed();
          if (!mounted) return;
          
          bool changed = false;
          for (var i = 0; i < _packs.length; i++) {
              final local = _packs[i];
              final remote = communityPacks.firstWhere((p) => p.id == local.id, orElse: () => StickerPack.empty());
              
              if (remote.id.isNotEmpty && remote.likes != local.likes) {
                  _packs[i] = StickerPack(
                     id: local.id,
                     title: local.title,
                     author: local.author,
                     likes: remote.likes,
                     createdAt: local.createdAt,
                     stickers: local.stickers,
                     coverImageId: local.coverImageId,
                     isFavorite: local.isFavorite,
                     isPublic: local.isPublic
                  );
                  changed = true;
              }
          }
          if (changed && mounted) setState(() {});
      } catch (e) {
          print("Sync Logic Error: $e");
      }
  }

  void _deletePack(String id) async {
      // Optimistic Update
      setState(() {
          _packs.removeWhere((p) => p.id == id);
          MockData.deletePack(id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pack deleted.")));
      
      // Delete from persistent storage
      await StorageService().deletePack(id);
      
      // Fire and forget backend delete
      await ApiClient().deletePack(id);
  }
  
  void _toggleLike(String id) {
      setState(() {
          if (_likedPackIds.contains(id)) {
              _likedPackIds.remove(id);
          } else {
              _likedPackIds.add(id);
          }
      });
  }
  
  void _handleMenuAction(String action) {
    HapticHelper.lightTap();
    switch (action) {
      case 'subscription':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionSettingsScreen()));
        break;
      case 'privacy':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
        break;
      case 'terms':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
        break;
      case 'support':
        launchUrl(Uri.parse('mailto:support@meez.app?subject=Meez%20Support'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_packs.isEmpty) {
        return Scaffold(
           extendBodyBehindAppBar: true,
           backgroundColor: Colors.transparent,
           appBar: AppBar(
             title: const Text("History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
             centerTitle: false,
             backgroundColor: Colors.transparent,
             elevation: 0,
             actions: [
               PopupMenuButton<String>(
                 onSelected: (value) => _handleMenuAction(value),
                 offset: const Offset(0, 45),
                 color: const Color(0xFF1E293B),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 itemBuilder: (context) => [
                   const PopupMenuItem(
                     value: 'subscription',
                     child: Row(children: [
                       Icon(Icons.star_outline, color: Colors.white70, size: 20),
                       SizedBox(width: 12),
                       Text('Subscription', style: TextStyle(color: Colors.white)),
                     ]),
                   ),
                   const PopupMenuDivider(),
                   const PopupMenuItem(
                     value: 'privacy',
                     child: Row(children: [
                       Icon(Icons.privacy_tip_outlined, color: Colors.white70, size: 20),
                       SizedBox(width: 12),
                       Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                     ]),
                   ),
                   const PopupMenuItem(
                     value: 'terms',
                     child: Row(children: [
                       Icon(Icons.description_outlined, color: Colors.white70, size: 20),
                       SizedBox(width: 12),
                       Text('Terms of Service', style: TextStyle(color: Colors.white)),
                     ]),
                   ),
                   const PopupMenuDivider(),
                   const PopupMenuItem(
                     value: 'support',
                     child: Row(children: [
                       Icon(Icons.help_outline, color: Colors.white70, size: 20),
                       SizedBox(width: 12),
                       Text('Contact Support', style: TextStyle(color: Colors.white)),
                     ]),
                   ),
                 ],
                 child: Container(
                   margin: const EdgeInsets.only(right: 16),
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.1),
                     shape: BoxShape.circle,
                   ),
                   child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                 ),
               ),
             ],
           ),
           body: SafeArea(
             child: Center(
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 32.0),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     // Sticker visual - 3 tilted stickers
                     SizedBox(
                       width: 180,
                       height: 100,
                       child: Stack(
                         alignment: Alignment.center,
                         children: [
                           Positioned(
                             left: 10,
                             child: Transform.rotate(
                               angle: -0.15,
                               child: Container(
                                 width: 55, height: 55,
                                 decoration: BoxDecoration(
                                   color: Colors.white.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 child: const Center(child: Text("😊", style: TextStyle(fontSize: 28))),
                               ),
                             ),
                           ),
                           Positioned(
                             child: Container(
                               width: 65, height: 65,
                               decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.15),
                                 borderRadius: BorderRadius.circular(14),
                               ),
                               child: const Center(child: Text("🔥", style: TextStyle(fontSize: 32))),
                             ),
                           ),
                           Positioned(
                             right: 10,
                             child: Transform.rotate(
                               angle: 0.15,
                               child: Container(
                                 width: 55, height: 55,
                                 decoration: BoxDecoration(
                                   color: Colors.white.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 child: const Center(child: Text("💯", style: TextStyle(fontSize: 28))),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 32),
                     const Text(
                       "No Stickers Yet", 
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                     ),
                     const SizedBox(height: 8),
                     Text(
                       "Your creations will appear here", 
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)
                     ),
                     
                     const SizedBox(height: 40),
                     
                     // Primary Call to Action
                     Container(
                         width: 200,
                         height: 52,
                         decoration: BoxDecoration(
                             color: AppColors.accentBlue,
                             borderRadius: BorderRadius.circular(14),
                             boxShadow: [
                                 BoxShadow(
                                   color: AppColors.accentBlue.withOpacity(0.3), 
                                   blurRadius: 16, 
                                   offset: const Offset(0, 6)
                                 )
                             ]
                         ),
                         child: ElevatedButton(
                             onPressed: widget.onGoToCreate,
                             style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.transparent,
                                 shadowColor: Colors.transparent,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                             ),
                             child: const Text("Create Stickers", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                         ),
                     ),
                     
                     const SizedBox(height: 16),
                     
                     // Secondary Action
                     TextButton(
                       onPressed: widget.onGoToCommunity,
                       child: Text("Explore Community", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500, fontSize: 14)),
                     ),
                   ],
                 ),
               ),
             ),
           ),
        );
    }


    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            offset: const Offset(0, 45),
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'subscription',
                child: Row(children: [
                  Icon(Icons.star_outline, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Subscription', style: TextStyle(color: Colors.white)),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'privacy',
                child: Row(children: [
                  Icon(Icons.privacy_tip_outlined, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                ]),
              ),
              const PopupMenuItem(
                value: 'terms',
                child: Row(children: [
                  Icon(Icons.description_outlined, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Terms of Service', style: TextStyle(color: Colors.white)),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'support',
                child: Row(children: [
                  Icon(Icons.help_outline, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Contact Support', style: TextStyle(color: Colors.white)),
                ]),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: ListView.builder(
          padding: const EdgeInsets.only(top: 130, left: 16, right: 16, bottom: 24),
          itemCount: _packs.length,
          itemBuilder: (context, index) {
            try {
              final pack = _packs[index];
              final isLiked = _likedPackIds.contains(pack.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: PremiumGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(pack.title, 
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))
                          ),
                          // Interactive Flame Icon
                          GestureDetector(
                            onTap: () => _toggleLike(pack.id),
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: isLiked ? Colors.orange.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isLiked ? Border.all(color: Colors.orange.withOpacity(0.5)) : null
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        Icons.local_fire_department, 
                                        color: isLiked ? Colors.orange : Colors.white.withOpacity(0.3),
                                        size: 20
                                    ),
                                    if (pack.likes > 0) ...[
                                        const SizedBox(width: 4),
                                        Text("${pack.likes}", style: TextStyle(color: isLiked ? Colors.orange : Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 13)),
                                    ]
                                  ],
                                ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0, 
                        ),
                        itemCount: pack.stickers.length > 6 ? 6 : pack.stickers.length,
                        itemBuilder: (context, i) {
                            final sticker = pack.stickers[i];
                            Widget imageContent;

                            // Image Logic
                            if (sticker.imageUrl.startsWith("data:image")) {
                              try {
                                final base64String = sticker.imageUrl.split(',').last;
                                 imageContent = Image.memory(base64Decode(base64String), fit: BoxFit.contain);
                              } catch (e) {
                                imageContent = const Icon(Icons.error, color: Colors.white);
                              }
                            } else if (sticker.imageUrl.startsWith("http")) {
                              imageContent = Image.network(sticker.imageUrl, fit: BoxFit.contain);
                            } else {
                               imageContent = const Center(child: Text("🔥", style: TextStyle(fontSize: 32)));
                            }

                            // If it's the 6th item and there are more, could show overlay, but user expects 6.
                            // Just showing the grid item.
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(stickers: pack.stickers, initialIndex: i))),
                              child: Hero(
                                tag: "${sticker.id}_history",
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.1))
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  padding: const EdgeInsets.all(8), // Padding inside cell
                                  child: imageContent,
                                ),
                              ),
                            );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Action Row
                      Row(
                        children: [
                          // Main CTA: Add Pack
                          Expanded(
                            child: GestureDetector(
                              onTapUp: (details) async {
                                   // Create a 1x1 rect at the touch position
                                   final origin = details.globalPosition & const Size(1, 1);
                                   
                                   String? error = await ExportHelper.exportPack(
                                      pack, 
                                      platforms.MeezExportPlatform.whatsapp,
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
                          // Copy Link
                          _iconButton(Icons.link, () {
                              Clipboard.setData(ClipboardData(text: 'Check out my sticker pack "${pack.title}" here: https://meez.app/p/${pack.id}'));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied!")));
                          }),
                          const SizedBox(width: 8),
                          // Delete
                          _iconButton(Icons.delete_outline, () => _deletePack(pack.id), color: Colors.redAccent.withOpacity(0.7)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            } catch (e) {
              return const SizedBox.shrink(); // Hide problematic items instead of crashing
            }
          },
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
}
