import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_client.dart';
import '../../core/services/subscription_service.dart';
import '../../core/services/language_service.dart';
import '../../shared/widgets/premium_glass_card.dart';
import '../../shared/widgets/branded_background.dart';
import '../library/packs_screen.dart';
import '../../data/models/sticker_pack.dart';
import '../library/detail_screen.dart';
import 'generation_results_screen.dart';
import '../../data/mock_data.dart';
import '../subscription/trial_ended_screen.dart';
import '../../core/services/storage_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

enum CreateStep { textInput, themeSelect, generating }

class _CreateScreenState extends State<CreateScreen> with SingleTickerProviderStateMixin {
  CreateStep _step = CreateStep.textInput;
  final ApiClient _api = ApiClient();
  final ImagePicker _picker = ImagePicker();
  final SubscriptionService _subscriptionService = SubscriptionService();
  final TextEditingController _textController = TextEditingController();
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  bool _hasInput = false;
  File? _selectedImage;
  String? _loadingProgress;
  
  // Caption and language settings
  bool _captionsEnabled = true;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
        
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
    
    // Load caption preferences
    _loadCaptionPreferences();
  }
  
  Future<void> _loadCaptionPreferences() async {
    final enabled = await LanguageService.areCaptionsEnabled();
    final lang = await LanguageService.getPreferredLanguage();
    if (mounted) {
      setState(() {
        _captionsEnabled = enabled;
        _selectedLanguage = lang;
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward();
  }

  void _handleGeneratePress() async {
    if (_hasInput) {
      // Check subscription/trial limit before generating
      if (!_subscriptionService.canGenerate) {
        final subscribed = await TrialEndedScreen.show(context);
        if (!subscribed) return;
      }
      _startTextGeneration();
    } else {
      _triggerShake();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a prompt first! ✨"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }
  
  final List<String> _selectedMoods = [];  // Optional mood selection
  final List<String> _selectedStyles = [];  // Optional style selection

  // Mood options - emotional tone of stickers
  final Map<String, Map<String, dynamic>> _moodOptions = {
      "happy": {"label": "Happy", "emoji": "😊", "color": const Color(0xFFFBBF24)},     // Joyful, smiling
      "funny": {"label": "Funny", "emoji": "😂", "color": const Color(0xFFF472B6)},     // Laughing, comedy
      "sarcastic": {"label": "Sarcastic", "emoji": "🙄", "color": const Color(0xFFEF4444)}, // Eye roll, roast
      "chill": {"label": "Chill", "emoji": "😎", "color": const Color(0xFF38BDF8)},     // Relaxed, cool
      "romantic": {"label": "Romantic", "emoji": "🥰", "color": const Color(0xFFEC4899)}, // Love, hearts
      "excited": {"label": "Excited", "emoji": "🤩", "color": const Color(0xFF10B981)},   // Hyped, stars
      "angry": {"label": "Angry", "emoji": "🤬", "color": const Color(0xFFDC2626)},       // Mad, fire
      "sad": {"label": "Sad", "emoji": "😢", "color": const Color(0xFF64748B)},           // Teary, blues
  };

  // Style options - visual rendering style
  final Map<String, Map<String, dynamic>> _styleOptions = {
      "3d": {"label": "3D Render", "emoji": "🧊", "color": const Color(0xFF22D3EE)},          // Pixar style
      "sticker": {"label": "Sticker Art", "emoji": "✂️", "color": const Color(0xFFF472B6)},   // Classic die-cut
      "pixel": {"label": "Retro Pixel", "emoji": "👾", "color": const Color(0xFFA855F7)},     // 8-bit game
      "handdrawn": {"label": "Hand Drawn", "emoji": "✏️", "color": const Color(0xFFFBBF24)},  // Sketchy, doodle
      "clay": {"label": "Claymation", "emoji": "🗿", "color": const Color(0xFFFB923C)},       // Plasticine look
      "painting": {"label": "Oil Painting", "emoji": "🎨", "color": const Color(0xFF10B981)}, // Artistic
      "anime": {"label": "Anime", "emoji": "🌸", "color": const Color(0xFFE879F9)},           // Japanese style
      "realistic": {"label": "Realistic", "emoji": "📸", "color": const Color(0xFF94A3B8)},   // Photo-real
  };

  void _toggleMood(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else {
        _selectedMoods.add(mood);
      }
    });
  }

  void _toggleStyle(String style) {
    setState(() {
      if (_selectedStyles.contains(style)) {
        _selectedStyles.remove(style);
      } else {
        _selectedStyles.add(style);
      }
    });
  }

  Future<void> _handleImageSelection() async {
      try {
          final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 600, // Reduced from 800 for speed
              maxHeight: 600,
              imageQuality: 70 // Reduced from 85 to significantly reduce payload size
          );
          
          if (pickedFile != null) {
              setState(() {
                  _selectedImage = File(pickedFile.path);
                  _step = CreateStep.themeSelect;
              });
              
              // Wait for user to confirm style and tap magic button
          }
      } catch (e) {
          debugPrint("Error picking image: $e");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not pick image. Check permissions.")));
      }
  }

  // _showSourceSelector removed logic...

  // Get summary text for the style chip
  String _getStyleSummary() {
    if (_selectedMoods.isEmpty && _selectedStyles.isEmpty) {
      return "Random";
    }
    
    List<String> parts = [];
    if (_selectedMoods.isNotEmpty) {
      parts.addAll(_selectedMoods.map((k) => _moodOptions[k]?['label'] ?? k));
    }
    if (_selectedStyles.isNotEmpty) {
      parts.addAll(_selectedStyles.map((k) => _styleOptions[k]?['label'] ?? k));
    }
    
    if (parts.length > 2) {
      return "${parts.take(2).join(', ')} +${parts.length - 2}";
    }
    return parts.join(', ');
  }

  // Open compact bottom sheet for style selection
  void _openStyleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allow it to be taller if needed
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Customize Style", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  if (_selectedMoods.isNotEmpty || _selectedStyles.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMoods.clear();
                          _selectedStyles.clear();
                        });
                        setSheetState(() {});
                      },
                      child: Text(
                        "Reset",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Mood Section
              Text("Mood", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _moodOptions.entries.map((e) {
                  bool selected = _selectedMoods.contains(e.key);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _toggleMood(e.key));
                      setSheetState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.value['emoji'], style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            e.value['label'],
                            style: TextStyle(
                              color: selected ? Colors.black : Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Style Section
              Text("Style", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _styleOptions.entries.map((e) {
                  bool selected = _selectedStyles.contains(e.key);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _toggleStyle(e.key));
                      setSheetState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.value['emoji'], style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            e.value['label'],
                            style: TextStyle(
                              color: selected ? Colors.black : Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Caption section with toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Captions", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
                  Switch.adaptive(
                    value: _captionsEnabled,
                    activeColor: AppColors.accentBlue,
                    onChanged: (value) async {
                      setState(() => _captionsEnabled = value);
                      setSheetState(() {});
                      await LanguageService.setCaptionsEnabled(value);
                    },
                  ),
                ],
              ),
              
              // Language selector (only visible when captions enabled)
              AnimatedCrossFade(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: LanguageService.supportedLanguages.map((langCode) {
                        final isSelected = _selectedLanguage == langCode;
                        final langName = LanguageService.getLanguageName(langCode);
                        return GestureDetector(
                          onTap: () async {
                            setState(() => _selectedLanguage = langCode);
                            setSheetState(() {});
                            await LanguageService.setPreferredLanguage(langCode);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accentBlue.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? AppColors.accentBlue.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(langName, style: TextStyle(color: isSelected ? Colors.white : Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _captionsEnabled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),
              
              const SizedBox(height: 32),
              
              // Done Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show bottom sheet with mood/style options
  void _showCustomizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                "Customize",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Optional filters for your stickers",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              ),
              
              const SizedBox(height: 24),
              
              // Mood section
              Text("Mood", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _moodOptions.entries.map((e) {
                  bool selected = _selectedMoods.contains(e.key);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _toggleMood(e.key));
                      setSheetState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? (e.value['color'] as Color).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? (e.value['color'] as Color).withOpacity(0.4) : Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(e.value['label'], style: TextStyle(color: selected ? Colors.white : Colors.white.withOpacity(0.6), fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Style section
              Text("Style", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _styleOptions.entries.map((e) {
                  bool selected = _selectedStyles.contains(e.key);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _toggleStyle(e.key));
                      setSheetState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? (e.value['color'] as Color).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? (e.value['color'] as Color).withOpacity(0.4) : Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(e.value['label'], style: TextStyle(color: selected ? Colors.white : Colors.white.withOpacity(0.6), fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Caption section with toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Captions", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
                  Switch.adaptive(
                    value: _captionsEnabled,
                    activeColor: AppColors.accentBlue,
                    onChanged: (value) async {
                      setState(() => _captionsEnabled = value);
                      setSheetState(() {});
                      await LanguageService.setCaptionsEnabled(value);
                    },
                  ),
                ],
              ),
              
              // Language selector (only visible when captions enabled)
              AnimatedCrossFade(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: LanguageService.supportedLanguages.map((langCode) {
                        final isSelected = _selectedLanguage == langCode;
                        final langName = LanguageService.getLanguageName(langCode);
                        return GestureDetector(
                          onTap: () async {
                            setState(() => _selectedLanguage = langCode);
                            setSheetState(() {});
                            await LanguageService.setPreferredLanguage(langCode);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accentBlue.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.accentBlue.withOpacity(0.4) : Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(langName, style: TextStyle(color: isSelected ? Colors.white : Colors.white.withOpacity(0.6), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _captionsEnabled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),
              
              const SizedBox(height: 24),
              
              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for section labels
  Widget _buildSectionLabel(String title, String subtitle) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "($subtitle)",
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Helper widget for chip row
  Widget _buildChipRow(
    Map<String, Map<String, dynamic>> options,
    List<String> selectedList,
    Function(String) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        final key = entry.key;
        final data = entry.value;
        final isSelected = selectedList.contains(key);
        final chipColor = data['color'] as Color;

        return GestureDetector(
          onTap: () => onToggle(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? chipColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? chipColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? chipColor : chipColor.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  data['label'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Compact chip for inline row - minimal Apple style
  Widget _buildCompactChip(String label, Color color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected 
                ? color.withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _pollAndNavigate(String jobId) async {
        // Poll Status
        bool completed = false;
        int attempts = 0;
        final maxAttempts = 60; 
        
        // Optimistic UI updates - start progress immediately
        if (mounted) setState(() => _loadingProgress = "1/6");

        while (!completed && attempts < maxAttempts) {
            await Future.delayed(const Duration(seconds: 2));
            final status = await _api.checkJobStatus(jobId);
            print("DEBUG STATUS FULL: $status");
            print("DEBUG RESULT KEY: ${status.containsKey('result')}");
            print("DEBUG RESULT VAL: ${status['result']}");
            
            if (mounted && status['progress_count'] != null) {
                setState(() => _loadingProgress = status['progress_count']);
            }

            if (status['status'] == 'completed') {
                completed = true;
            } else if (status['status'] == 'failed') {
                 throw "Generation Failed";
            }
            attempts++;
        }

        if (mounted) {
            setState(() => _step = CreateStep.textInput); // Reset for next time

            final status = await _api.checkJobStatus(jobId);
            print("DEBUG STATUS: $status");
            if (status['result'] != null) {
                final res = status['result'];
                final List<dynamic> rawStickers = res['stickers'] ?? [];
                
                final newPack = StickerPack(
                  id: res['id'] ?? "gen_id",
                  title: res['title'] ?? "Fresh Drop",
                  createdAt: DateTime.now(),
                  coverImageId: rawStickers.isNotEmpty ? rawStickers[0]['id'] : '',
                  stickers: rawStickers.map((s) {
                      String typeStr = s['type'] ?? 'reaction';
                      StickerType type = StickerType.reaction;
                      if (typeStr == 'meme') type = StickerType.meme;
                      
                      return StickerAsset(
                        id: s['id'] ?? "unknown",
                        imageUrl: s['imageUrl'] ?? "", 
                        caption: s['caption'] ?? "",
                        type: type,
                        theme: s['theme'] ?? "general"
                      );
                  }).toList(),
                );
                
                // Save to persistent storage AND MockData (for session)
                await StorageService().savePack(newPack);
                MockData.addPack(newPack);

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => GenerationResultsScreen(pack: newPack)
                ));
            } else {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No result received.")));
            }
        }
  }

  void _startGeneration() async {
    if (_selectedImage == null) return;
    
    // Check subscription/trial limit before generating
    if (!_subscriptionService.canGenerate) {
      final subscribed = await TrialEndedScreen.show(context);
      if (!subscribed) return;
    }
    
    setState(() => _step = CreateStep.generating);
    try {
        // Get user's preferred language for captions
        final language = await LanguageService.getEffectiveLanguage();
        
        // Build params: mood,mood|style,style format
        String moodParam = _selectedMoods.isNotEmpty ? _selectedMoods.join(',') : 'random';
        String styleParam = _selectedStyles.isNotEmpty ? _selectedStyles.join(',') : 'random';
        final jobId = await _api.submitGenerationJob(
          _selectedImage!, 
          MockData.currentUser.id, 
          '$moodParam|$styleParam',
          language: language,
        );
        await _pollAndNavigate(jobId);
        
        // Increment generation count after successful generation
        await _subscriptionService.incrementGenerationCount();
    } catch (e) {
        if (mounted) {
            setState(() => _step = CreateStep.textInput);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
    }
  }

  void _startTextGeneration() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() => _step = CreateStep.generating);
    try {
        // Get user's preferred language for captions
        final language = await LanguageService.getEffectiveLanguage();
        
        // Build mood and style params (same as image generation)
        String moodParam = _selectedMoods.isNotEmpty ? _selectedMoods.join(',') : 'random';
        String styleParam = _selectedStyles.isNotEmpty ? _selectedStyles.join(',') : 'random';
        
        final jobId = await _api.submitTextGenerationJob(
          text, 
          tone: moodParam, 
          style: styleParam,
          language: language,
        );
        await _pollAndNavigate(jobId);
        
        // Increment generation count after successful generation
        await _subscriptionService.incrementGenerationCount();
    } catch (e) {
        if (mounted) {
            setState(() => _step = CreateStep.textInput); // Go back to text input on fail
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("XXX_DEBUG: CreateScreen build started. Step: $_step Image: $_selectedImage");
    Widget content;
    
    if (_step == CreateStep.generating) {
        content = _buildLoadingState();
    } else if (_step == CreateStep.themeSelect && _selectedImage != null) {
        content = _buildImageReviewState(); // New State
    } else {
        // VisionOS Inspired Layout
        content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 6),

              // 1. Header Title & Description
              const Text(
                "Generate Stickers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Instantly create personalized stickers using AI.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  height: 1.4
                ),
              ),

              const SizedBox(height: 32),

              // 2. Main Interaction Block
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasInput 
                        ? Colors.white.withOpacity(0.08) 
                        : (_shakeController.isAnimating ? Colors.red.withOpacity(0.5) : Colors.white.withOpacity(0.08))
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))
                    ]
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    onChanged: (text) => setState(() => _hasInput = text.trim().isNotEmpty),
                    controller: _textController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    cursorColor: AppColors.accentBlue,
                    decoration: InputDecoration(
                      hintText: "Type anything... e.g. 'a tired cat'",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14) 
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Mood/Style selector chip - opens full page selector
              GestureDetector(
                onTap: () => _openStyleSelector(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 16, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Text(
                        _getStyleSummary(),
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16, color: Colors.white.withOpacity(0.4)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Primary CTA
              Container(
                width: double.infinity,
                height: 48, 
                decoration: BoxDecoration(
                  color: AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(12), 
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue.withOpacity(0.35),
                      blurRadius: 16, 
                      offset: const Offset(0, 8)
                    )
                  ]
                ),
                child: ElevatedButton(
                  onPressed: _handleGeneratePress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)) 
                  ),
                  child: const Text(
                    "Generate Stickers", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 0.5
                    )
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Secondary Action
              TextButton(
                onPressed: _handleImageSelection,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.7),
                  splashFactory: NoSplash.splashFactory
                ),
                child: const Text("Or use a photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),

              const Spacer(flex: 4),
            ],
          ),
        );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
          children: [
             if (_step == CreateStep.textInput) ...[
                 const _FloatingSticker(path: 'assets/images/mock/float_3.png', size: 90, top: 110, left: -20, rotation: 0.15, opacity: 0.15),
                 const _FloatingSticker(path: 'assets/images/mock/float_2.png', size: 100, top: 80, right: -25, rotation: -0.1, blur: 1, opacity: 0.1),
                 
                 const _FloatingSticker(path: 'assets/images/mock/float_5.png', size: 85, top: 260, left: -30, rotation: -0.2, blur: 2, opacity: 0.05),
                 const _FloatingSticker(path: 'assets/images/mock/float_7.png', size: 70, top: 280, right: -20, rotation: 0.1, blur: 1.5, opacity: 0.05),

                 const _FloatingSticker(path: 'assets/images/mock/float_1.png', size: 75, top: 420, right: 10, rotation: 0.2, blur: 3, opacity: 0.05),
                 // Removed bottom stickers (float_4, float_6) - they were causing red appearance when keyboard opens
             ],
             SafeArea(
                 child: content,
             )
          ],
      )
    );
  }

  Widget _buildImageReviewState() {
     return Column(
       children: [
         // Custom Top Bar with Back Button
         Padding(
           padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
           child: Row(
             children: [
               GestureDetector(
                 onTap: () => setState(() { _step = CreateStep.textInput; _selectedImage = null; _selectedMoods.clear(); _selectedStyles.clear(); }),
                 child: Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.08),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.white.withOpacity(0.1)),
                   ),
                   child: Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.9), size: 18),
                 ),
               ),
               const Spacer(),
               // Optional: Can add a "Help" or "Info" icon here if needed
             ],
           ),
         ),
         
         const Spacer(flex: 2),

         // Modern Hero Photo Card
         Container(
           margin: const EdgeInsets.symmetric(horizontal: 20),
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: Colors.white.withOpacity(0.05),
             borderRadius: BorderRadius.circular(24),
             border: Border.all(color: Colors.white.withOpacity(0.1)),
             boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
             ]
           ),
           child: Column(
             children: [
               // Photo
               Container(
                 height: 320, // Taller and more prominent
                 width: double.infinity,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
                   border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                   image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
                 ),
               ),
               
               const SizedBox(height: 20),
               
               // Title & Subtitle inside card for tighter grouping
               const Text(
                 "Photo Selected",
                 style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 4),
               Text(
                 "Customize the style before generating",
                 style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
               ),
             ],
           ),
         ),
         
         const SizedBox(height: 24),
         
         // Style Selector (Modern Strip)
         GestureDetector(
             onTap: () => _openStyleSelector(context),
             child: Container(
               margin: const EdgeInsets.symmetric(horizontal: 40),
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.06),
                 borderRadius: BorderRadius.circular(16),
                 border: Border.all(color: Colors.white.withOpacity(0.1)),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.tune_rounded, size: 18, color: Colors.white.withOpacity(0.7)),
                   const SizedBox(width: 8),
                   Expanded(
                    child: Text(
                     _getStyleSummary(),
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                   ),
                   const SizedBox(width: 8),
                   Icon(Icons.keyboard_arrow_up_rounded, size: 20, color: Colors.white.withOpacity(0.5)),
                 ],
               ),
             ),
         ),
         
         const Spacer(flex: 3),
         
         // Big Create Button
         Container(
           margin: const EdgeInsets.symmetric(horizontal: 24),
           width: double.infinity,
           height: 56, 
           decoration: BoxDecoration(
              color: AppColors.accentBlue,
             borderRadius: BorderRadius.circular(16), 
             boxShadow: [
               BoxShadow(
                 color: AppColors.accentBlue.withOpacity(0.4),
                 blurRadius: 20, 
                 offset: const Offset(0, 10)
               )
             ]
           ),
           child: ElevatedButton(
             onPressed: _startGeneration,
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.transparent,
               shadowColor: Colors.transparent,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)) 
             ),
             child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    "Create Stickers", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 0.5
                    )
                  ),
                ],
             ),
           ),
         ),
         
         const SizedBox(height: 30), // Bottom padding
       ],
     );
  }

  Widget _buildLoadingState() {
     int progress = 0;
     if (_loadingProgress != null) {
        try {
           progress = int.parse(_loadingProgress!.split('/').first);
        } catch (e) {
           progress = 0;
        }
     }
     return _LoadingOverlay(progressCount: progress);
  }
}

