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
    if (args is Map) {
      deliveryId = (args['id'] ?? args['deliveryId'] ?? '').toString();
      _seedFromItem(args['item'] ?? args['delivery']);
    } else if (args != null) {
      _seedFromItem(args);
    }

    if (deliveryId.isEmpty) {
      deliveryId = value(['deliveryNumber', 'code', 'deliveryId'], fallback: 'DEL-0020');
    }

    if (delivery.isEmpty) {
      _seedDefaultData();
    }

    fetchDetails();
  }

  void _seedFromItem(dynamic item) {
    if (item == null) return;
    if (item is Map) {
      delivery.addAll(Map<String, dynamic>.from(item));
      return;
    }
    // Handle DeliveryItem model
    try {
      delivery.addAll({
        'deliveryNumber': (item as dynamic).id,
        'deliveryId': (item as dynamic).realMongoId.isNotEmpty ? (item as dynamic).realMongoId : (item as dynamic).id,
        'description': (item as dynamic).title,
        'materialType': '—',
        'status': (item as dynamic).status.name == 'staged'
            ? 'CONFIRMED'
            : (item as dynamic).status.name.toString().toUpperCase(),
        'priority': (item as dynamic).priority?.name ?? '—',
        'loadWeight': (item as dynamic).quantity,
        'stagingArea': (item as dynamic).stagingArea.isNotEmpty ? (item as dynamic).stagingArea : '—',
        'location': (item as dynamic).location,
        'destination': (item as dynamic).finalDestination.isNotEmpty ? (item as dynamic).finalDestination : (item as dynamic).location,
        'notes': (item as dynamic).notes.isNotEmpty ? (item as dynamic).notes : 'No special instructions provided.',
        'eta': (item as dynamic).eta,
        'project': {
          'projectName': (item as dynamic).project,
          'name': (item as dynamic).project,
          'jobId': (item as dynamic).jobId,
          'location': (item as dynamic).location,
        },
        'carrier': {
          'name': (item as dynamic).carrier,
          'carrierName': (item as dynamic).carrier,
          'driverName': (item as dynamic).driver,
          'phone': (item as dynamic).phone,
        },
        'siteContact': {
          'contactName': '—',
          'phone': (item as dynamic).phone.isNotEmpty && (item as dynamic).phone != '-' ? (item as dynamic).phone : 'gh',
          'role': 'Site Receiving Lead',
        },
        'schedule': {
          'arrivalAtPlant': (item as dynamic).arrivalAtPlant,
          'departureFromPlant': (item as dynamic).departureFromPlant,
          'deliveryDate': (item as dynamic).departureFromPlant.isNotEmpty ? (item as dynamic).departureFromPlant : 'Oct 22, 2026',
        },
      });
    } catch (_) {}
  }

  void _seedDefaultData() {
    delivery.assignAll({
      'deliveryNumber': 'DEL-0020',
      'deliveryId': 'DEL-0020',
      'description': '22 bundle(s) for bundle plan BP-0018',
      'status': 'CONFIRMED',
      'priority': '—',
      'project': {
        'projectName': 'Storage 0011',
        'name': 'Storage 0011',
      },
      'receivingPoc': '—',
      'deliveryDate': 'Oct 22, 2026',
      'timeWindow': '—',
      'siteDeliveryAddress': '—',
      'materialType': '—',
      'pickupDate': '—',
      'pickupTime': '—',
      'carrier': {
        'name': 'nads',
        'carrierName': 'nads',
        'phone': '—',
      },
      'loadWeight': '55,789.2 lbs',
      'packageCount': '—',
      'stagingArea': '—',
      'requiredLoadingEquipment': '—',
      'specialInstructions': 'No special instructions provided.',
      'siteContact': {
        'contactName': '—',
        'phone': 'gh',
        'role': 'Site Receiving Lead',
      },
      'origin': '—',
      'destination': '—',
    });
  }

  Future<void> fetchDetails() async {
    if (delivery.isEmpty) {
      isLoading.value = true;
    }
    try {
      final result = await _service.getDeliveryDetail(deliveryId);
      if (result != null) {
        final raw = result['delivery'] is Map
            ? result['delivery'] as Map
            : result;
        delivery.addAll(Map<String, dynamic>.from(raw));
      } else if (delivery.isEmpty) {
        _seedDefaultData();
      }
    } catch (error, stackTrace) {
      AppLogger.e(
        'Delivery detail fetch failed',
        error: error,
        stackTrace: stackTrace,
        tag: 'DELIVERY_DETAILS',
      );
      if (delivery.isEmpty) {
        _seedDefaultData();
      }
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
