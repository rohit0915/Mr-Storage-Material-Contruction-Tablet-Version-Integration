import 'package:get/get.dart';
import '../controllers/dispatch_verification_controller.dart';

class DispatchVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DispatchVerificationController>(
      () => DispatchVerificationController(),
    );
  }
}
