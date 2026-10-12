import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:toastification/toastification.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/api_client.dart';
import 'app/services/construction_socket_service.dart';
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

  final socketService = Get.put(ConstructionSocketService(), permanent: true);
  if (apiClient.token != null && apiClient.token!.isNotEmpty) {
    socketService.connect();
  }

  final authService = Get.put(AuthService(), permanent: true);
  Get.put(AppShellController(), permanent: true);

  final initialRoute =
      authService.isLoggedIn ? AppRoutes.dashboard : AppRoutes.login;

  runApp(SteelBuildingApp(initialRoute: initialRoute));
}

class SteelBuildingApp extends StatelessWidget {
  const SteelBuildingApp({super.key, this.initialRoute = AppRoutes.login});

  final String initialRoute;

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
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}
