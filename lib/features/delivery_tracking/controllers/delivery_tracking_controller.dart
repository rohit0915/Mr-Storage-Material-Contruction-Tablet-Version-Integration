import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../models/delivery_tracking_models.dart';
import '../services/delivery_tracking_service.dart';

class DeliveryTrackingController extends GetxController {
  DeliveryTrackingController({DeliveryTrackingService? service})
      : _service = service ?? Get.put(DeliveryTrackingService());

  final DeliveryTrackingService _service;

  final isLoading = false.obs;
  final deliveries = <DeliveryItem>[].obs;

  final apiInTransit = 0.obs;
  final apiStaged = 0.obs;
  final apiReady = 0.obs;
  final apiTotalToday = 0.obs;

  int get inTransitCount => apiInTransit.value > 0
      ? apiInTransit.value
      : deliveries.where((d) => d.status == DeliveryStatus.inTransit).length;

  int get stagedCount => apiStaged.value > 0
      ? apiStaged.value
      : deliveries.where((d) => d.status == DeliveryStatus.staged).length;

  int get readyCount => apiReady.value > 0
      ? apiReady.value
      : deliveries.where((d) => d.status == DeliveryStatus.ready).length;

  int get totalToday => apiTotalToday.value > 0
      ? apiTotalToday.value
      : deliveries.length;

  @override
  void onInit() {
    super.onInit();
    fetchDeliveries();
  }

  Future<void> fetchDeliveries() async {
    isLoading.value = true;
    try {
      final res = await _service.getDeliveries();
      if (res != null) {
        List list = [];
        if (res is Map) {
          if (res['deliveries'] is List) {
            list = res['deliveries'] as List;
          }
          if (res['stats'] is Map) {
            final st = res['stats'] as Map;
            apiInTransit.value = (st['inTransit'] as int?) ?? 0;
            apiStaged.value = (st['staged'] as int?) ?? 0;
            apiReady.value = (st['ready'] as int?) ?? 0;
            apiTotalToday.value = (st['totalToday'] as int?) ?? 0;
          }
        } else if (res is List) {
          list = res;
        }

        final parsed = <DeliveryItem>[];
        for (final item in list) {
          if (item is Map) {
            parsed.add(DeliveryItem.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        deliveries.assignAll(parsed);
      }
    } catch (e, stackTrace) {
      AppLogger.e('fetchDeliveries Error', error: e, stackTrace: stackTrace, tag: 'DELIVERY_CTRL');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markReceived(String id) async {
    final idx = deliveries.indexWhere((d) => d.id == id || d.realMongoId == id);
    if (idx >= 0) {
      final target = deliveries[idx];
      deliveries[idx] = target.copyWith(status: DeliveryStatus.delivered);
      final reqId = target.realMongoId.isNotEmpty ? target.realMongoId : target.id;
      await _service.markReceived(reqId);
    }
  }

  Future<void> markPartialReceived(String id) async {
    final idx = deliveries.indexWhere((d) => d.id == id || d.realMongoId == id);
    if (idx >= 0) {
      final target = deliveries[idx];
      deliveries[idx] = target.copyWith(status: DeliveryStatus.staged);
      final reqId = target.realMongoId.isNotEmpty ? target.realMongoId : target.id;
      await _service.markPartial(reqId, 'Partial received');
    }
  }
}
