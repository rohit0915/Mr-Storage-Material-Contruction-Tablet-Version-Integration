import 'package:get/get.dart';

import '../controllers/bom_file_details_controller.dart';

class BomFileDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BomFileDetailsController>(() => BomFileDetailsController());
  }
}
