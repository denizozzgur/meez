import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../data/models/user_profile.dart';
import '../creation/create_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;
  final List<String> _selectedContexts = [];
  String _selectedMood = '😀';
  String _selectedHumor = 'Relatable';

  void _nextStep() {
    setState(() {
      if (_step < 3) {
        _step++;
      } else {
        // Complete - Navigate to Create
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CreateScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (Simulated)
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF1A0033)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            )
          )),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _getTitleForStep(_step),
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  flex: 3,
                  child: _buildContentForStep(_step),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GlassCard(
                    isActive: true,
                    onTap: _nextStep,
                    child: const Center(
                      child: Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitleForStep(int step) {
    switch (step) {
      case 1: return "What describes your life right now?";
      case 2: return "What's your vibe?";
      case 3: return "Pick your humor.";
      default: return "";
    }
  }

  Widget _buildContentForStep(int step) {
    switch (step) {
      case 1:
        return GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: ["Work", "Coffee", "Tired", "Social", "Money", "Love"]
              .map((ctx) => GlassCard(
                isActive: _selectedContexts.contains(ctx),
                onTap: () => setState(() {
                  if (_selectedContexts.contains(ctx)) {
                    _selectedContexts.remove(ctx);
                  } else {
                    _selectedContexts.add(ctx);
                  }
                }),
                child: Center(child: Text(ctx, style: const TextStyle(color: Colors.white))),
              )).toList(),
        );
      case 2:
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: ['😀', '😭', '😡', '😴', '🤡', '🫠', '🙄', '😎']
              .map((emoji) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMood = emoji),
                  child: Container(
                    decoration: BoxDecoration(
                      border: _selectedMood == emoji ? Border.all(color: AppColors.accentBlue, width: 2) : null,
                      shape: BoxShape.circle
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(emoji, style: const TextStyle(fontSize: 48)),
                  ),
                ),
              )).toList(),
        );
      case 3:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: ["Relatable", "Sarcastic", "Deadpan", "Polite-Funny"]
              .map((tone) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  isActive: _selectedHumor == tone,
                  onTap: () => setState(() => _selectedHumor = tone),
                  child: Text(tone, style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              )).toList(),
        );
      default: return const SizedBox.shrink();
    }
  }
}
