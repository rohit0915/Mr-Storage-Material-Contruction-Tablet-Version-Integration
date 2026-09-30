import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import '../services/notifications_service.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsService>(() => NotificationsService());
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(service: Get.find<NotificationsService>()),
    );
  }
}
