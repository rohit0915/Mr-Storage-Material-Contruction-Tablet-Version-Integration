import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class DeliveryTrackingService extends GetxService {
  DeliveryTrackingService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<dynamic> getDeliveries({String? leadId}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.deliveries,
        queryParams: leadId == null || leadId.isEmpty
            ? null
            : {'leadId': leadId},
      );
      var result = response;
      if (response is Map && response.containsKey('data')) {
        result = response['data'];
      }
      return result;
    } catch (e, stackTrace) {
      AppLogger.e(
        'getDeliveries Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'DELIVERY_SERVICE',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDeliveryDetail(String deliveryId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.deliveryDetail(deliveryId),
      );
      if (response is Map) {
        final data = response['data'] ?? response;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getDeliveryDetail Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'DELIVERY_SERVICE',
      );
    }
    return null;
  }

  Future<bool> markReceived(String deliveryId) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.markDeliveryReceived(deliveryId),
      );
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

  Future<bool> updateSiteContact(
    String deliveryId,
    Map<String, dynamic> contactData,
  ) async {
    try {
      final res = await _apiClient.put(
        ApiConstants.deliverySiteContact(deliveryId),
        body: contactData,
      );
      return res != null;
    } catch (e) {
      AppLogger.w('updateSiteContact Error: $e', tag: 'DELIVERY_SERVICE');
      return false;
    }
  }

  Future<bool> scanBundleQr(String code) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.deliveryScanBundle,
        body: {'bundleId': code},
      );
      return res != null;
    } catch (e) {
      AppLogger.w('scanBundleQr Error: $e', tag: 'DELIVERY_SERVICE');
      return false;
    }
  }

  Future<bool> scanQrCode(String code) => scanBundleQr(code);

  Future<String?> downloadPackingListPdf(String deliveryId) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.deliveryDownloadPackingList(deliveryId),
      );
      if (res is Map && res['url'] != null) {
        return res['url'].toString();
      }
    } catch (e) {
      AppLogger.w('downloadPackingListPdf Error: $e', tag: 'DELIVERY_SERVICE');
    }
    return null;
  }

  Future<String?> downloadBillOfLadingPdf(String deliveryId) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.deliveryDownloadBillOfLading(deliveryId),
      );
      if (res is Map && res['url'] != null) {
        return res['url'].toString();
      }
    } catch (e) {
      AppLogger.w('downloadBillOfLadingPdf Error: $e', tag: 'DELIVERY_SERVICE');
    }
    return null;
  }
}
