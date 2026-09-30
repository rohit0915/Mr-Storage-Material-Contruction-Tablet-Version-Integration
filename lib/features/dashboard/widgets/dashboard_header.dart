import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';

/// Fixed white app bar (Figma): blue menu button opens left drawer.
class DashboardHeader extends GetView<DashboardController> {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final nameSize = (size.width * 0.014).clamp(14.0, 18.0);
    final emailSize = (size.width * 0.010).clamp(11.0, 13.0);
    final iconBox = (size.width * 0.028).clamp(36.0, 44.0);
    final gap = DashboardGap.page(context);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: gap * 1.2,
        vertical: size.height * 0.012,
      ),
      child: Row(
        children: [
          // Blue rounded menu button → opens drawer
          InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.menu, color: Colors.white, size: iconBox * 0.5),
            ),
          ),
          SizedBox(width: gap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, John!',
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'construction@steelbuilding.depot',
                style: TextStyle(
                  fontSize: emailSize,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Container(
              height: iconBox,
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.012),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: emailSize + 1,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
          SizedBox(width: gap),
          _CircleAction(
            icon: Icons.notifications_none_rounded,
            size: iconBox,
            showBadge: true,
          ),
          SizedBox(width: size.width * 0.006),
          _CircleAction(icon: Icons.person_outline, size: iconBox),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.size,
    this.showBadge = false,
  });

  final IconData icon;
  final double size;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: size * 0.48, color: AppColors.primaryBlue),
        ),
        if (showBadge)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
