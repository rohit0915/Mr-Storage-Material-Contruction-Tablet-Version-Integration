import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class MaterialRequestsService extends GetxService {
  MaterialRequestsService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final res = await _apiClient.get(
        ApiConstants.projects,
        queryParams: const {'page': '1', 'limit': '100'},
      );
      final data = res is Map ? res['data'] : null;
      final items = data is Map ? data['projects'] : null;
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getProjects Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return const [];
  }

  Future<Map<String, dynamic>?> getMaterialRequests({
    int page = 1,
    int limit = 10,
    String? project,
    String? department,
    String? status,
    String? requestedBy,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final query = <String, String>{};
      query['page'] = page.toString();
      query['limit'] = limit.toString();
      if (project != null && project.isNotEmpty && project != 'All Projects') {
        query['project'] = project;
      }
      if (department != null &&
          department.isNotEmpty &&
          department != 'All Departments') {
        query['department'] = department;
      }
      if (status != null && status.isNotEmpty && status != 'All Status') {
        query['status'] = status.toLowerCase();
      }
      if (requestedBy != null &&
          requestedBy.isNotEmpty &&
          requestedBy != 'All') {
        query['requestedBy'] = requestedBy;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        query['startDate'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) query['endDate'] = dateTo;

      final res = await _apiClient.get(
        ApiConstants.materialRequests,
        queryParams: query,
      );
      if (res is Map && res['data'] is Map) {
        return Map<String, dynamic>.from(res['data'] as Map);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getMaterialRequests Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return null;
  }

  Future<bool> createMaterialRequest(Map<String, dynamic> payload) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.materialRequests,
        body: payload,
      );
      return res != null &&
          (res['success'] == true || res['_id'] != null || res['data'] != null);
    } catch (e, stackTrace) {
      AppLogger.e(
        'createMaterialRequest Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return false;
  }

  Future<Map<String, dynamic>?> getMaterialRequestDetail(
    String requestId,
  ) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.materialRequestDetail(requestId),
      );
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getMaterialRequestDetail Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return null;
  }

  Future<bool> updateMaterialRequestStatus(
    String requestId,
    String status,
    String reviewNotes,
  ) async {
    try {
      final res = await _apiClient.put(
        ApiConstants.materialRequestStatus(requestId),
        body: {'status': status, 'reviewNotes': reviewNotes},
      );
      return res != null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'updateMaterialRequestStatus Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return false;
  }

  Future<bool> sendQuotation(
    String requestId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.materialRequestQuotations(requestId),
        body: payload,
      );
      return res != null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'sendQuotation Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return false;
  }

  Future<bool> markItemDelivered({
    required String requestId,
    required String itemId,
    required String deliveryId,
    required String deliveryReference,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.materialRequestItemDelivered(requestId, itemId),
        body: {
          'deliveryId': deliveryId,
          'deliveryReference': deliveryReference,
        },
      );
      return res != null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'markItemDelivered Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return false;
  }
}
