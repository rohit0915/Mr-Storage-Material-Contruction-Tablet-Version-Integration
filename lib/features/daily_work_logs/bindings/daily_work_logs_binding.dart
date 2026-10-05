import 'package:get/get.dart';

import '../controllers/daily_work_logs_controller.dart';
import '../services/work_logs_service.dart';

class DailyWorkLogsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkLogsService>(() => WorkLogsService());
    Get.lazyPut<DailyWorkLogsController>(() => DailyWorkLogsController());
  }
}
