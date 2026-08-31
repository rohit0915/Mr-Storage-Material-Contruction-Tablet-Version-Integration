import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import 'app_drawer.dart';
import 'app_shell_controller.dart';
import 'common_app_bar.dart';

/// Shared shell: fixed white app bar + notch, soft blue body background.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.menuTitle = 'Dashboard',
  });

  final Widget body;
  final String menuTitle;

  static const SystemUiOverlayStyle _statusStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppShellController>()) {
      Get.put(AppShellController(), permanent: true);
    }
    final shell = Get.find<AppShellController>();
    if (shell.selectedMenu.value != menuTitle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (shell.selectedMenu.value != menuTitle) {
          shell.selectedMenu.value = menuTitle;
        }
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _statusStyle,
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const AppDrawer(),
        drawerEnableOpenDragGesture: true,
        body: Column(
          children: [
            const ColoredBox(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: CommonAppBar(),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.dashboardBg,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
