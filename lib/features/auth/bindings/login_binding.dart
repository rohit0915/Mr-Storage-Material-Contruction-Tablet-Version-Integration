import 'package:get/get.dart';

import '../../../app/services/api_client.dart';
import '../controllers/login_controller.dart';
import '../services/auth_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
