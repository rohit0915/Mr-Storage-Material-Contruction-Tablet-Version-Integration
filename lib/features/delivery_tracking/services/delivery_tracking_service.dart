import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class DeliveryTrackingService extends GetxService {
  DeliveryTrackingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<dynamic> getDeliveries() async {
    try {
      final response = await _apiClient.get(ApiConstants.deliveries);
      AppLogger.i('Get Deliveries API Response: $response', tag: 'DELIVERY_SERVICE');
      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e, stackTrace) {
      AppLogger.e('getDeliveries Exception', error: e, stackTrace: stackTrace, tag: 'DELIVERY_SERVICE');
      return null;
    }
  }

  Future<bool> markReceived(String deliveryId) async {
    try {
      final res = await _apiClient.post(ApiConstants.markDeliveryReceived(deliveryId));
      return res is Map && (res['success'] == true || res.containsKey('data'));
    } catch (e) {
      return false;
    }
  }

  Future<bool> markPartial(String deliveryId, String notes) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.markDeliveryPartial(deliveryId),
        body: {'notes': notes},
      );
      return res is Map && (res['success'] == true || res.containsKey('data'));
    } catch (e) {
      return false;
    }
  }
}
