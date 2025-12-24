import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../creation/create_screen.dart';
import '../library/packs_screen.dart';
import '../community/community_screen.dart';
import '../../shared/widgets/branded_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Start at Create (Center)

  List<Widget> get _screens => [
    const CommunityScreen(), // 0
    const CreateScreen(),    // 1
    PacksScreen( // 2
      onGoToCreate: () => setState(() => _currentIndex = 1),
      onGoToCommunity: () => setState(() => _currentIndex = 0),
    ),     
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // For glass effect behind nav bar
      body: BrandedBackground(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(24),
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.9), // Slate 800
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.explore_outlined, 
              isActive: _currentIndex == 0, 
              onTap: () => setState(() => _currentIndex = 0)
            ),
            _NavItem(
              icon: Icons.auto_awesome, 
              isActive: _currentIndex == 1, 
              isCenter: true,
              onTap: () => setState(() => _currentIndex = 1)
            ),
            _NavItem(
              icon: Icons.history_toggle_off_outlined, 
              isActive: _currentIndex == 2, 
              onTap: () => setState(() => _currentIndex = 2)
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isCenter;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.isActive, this.isCenter = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accentBlue : Colors.white.withOpacity(0.4);
    
    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : AppColors.accentBlue,
            boxShadow: [BoxShadow(color: AppColors.accentBlue.withOpacity(0.5), blurRadius: 15)]
          ),
          child: Icon(icon, color: isActive ? AppColors.accentBlue : Colors.white, size: 28),
        ),
      );
    }

    return IconButton(
      icon: Icon(icon, color: color, size: 28),
      onPressed: onTap,
    );
  }
}
