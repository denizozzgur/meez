import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool isActive;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.onTap,
    this.isActive = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassTheme.blurAmount, 
            sigmaY: GlassTheme.blurAmount
          ),
          child: Container(
            width: width,
            height: height,
            decoration: isActive 
                ? GlassTheme.glassDecorationActive 
                : GlassTheme.glassDecoration,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
