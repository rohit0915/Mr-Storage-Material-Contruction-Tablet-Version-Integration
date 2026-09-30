import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../services/delivery_tracking_service.dart';

class DeliveryDetailsController extends GetxController {
  DeliveryDetailsController({DeliveryTrackingService? service})
    : _service = service ?? Get.put(DeliveryTrackingService());

  final DeliveryTrackingService _service;

  final isLoading = true.obs;
  final isActionLoading = false.obs;
  final delivery = <String, dynamic>{}.obs;
  String deliveryId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    deliveryId = args is Map
        ? (args['id'] ?? args['deliveryId'] ?? '').toString()
        : '';
    if (deliveryId.isEmpty) {
      isLoading.value = false;
      AppToast.showError(title: 'Delivery ID is missing');
      return;
    }
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    isLoading.value = true;
    try {
      final result = await _service.getDeliveryDetail(deliveryId);
      if (result == null) {
        delivery.clear();
        AppToast.showError(title: 'Unable to load delivery details');
        return;
      }
      final raw = result['delivery'] is Map
          ? result['delivery'] as Map
          : result;
      delivery.assignAll(Map<String, dynamic>.from(raw));
    } catch (error, stackTrace) {
      AppLogger.e(
        'Delivery detail fetch failed',
        error: error,
        stackTrace: stackTrace,
        tag: 'DELIVERY_DETAILS',
      );
      delivery.clear();
      AppToast.showError(title: 'Unable to load delivery details');
    } finally {
      isLoading.value = false;
    }
  }

  String get requestId =>
      value(['deliveryId', '_id', 'id'], fallback: deliveryId);

  String value(List<String> keys, {String fallback = '—'}) {
    for (final key in keys) {
      final candidate = delivery[key];
      if (candidate != null &&
          candidate.toString().trim().isNotEmpty &&
          candidate.toString() != 'null') {
        return candidate.toString();
      }
    }
    return fallback;
  }

  Map<String, dynamic> mapValue(List<String> keys) {
    for (final key in keys) {
      final candidate = delivery[key];
      if (candidate is Map) return Map<String, dynamic>.from(candidate);
    }
    return const {};
  }

  List<dynamic> listValue(List<String> keys) {
    for (final key in keys) {
      final candidate = delivery[key];
      if (candidate is List) return candidate;
    }
    return const [];
  }

  String nestedValue(
    Map<String, dynamic> source,
    List<String> keys, {
    String fallback = '—',
  }) {
    for (final key in keys) {
      final candidate = source[key];
      if (candidate != null &&
          candidate.toString().trim().isNotEmpty &&
          candidate.toString() != 'null') {
        return candidate.toString();
      }
    }
    return fallback;
  }

  Future<bool> markReceived() => _runAction(
    () => _service.markReceived(requestId),
    successMessage: 'Delivery marked as received',
  );

  Future<bool> markPartial(String notes) => _runAction(
    () => _service.markPartial(requestId, notes),
    successMessage: 'Partial receipt saved',
  );

  Future<bool> updateSiteContact(Map<String, dynamic> contact) => _runAction(
    () => _service.updateSiteContact(requestId, contact),
    successMessage: 'Site contact updated',
  );

  Future<void> downloadDocument(String type) async {
    isActionLoading.value = true;
    try {
      final url = type == 'bill-of-lading'
          ? await _service.downloadBillOfLadingPdf(requestId)
          : await _service.downloadPackingListPdf(requestId);
      if (url == null || url.isEmpty) {
        AppToast.showError(title: 'Document is not available');
      } else {
        AppToast.showSuccess(title: 'Download link received', description: url);
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> _runAction(
    Future<bool> Function() request, {
    required String successMessage,
  }) async {
    if (isActionLoading.value) return false;
    isActionLoading.value = true;
    try {
      final success = await request();
      if (!success) {
        AppToast.showError(
          title: 'Request failed',
          description: 'Please try again.',
        );
        return false;
      }
      await fetchDetails();
      AppToast.showSuccess(title: successMessage);
      return true;
    } finally {
      isActionLoading.value = false;
    }
  }
}
