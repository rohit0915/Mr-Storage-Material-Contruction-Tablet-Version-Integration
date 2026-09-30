import 'package:flutter/material.dart';
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
  String leadId = '';
  String scopedProject = '';
  String scopedJobId = '';
  bool isProjectScoped = false;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatus = 'All Statuses'.obs;

  final isFilterByProjectOnly = false.obs;

  List<DeliveryItem> get projectDeliveries {
    if (!isProjectScoped) return deliveries;
    return deliveries.where((d) {
      if (scopedJobId.isNotEmpty &&
          (d.jobId.toLowerCase().contains(scopedJobId.toLowerCase()) ||
              d.project.toLowerCase().contains(scopedJobId.toLowerCase())))
        return true;
      if (scopedProject.isNotEmpty &&
          d.project.toLowerCase().contains(scopedProject.toLowerCase()))
        return true;
      if (leadId.isNotEmpty && (d.realMongoId == leadId || d.id == leadId))
        return true;
      return false;
    }).toList();
  }

  bool get projectHasDeliveries => projectDeliveries.isNotEmpty;

  List<DeliveryItem> get baseDeliveries {
    if (isProjectScoped &&
        projectHasDeliveries &&
        !isFilterByProjectOnly.value) {
      return projectDeliveries;
    }
    if (isProjectScoped && isFilterByProjectOnly.value) {
      return projectDeliveries;
    }
    return deliveries;
  }

  List<DeliveryItem> get filteredDeliveries {
    var list = List<DeliveryItem>.from(baseDeliveries);

    if (selectedStatus.value != 'All Statuses') {
      final filterText = selectedStatus.value.toLowerCase();
      list = list
          .where((d) => d.status.name.toLowerCase().contains(filterText))
          .toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (d) =>
                d.id.toLowerCase().contains(q) ||
                d.title.toLowerCase().contains(q) ||
                d.project.toLowerCase().contains(q) ||
                d.jobId.toLowerCase().contains(q) ||
                d.driver.toLowerCase().contains(q) ||
                d.truck.toLowerCase().contains(q) ||
                d.carrier.toLowerCase().contains(q) ||
                d.location.toLowerCase().contains(q) ||
                d.finalDestination.toLowerCase().contains(q) ||
                d.status.name.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  void onSearch(String val) {
    searchQuery.value = val;
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void toggleProjectFilter(bool onlyProject) {
    isFilterByProjectOnly.value = onlyProject;
  }

  final hasApiStats = false.obs;
  final apiInTransit = 0.obs;
  final apiStaged = 0.obs;
  final apiReady = 0.obs;
  final apiTotalToday = 0.obs;

  int get inTransitCount => hasApiStats.value
      ? apiInTransit.value
      : baseDeliveries
            .where((d) => d.status == DeliveryStatus.inTransit)
            .length;

  int get stagedCount => hasApiStats.value
      ? apiStaged.value
      : baseDeliveries.where((d) => d.status == DeliveryStatus.staged).length;

  int get readyCount => hasApiStats.value
      ? apiReady.value
      : baseDeliveries.where((d) => d.status == DeliveryStatus.ready).length;

  int get totalToday => hasApiStats.value
      ? apiTotalToday.value
      : baseDeliveries.where((d) {
          final eta = d.eta.toLowerCase();
          final arrival = d.arrivalAtPlant.toLowerCase();
          return eta.contains('today') || arrival.contains('today');
        }).length;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      leadId = (args['leadId'] ?? '').toString();
      scopedProject = (args['project'] ?? '').toString();
      scopedJobId = (args['jobId'] ?? '').toString();
      isProjectScoped =
          args['fromProject'] == true ||
          leadId.isNotEmpty ||
          scopedJobId.isNotEmpty;
    }
    fetchDeliveries();
  }

  Future<void> fetchDeliveries() async {
    isLoading.value = true;
    try {
      final res = await _service.getDeliveries(leadId: leadId);
      if (res != null) {
        List list = [];
        if (res is Map) {
          if (res['deliveries'] is List) {
            list = res['deliveries'] as List;
          }
          if (res['stats'] is Map) {
            final st = res['stats'] as Map;
            apiInTransit.value = (st['inTransit'] as num?)?.toInt() ?? 0;
            apiStaged.value = (st['staged'] as num?)?.toInt() ?? 0;
            apiReady.value = (st['ready'] as num?)?.toInt() ?? 0;
            apiTotalToday.value = (st['totalToday'] as num?)?.toInt() ?? 0;
            hasApiStats.value = true;
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
      AppLogger.e(
        'fetchDeliveries Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'DELIVERY_CTRL',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markReceived(String id) async {
    final idx = deliveries.indexWhere((d) => d.id == id || d.realMongoId == id);
    if (idx >= 0) {
      final target = deliveries[idx];
      deliveries[idx] = target.copyWith(status: DeliveryStatus.delivered);
      final reqId = target.realMongoId.isNotEmpty
          ? target.realMongoId
          : target.id;
      final success = await _service.markReceived(reqId);
      if (!success) {
        deliveries[idx] = target;
      } else {
        await fetchDeliveries();
      }
    }
  }

  Future<void> markPartialReceived(String id) async {
    final idx = deliveries.indexWhere((d) => d.id == id || d.realMongoId == id);
    if (idx >= 0) {
      final target = deliveries[idx];
      deliveries[idx] = target.copyWith(status: DeliveryStatus.staged);
      final reqId = target.realMongoId.isNotEmpty
          ? target.realMongoId
          : target.id;
      final success = await _service.markPartial(reqId, 'Partial received');
      if (!success) {
        deliveries[idx] = target;
      } else {
        await fetchDeliveries();
      }
    }
  }

  Future<DeliveryItem?> getDeliveryDetail(String id) async {
    final local = deliveries.firstWhereOrNull(
      (d) => d.id == id || d.realMongoId == id,
    );
    final requestId = local?.realMongoId.isNotEmpty == true
        ? local!.realMongoId
        : id;
    final data = await _service.getDeliveryDetail(requestId);
    return data == null ? local : DeliveryItem.fromJson(data);
  }

  Future<bool> updateSiteContact(
    String id,
    Map<String, dynamic> contactData,
  ) async {
    final idx = deliveries.indexWhere((d) => d.id == id || d.realMongoId == id);
    final reqId = idx >= 0 && deliveries[idx].realMongoId.isNotEmpty
        ? deliveries[idx].realMongoId
        : id;
    return await _service.updateSiteContact(reqId, contactData);
  }

  Future<bool> scanQrCode(String code) async {
    return await _service.scanQrCode(code);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
