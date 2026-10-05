import 'package:get/get.dart';
import '../controllers/bundle_scan_controller.dart';
import '../controllers/bundle_scan_detail_controller.dart';

class BundleScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BundleScanController>(() => BundleScanController());
    Get.lazyPut<BundleScanDetailController>(() => BundleScanDetailController());
  }
}
