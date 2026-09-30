import 'package:get/get.dart';

import '../controllers/delivery_tracking_controller.dart';
import '../controllers/delivery_details_controller.dart';
import '../services/delivery_tracking_service.dart';

class DeliveryTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryTrackingService>(
      () => DeliveryTrackingService(),
      fenix: true,
    );
    Get.lazyPut<DeliveryTrackingController>(() => DeliveryTrackingController());
  }
}

class DeliveryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryTrackingService>(
      () => DeliveryTrackingService(),
      fenix: true,
    );
    Get.lazyPut<DeliveryDetailsController>(() => DeliveryDetailsController());
  }
}
