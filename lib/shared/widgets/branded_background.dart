import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BrandedBackground extends StatelessWidget {
  final Widget? child;

  const BrandedBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Layer: Deep Slate / Black
        Container(
          height: double.infinity,
          width: double.infinity,
           decoration: const BoxDecoration(
             gradient: LinearGradient(
               colors: [Color(0xFF020617), Color(0xFF0F172A)], // Deepest Navy -> Slate 900
               begin: Alignment.topCenter,
               end: Alignment.bottomCenter
             )
           ),
        ),

        // 2. Ambient Orb: Top Right (Blue/Cyan)
        Positioned(
          top: -150,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withOpacity(0.2), 
                  blurRadius: 150, 
                  spreadRadius: 20
                )
              ]
            ),
          ),
        ),

        // 3. Ambient Orb: Bottom Left (Subtle purple)
        Positioned(
          bottom: -180,
          left: -120,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPurple.withOpacity(0.04), // More subtle
              boxShadow: [
                 BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.08), 
                  blurRadius: 150, 
                  spreadRadius: 20
                )
              ]
            ),
          ),
        ),

        // 4. Content
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}
