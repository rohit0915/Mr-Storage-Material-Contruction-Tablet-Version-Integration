import 'package:get/get.dart';

import '../controllers/drawings_controller.dart';

class DrawingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrawingsController>(() => DrawingsController());
  }
}
