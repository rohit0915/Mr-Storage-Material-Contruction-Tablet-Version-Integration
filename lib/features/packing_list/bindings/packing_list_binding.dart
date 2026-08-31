import 'package:get/get.dart';
import '../controllers/packing_list_controller.dart';

class PackingListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackingListController>(() => PackingListController());
  }
}
