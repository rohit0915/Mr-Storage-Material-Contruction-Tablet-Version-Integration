import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';

/// Figma-style colored square with white clock/history icon.
class StatIconBox extends StatelessWidget {
  const StatIconBox({
    super.key,
    required this.color,
    this.icon,
    this.size,
  });

  final Color color;
  final IconData? icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final box = size ?? (mq.width * 0.028).clamp(32.0, 40.0);

    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DashboardGap.radius),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon ?? Icons.history_rounded,
        color: Colors.white,
        size: box * 0.58,
      ),
    );
  }
}