class _LoadingOverlay extends StatefulWidget {
  final int progressCount;
  const _LoadingOverlay({this.progressCount = 0});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _msgIndex = 0;
  Timer? _timer;
  
  final List<String> _messages = [
      "Hiring digital artists...",
      "Mixing colors...",
      "Teaching AI some humor...",
      "Capturing your vibe...",
      "Adding final polish...",
      "Almost ready..."
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    // Faster cycling of messages for perceived speed
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        if (mounted) setState(() => _msgIndex = (_msgIndex + 1) % _messages.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            // GHOST GRID
            SizedBox(
              width: 280,
              height: 200, // Approx height for 2 rows
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                   return _buildGridItem(index);
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Witty Text
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                    _messages[_msgIndex],
                    key: ValueKey(_msgIndex),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                ),
            ),
            const SizedBox(height: 8),
            Text(
                "Generating sticker ${widget.progressCount + 1} of 6", 
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)
            ),
        ],
      ),
    );
  }

  Widget _buildGridItem(int index) {
      bool isCompleted = index < widget.progressCount;
      bool isProcessing = index == widget.progressCount;

      if (isCompleted) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.accentBlue.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 32),
          );
      } else if (isProcessing) {
          return FadeTransition(
            opacity: _controller,
            child: Container(
               decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentBlue.withOpacity(0.8), width: 2)
               ),
               child: const Center(
                 child: SizedBox(
                   width: 20, height: 20,
                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                 ),
               ),
            ),
          );
      } else {
          // Waiting
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1)
            ),
          );
      }
  }
}

class _FloatingSticker extends StatelessWidget {
  final String path;
  final double size;
  final double top;
  final double? left;
  final double? right;
  final double rotation;
  final double blur;
  final double opacity;

  const _FloatingSticker({
      super.key,
      required this.path, 
      required this.size, 
      required this.top, 
      this.left, 
      this.right, 
      this.rotation = 0,
      this.blur = 0,
      this.opacity = 1.0
  });

  @override
  Widget build(BuildContext context) {
      return Positioned(
          top: top,
          left: left,
          right: right,
          child: IgnorePointer(
            child: Transform.rotate(
                angle: rotation,
                child: Opacity(
                    opacity: opacity,
                    child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                        child: Image.asset(path, width: size, height: size, fit: BoxFit.contain)
                    )
                )
            ),
          )
      );
  }
}
