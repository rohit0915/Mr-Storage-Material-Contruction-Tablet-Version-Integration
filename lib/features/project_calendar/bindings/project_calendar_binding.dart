import 'package:get/get.dart';

import '../controllers/project_calendar_controller.dart';
import '../services/project_progress_service.dart';

class ProjectCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectProgressService>(
      () => ProjectProgressService(),
      fenix: true,
    );
    Get.lazyPut<ProjectCalendarController>(
      () => ProjectCalendarController(),
      fenix: true,
    );
  }
}
