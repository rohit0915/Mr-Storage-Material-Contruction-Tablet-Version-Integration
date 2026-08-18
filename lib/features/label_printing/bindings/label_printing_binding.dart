import 'package:get/get.dart';

import '../controllers/label_printing_controller.dart';

class LabelPrintingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LabelPrintingController>(() => LabelPrintingController());
  }
}
