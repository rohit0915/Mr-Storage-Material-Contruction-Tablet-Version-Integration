import 'package:get/get.dart';

import '../controllers/material_requests_controller.dart';

class MaterialRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MaterialRequestsController>(() => MaterialRequestsController());
  }
}

