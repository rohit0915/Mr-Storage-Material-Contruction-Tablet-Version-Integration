import 'package:get/get.dart';

import '../controllers/project_calendar_controller.dart';

class ProjectCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectCalendarController>(() => ProjectCalendarController());
  }
}
