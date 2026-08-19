import 'package:get/get.dart';

import '../controllers/delivery_tracking_controller.dart';

class DeliveryTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryTrackingController>(() => DeliveryTrackingController());
  }
}
