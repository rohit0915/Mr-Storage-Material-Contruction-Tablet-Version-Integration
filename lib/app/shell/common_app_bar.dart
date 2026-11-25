import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/services/auth_service.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../walkthrough/controllers/walkthrough_controller.dart';
import '../walkthrough/sequences/app_walkthrough_catalog.dart';
import '../walkthrough/services/walkthrough_registry.dart';
import 'app_shell_controller.dart';

/// Common fixed app bar used on all main screens.
class CommonAppBar extends GetView<AppShellController> {
  const CommonAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final nameSize = (size.width * 0.014).clamp(14.0, 18.0);
    final emailSize = (size.width * 0.010).clamp(11.0, 13.0);
    final iconBox = (size.width * 0.028).clamp(36.0, 44.0);
    final gap = (size.width * 0.012).clamp(10.0, 16.0);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: gap * 1.2,
        vertical: size.height * 0.012,
      ),
      child: Row(
        children: [
          KeyedSubtree(
            key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.appBarMenu),
            child: InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: iconBox * 0.5,
                ),
              ),
            ),
          ),
          SizedBox(width: gap),
          KeyedSubtree(
            key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.appBarGreeting),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${Get.isRegistered<AuthService>() ? AuthService.to.userName : 'User'}!',
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  Get.isRegistered<AuthService>() ? AuthService.to.userEmail : '',
                  style: TextStyle(
                    fontSize: emailSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Guided Tour button
          InkWell(
            onTap: () {
              if (Get.isRegistered<WalkthroughController>()) {
                WalkthroughController.to.showWelcomeModal(context);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Tooltip(
              message: 'Interactive Guided Tour',
              child: _CircleAction(
                icon: Icons.tour_rounded,
                size: iconBox,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.006),
          KeyedSubtree(
            key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.appBarNotifications),
            child: InkWell(
              onTap: () => Get.toNamed(AppRoutes.notifications),
              borderRadius: BorderRadius.circular(20),
              child: _CircleAction(
                icon: Icons.notifications_none_rounded,
                size: iconBox,
                showBadge: true,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.006),
          KeyedSubtree(
            key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.appBarProfile),
            child: InkWell(
              onTap: () => Get.toNamed(AppRoutes.profile),
              borderRadius: BorderRadius.circular(20),
              child: _CircleAction(icon: Icons.person_outline, size: iconBox),
            ),
          ),
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
