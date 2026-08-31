import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:toastification/toastification.dart';

import 'app/routes/app_pages.dart';
import 'app/services/api_client.dart';
import 'app/shell/app_shell_controller.dart';
import 'app/theme/app_colors.dart';
import 'features/auth/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
    ),
  );

  final apiClient = ApiClient();
  await apiClient.init();
  Get.put(apiClient, permanent: true);

  Get.put(AuthService(), permanent: true);
  Get.put(AppShellController(), permanent: true);

  runApp(const SteelBuildingApp());
}

class SteelBuildingApp extends StatelessWidget {
  const SteelBuildingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: 'Steel Building Depot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: AppColors.dashboardBg,
        ),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
