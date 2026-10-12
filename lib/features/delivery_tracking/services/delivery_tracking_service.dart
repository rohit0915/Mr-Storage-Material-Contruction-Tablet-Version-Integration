import 'dart:typed_data';

import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class DeliveryTrackingService extends GetxService {
  DeliveryTrackingService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<dynamic> getDeliveries({
    String? leadId,
    String? search,
    String? status,
    String? sortBy,
    String? materialType,
    String? siteDestination,
    String? transporter,
    String? driver,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (leadId != null && leadId.isNotEmpty) queryParams['leadId'] = leadId;
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (status != null && status.isNotEmpty && status != 'All Statuses') {
        queryParams['status'] = status;
      }
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (materialType != null && materialType.trim().isNotEmpty) {
        queryParams['materialType'] = materialType.trim();
      }
      if (siteDestination != null && siteDestination.trim().isNotEmpty && siteDestination != 'All Destinations') {
        queryParams['siteDestination'] = siteDestination.trim();
      }
      if (transporter != null && transporter.trim().isNotEmpty && transporter != 'All Transporters') {
        queryParams['transporter'] = transporter.trim();
      }
      if (driver != null && driver.trim().isNotEmpty && driver != 'All Drivers') {
        queryParams['driver'] = driver.trim();
      }
      if (startDate != null && startDate.isNotEmpty) queryParams['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['endDate'] = endDate;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiClient.get(
        ApiConstants.deliveries,
        queryParams: queryParams.isEmpty ? null : queryParams,
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

  Future<dynamic> getProjectMaterialDeliveries(String leadId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.projectMaterialDeliveries(leadId),
      );
      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e) {
      AppLogger.w(
        'getProjectMaterialDeliveries failed: $e',
        tag: 'DELIVERY_SERVICE',
      );
      return null;
    }
  }

  Future<dynamic> getProjectDetails(String leadId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.projectDetails(leadId),
      );
      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e) {
      AppLogger.w(
        'getProjectDetails failed: $e',
        tag: 'DELIVERY_SERVICE',
      );
      return null;
    }
  }

  Future<List<Map<String, String>>> getProjects() async {
    final merged = <String, Map<String, String>>{};
    const defaultProjects = [
      {
        'id': 'lead-0011',
        'name': 'Storage 0011',
        'jobId': '2026014',
      },
      {
        'id': 'lead-namra-01',
        'name': 'Storage Namra LLC 01',
        'jobId': 'LOAD-001',
      },
      {
        'id': 'lead-002',
        'name': 'Lucas project',
        'jobId': 'PRO-002',
      },
      {
        'id': 'lead-042',
        'name': 'Adam Gilchrist',
        'jobId': 'PRO-042',
      },
    ];

    for (final def in defaultProjects) {
      merged[def['name']!] = {
        'id': def['id']!,
        'name': def['name']!,
        'jobId': def['jobId']!,
      };
    }

    void addProjectItem(Map item) {
      final id = (item['_id'] ?? item['id'] ?? '').toString();
      final name = (item['projectName'] ?? item['name'] ?? item['title'] ?? '').toString();
      final jobId = (item['jobId'] ?? item['code'] ?? '').toString();
      final leadId = (item['leadId'] ?? item['lead']?['_id'] ?? item['lead']?['id'] ?? '').toString();
      final buildingType = (item['buildingType'] ?? '').toString();
      final location = (item['location'] ?? '').toString();

      String label = name;
      if (label.isEmpty) {
        if (buildingType.isNotEmpty && location.isNotEmpty) {
          label = '$buildingType - $location';
        } else if (jobId.isNotEmpty) {
          label = 'Project #$jobId';
        }
      }

      if (label.isNotEmpty) {
        merged[label] = {
          'id': id.isNotEmpty ? id : 'lead-$label',
          'name': label,
          'jobId': jobId,
          'leadId': leadId,
        };
      }
    }

    try {
      final res = await _apiClient.get(
        ApiConstants.projects,
        queryParams: const {'page': '1', 'limit': '100'},
      );
      List items = [];
      if (res is Map) {
        if (res['data'] is Map && res['data']['projects'] is List) {
          items = res['data']['projects'] as List;
        } else if (res['projects'] is List) {
          items = res['projects'] as List;
        } else if (res['data'] is List) {
          items = res['data'] as List;
        }
      } else if (res is List) {
        items = res;
      }
      for (final item in items) {
        if (item is Map) addProjectItem(item);
      }
    } catch (_) {}

    return merged.values.toList();
  }

  Future<Map<String, dynamic>?> getDeliveryFilters() async {
    try {
      final res = await _apiClient.get(ApiConstants.deliveryFilters);
      if (res is Map && res['data'] is Map) {
        return Map<String, dynamic>.from(res['data']);
      }
      if (res is Map) {
        return Map<String, dynamic>.from(res);
      }
    } catch (e) {
      AppLogger.w('getDeliveryFilters failed: $e', tag: 'DELIVERY_SERVICE');
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

  Future<bool> scanBundleQr(String code, {String? projectId}) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.deliveryScanBundle,
        body: {
          'bundleId': code,
          if (projectId != null && projectId.isNotEmpty) 'project': projectId,
        },
      );
      return res != null;
    } catch (e) {
      AppLogger.w('scanBundleQr Error: $e', tag: 'DELIVERY_SERVICE');
      return false;
    }
  }

  Future<bool> scanQrCode(String code, {String? projectId}) => scanBundleQr(code, projectId: projectId);

  Future<Uint8List?> downloadPackingListBytes(String deliveryId) async {
    try {
      return await _apiClient.getBytes(
        ApiConstants.deliveryDownloadPackingList(deliveryId),
      );
    } catch (e) {
      AppLogger.w('downloadPackingListBytes Error: $e', tag: 'DELIVERY_SERVICE');
    }
    return null;
  }

  Future<Uint8List?> downloadBillOfLadingBytes(String deliveryId) async {
    try {
      return await _apiClient.getBytes(
        ApiConstants.deliveryDownloadBillOfLading(deliveryId),
      );
    } catch (e) {
      AppLogger.w('downloadBillOfLadingBytes Error: $e', tag: 'DELIVERY_SERVICE');
    }
    return null;
  }

  Future<String?> downloadPackingListPdf(String deliveryId) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.deliveryDownloadPackingList(deliveryId),
      );
      if (res is Map) {
        final url = res['url'] ??
            res['downloadUrl'] ??
            res['fileUrl'] ??
            res['data']?['url'] ??
            res['data']?['downloadUrl'] ??
            res['data']?['fileUrl'] ??
            res['pdfUrl'];
        if (url != null && url.toString().isNotEmpty) {
          return url.toString();
        }
      } else if (res is String && res.startsWith('http')) {
        return res;
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
      if (res is Map) {
        final url = res['url'] ??
            res['downloadUrl'] ??
            res['fileUrl'] ??
            res['data']?['url'] ??
            res['data']?['downloadUrl'] ??
            res['data']?['fileUrl'] ??
            res['pdfUrl'];
        if (url != null && url.toString().isNotEmpty) {
          return url.toString();
        }
      } else if (res is String && res.startsWith('http')) {
        return res;
      }
    } catch (e) {
      AppLogger.w('downloadBillOfLadingPdf Error: $e', tag: 'DELIVERY_SERVICE');
    }
    return null;
  }
}
