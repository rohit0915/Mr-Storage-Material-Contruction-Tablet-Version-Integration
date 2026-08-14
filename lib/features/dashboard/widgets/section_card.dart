import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/dashboard_models.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      height: height,
      padding: padding ??
          EdgeInsets.all((size.width * 0.012).clamp(12.0, 16.0)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(DashboardGap.radius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
