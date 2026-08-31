import 'package:get/get.dart';

import '../../features/auth/bindings/login_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/drawings/bindings/drawings_binding.dart';
import '../../features/drawings/views/drawings_view.dart';
import '../../features/project_calendar/bindings/project_calendar_binding.dart';
import '../../features/tasks/bindings/tasks_binding.dart';
import '../../features/tasks/views/tasks_view.dart';
import '../../features/bundle_scan/bindings/bundle_scan_binding.dart';
import '../../features/bundle_scan/views/bundle_scan_detail_view.dart';
import '../../features/bundle_scan/views/bundle_scan_view.dart';
import '../../features/packing_list/bindings/packing_list_binding.dart';
import '../../features/packing_list/views/packing_list_detail_view.dart';
import '../../features/packing_list/views/packing_list_view.dart';
import '../../features/delivery_tracking/bindings/delivery_tracking_binding.dart';
import '../../features/delivery_tracking/views/delivery_tracking_view.dart';
import '../../features/label_printing/bindings/label_printing_binding.dart';
import '../../features/label_printing/views/label_printing_view.dart';
import '../../features/material_requests/bindings/material_requests_binding.dart';
import '../../features/material_requests/views/material_requests_view.dart';
import '../../features/dispatch_verification/bindings/dispatch_verification_binding.dart';
import '../../features/dispatch_verification/views/dispatch_verification_detail_view.dart';
import '../../features/dispatch_verification/views/dispatch_verification_view.dart';
import '../../features/chat/bindings/chat_binding.dart';
import '../../features/chat/views/chat_view.dart';
import '../../features/notifications/bindings/notifications_binding.dart';
import '../../features/notifications/views/notifications_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/project_calendar/views/bom_file_details_view.dart';
import '../../features/project_calendar/views/delivery_details_view.dart';
import '../../features/project_calendar/views/project_details_view.dart';
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
      name: AppRoutes.projectDetails,
      page: () => const ProjectDetailsView(),
    ),
    GetPage(
      name: AppRoutes.bomFileDetails,
      page: () => const BomFileDetailsView(),
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
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TasksView(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: AppRoutes.materialRequests,
      page: () => const MaterialRequestsView(),
      binding: MaterialRequestsBinding(),
    ),
    GetPage(
      name: AppRoutes.labelPrinting,
      page: () => const LabelPrintingView(),
      binding: LabelPrintingBinding(),
    ),
    GetPage(
      name: AppRoutes.deliveryTracking,
      page: () => const DeliveryTrackingView(),
      binding: DeliveryTrackingBinding(),
    ),
    GetPage(
      name: AppRoutes.bundleScan,
      page: () => const BundleScanView(),
      binding: BundleScanBinding(),
    ),
    GetPage(
      name: AppRoutes.bundleScanDetail,
      page: () => const BundleScanDetailView(),
      binding: BundleScanBinding(),
    ),
    GetPage(
      name: AppRoutes.packingList,
      page: () => const PackingListView(),
      binding: PackingListBinding(),
    ),
    GetPage(
      name: AppRoutes.packingListDetail,
      page: () => const PackingListDetailView(),
      binding: PackingListBinding(),
    ),
    GetPage(
      name: AppRoutes.dispatchVerification,
      page: () => const DispatchVerificationView(),
      binding: DispatchVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.dispatchVerificationDetail,
      page: () => const DispatchVerificationDetailView(),
      binding: DispatchVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}

