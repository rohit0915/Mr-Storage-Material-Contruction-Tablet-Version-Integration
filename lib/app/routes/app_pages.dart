import 'package:get/get.dart';

import '../../features/auth/bindings/login_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/drawings/bindings/drawings_binding.dart';
import '../../features/drawings/views/drawings_view.dart';
import '../../features/project_calendar/bindings/project_calendar_binding.dart';
import '../../features/project_calendar/views/delivery_details_view.dart';
import '../../features/project_calendar/views/project_calendar_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.login;

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.projectCalendar,
      page: () => const ProjectCalendarView(),
      binding: ProjectCalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.deliveryDetails,
      page: () => const DeliveryDetailsView(),
    ),
    GetPage(
      name: AppRoutes.drawings,
      page: () => const DrawingsView(),
      binding: DrawingsBinding(),
    ),
  ];
}
