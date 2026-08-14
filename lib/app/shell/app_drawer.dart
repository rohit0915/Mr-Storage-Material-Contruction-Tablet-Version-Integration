import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import 'app_shell_controller.dart';

class AppDrawer extends GetView<AppShellController> {
  const AppDrawer({super.key});

  static const _items = <_DrawerItem>[
    _DrawerItem('Dashboard', Icons.home_outlined),
    _DrawerItem('Project & Calendar', Icons.calendar_month_outlined),
    _DrawerItem('Drawings & Attachments', Icons.architecture_outlined),
    _DrawerItem('Tasks', Icons.checklist_rounded),
    _DrawerItem('Material Request', Icons.grid_view_rounded),
    _DrawerItem('Delivery Tracking', Icons.local_shipping_outlined),
    _DrawerItem('Label Printing', Icons.local_offer_outlined),
    _DrawerItem('Bundle Scan', Icons.qr_code_scanner_rounded),
    _DrawerItem('Packing List', Icons.inventory_2_outlined),
    _DrawerItem('Dispatch Verification', Icons.fact_check_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final drawerWidth = (size.width * 0.26).clamp(280.0, 340.0);
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
                Row(
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
                SizedBox(height: size.height * 0.022),
                Expanded(
                  child: Obx(() {
                    final selectedMenu = controller.selectedMenu.value;
                    return ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: cardGap),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _DrawerMenuCard(
                          title: item.title,
                          icon: item.icon,
                          selected: selectedMenu == item.title,
                          titleSize: titleSize,
                          onTap: () {
                            Navigator.of(context).pop();
                            controller.selectMenu(item.title);
                          },
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
  const _DrawerItem(this.title, this.icon);
  final String title;
  final IconData icon;
}
