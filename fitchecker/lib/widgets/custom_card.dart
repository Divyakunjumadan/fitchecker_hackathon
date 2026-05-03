import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? color;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: padding ?? const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: color ?? AppColors.cardFill,
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.accent.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
