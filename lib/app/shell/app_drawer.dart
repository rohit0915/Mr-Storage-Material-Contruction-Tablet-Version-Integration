import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import '../walkthrough/controllers/walkthrough_controller.dart';
import '../walkthrough/services/walkthrough_registry.dart';
import 'app_shell_controller.dart';

class AppDrawer extends GetView<AppShellController> {
  const AppDrawer({super.key});

  static const _items = <_DrawerItem>[
    _DrawerItem(
      'Dashboard',
      Icons.home_outlined,
      WalkthroughRegistry.drawerItemDashboard,
    ),
    _DrawerItem(
      'Project & Calendar',
      Icons.calendar_month_outlined,
      WalkthroughRegistry.drawerItemProjectCalendar,
    ),
    _DrawerItem(
      'Drawings & Attachments',
      Icons.architecture_outlined,
      WalkthroughRegistry.drawerItemDrawings,
    ),
    _DrawerItem(
      'Tasks',
      Icons.checklist_rounded,
      WalkthroughRegistry.drawerItemTasks,
    ),
    _DrawerItem(
      'Material Request',
      Icons.grid_view_rounded,
      WalkthroughRegistry.drawerItemMaterialRequest,
    ),
    _DrawerItem(
      'Delivery Tracking',
      Icons.local_shipping_outlined,
      WalkthroughRegistry.drawerItemDeliveryTracking,
    ),
    _DrawerItem(
      'Dispatch Verification',
      Icons.fact_check_outlined,
      WalkthroughRegistry.drawerItemDispatchVerification,
    ),
    _DrawerItem(
      'Communication',
      Icons.chat_bubble_outline_rounded,
      WalkthroughRegistry.drawerItemCommunication,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final drawerWidth = (size.width * 0.28).clamp(290.0, 360.0);
    final titleSize = (size.width * 0.011).clamp(13.0, 15.0);
    final cardGap = (size.height * 0.01).clamp(8.0, 12.0);
    final logoHeight = (size.height * 0.045).clamp(32.0, 40.0);

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: AppColors.primaryBlue,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.012,
              size.height * 0.02,
              size.width * 0.012,
              size.height * 0.016,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KeyedSubtree(
                  key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.drawerHeader),
                  child: Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          AppAssets.drawerLogo,
                          height: logoHeight,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.close, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.018),

                // Interactive Walkthrough Banner Card in Drawer
                const _DrawerWalkthroughCard(),
                SizedBox(height: size.height * 0.012),

                // Navigation Items List
                Expanded(
                  child: Obx(() {
                    final selectedMenu = controller.selectedMenu.value;
                    return ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: cardGap),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return KeyedSubtree(
                          key: WalkthroughRegistry.instance.getKey(item.walkthroughKey),
                          child: _DrawerMenuCard(
                            title: item.title,
                            icon: item.icon,
                            selected: selectedMenu == item.title,
                            titleSize: titleSize,
                            onTap: () {
                              if (selectedMenu == item.title) {
                                Navigator.of(context).pop();
                                return;
                              }
                              controller.selectMenu(item.title);
                            },
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerWalkthroughCard extends StatelessWidget {
  const _DrawerWalkthroughCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Application Walkthrough',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Learn how to navigate projects, track dispatches, inspect drawings, and manage site tasks.',
            style: TextStyle(
              color: Color(0xFFDBEAFE),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                if (Get.isRegistered<WalkthroughController>()) {
                  WalkthroughController.to.showWelcomeModal(context);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 7.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 16,
                      color: Color(0xFF1E3A8A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Start Tour',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuCard extends StatelessWidget {
  const _DrawerMenuCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.titleSize,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final double titleSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Material(
      color: selected
          ? Colors.white.withValues(alpha: 0.24)
          : Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.012,
            vertical: size.height * 0.016,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.35 : 0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              SizedBox(width: size.width * 0.01),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem(this.title, this.icon, this.walkthroughKey);
  final String title;
  final IconData icon;
  final String walkthroughKey;
}
