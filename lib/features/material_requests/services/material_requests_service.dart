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
      List rawList = const [];
      if (res is Map) {
        if (res['data'] is Map && res['data']['projects'] is List) {
          rawList = res['data']['projects'] as List;
        } else if (res['projects'] is List) {
          rawList = res['projects'] as List;
        } else if (res['data'] is List) {
          rawList = res['data'] as List;
        } else if (res['items'] is List) {
          rawList = res['items'] as List;
        }
      } else if (res is List) {
        rawList = res;
      }
      if (rawList.isNotEmpty) {
        return rawList
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

    // Fallback: try dashboard filters
    try {
      final res = await _apiClient.get(ApiConstants.dashboardFilters);
      if (res is Map && res['data'] is Map && res['data']['projects'] is List) {
        final pList = res['data']['projects'] as List;
        return pList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    } catch (_) {}

    return const [];
  }

  Future<Map<String, dynamic>?> getFilters() async {
    try {
      final res = await _apiClient.get(ApiConstants.materialRequestsFilters);
      if (res is Map) {
        if (res['data'] is Map) {
          return Map<String, dynamic>.from(res['data'] as Map);
        }
        return Map<String, dynamic>.from(res);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getFilters Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> getMaterialRequests({
    int page = 1,
    int limit = 10,
    String? project,
    String? status,
    String? priority,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? department,
    String? requestedBy,
  }) async {
    try {
      final query = <String, String>{};
      query['page'] = page.toString();
      query['limit'] = limit.toString();
      if (project != null && project.isNotEmpty && project != 'All Projects') {
        query['leadId'] = project;
        query['projectId'] = project;
        query['project'] = project;
      }
      if (status != null &&
          status.isNotEmpty &&
          status != 'All Statuses' &&
          status != 'All Status') {
        query['status'] = status.toLowerCase();
      }
      if (priority != null &&
          priority.isNotEmpty &&
          priority != 'All Priorities') {
        query['priority'] = priority.toLowerCase();
      }
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        query['dateFrom'] = dateFrom;
        query['fromDate'] = dateFrom;
        query['startDate'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        query['dateTo'] = dateTo;
        query['toDate'] = dateTo;
        query['endDate'] = dateTo;
      }
      if (department != null &&
          department.isNotEmpty &&
          department != 'All Departments') {
        query['department'] = department;
      }
      if (requestedBy != null &&
          requestedBy.isNotEmpty &&
          requestedBy != 'All') {
        query['requestedBy'] = requestedBy;
      }

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
      final normalizedStatus = _normalizeStatus(status);
      final notes = reviewNotes.trim().isNotEmpty
          ? reviewNotes.trim()
          : (normalizedStatus == 'cancelled'
              ? 'Cancelled by user'
              : 'Status updated to $normalizedStatus');
      final res = await _apiClient.put(
        ApiConstants.materialRequestStatus(requestId),
        body: {'status': normalizedStatus, 'reviewNotes': notes},
      );
      return res != null;
    } on ApiException {
      rethrow;
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

  static String _normalizeStatus(String status) {
    final lower = status.trim().toLowerCase();
    if (lower.contains('cancel')) return 'cancelled';
    if (lower.contains('approv')) return 'approved';
    if (lower.contains('reject')) return 'rejected';
    if (lower.contains('fulfill')) return 'fulfilled';
    if (lower.contains('pend')) return 'pending';
    return lower;
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

  /// Plant: Customer Add New Order requests for a single project
  Future<Map<String, dynamic>?> getProjectAdditionalMaterialRequests(
    String leadId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.plantProjectAdditionalMaterialRequests(
          leadId,
          page: page,
          limit: limit,
        ),
      );
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getProjectAdditionalMaterialRequests Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return null;
  }

  /// Plant: Mismatch tickets created from construction report-mismatch for a project
  Future<Map<String, dynamic>?> getProjectMismatchOrders(
    String leadId, {
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.plantProjectMismatchOrders(
          leadId,
          page: page,
          limit: limit,
          status: status,
        ),
      );
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getProjectMismatchOrders Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return null;
  }

  /// Plant: Update mismatch order status
  Future<bool> updateMismatchOrderStatus(
    String mismatchId, {
    required String status,
    String? actionNotes,
  }) async {
    try {
      final res = await _apiClient.put(
        ApiConstants.plantMismatchOrderStatus(mismatchId),
        body: {
          'status': status,
          if (actionNotes != null && actionNotes.isNotEmpty)
            'actionNotes': actionNotes,
        },
      );
      return res != null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'updateMismatchOrderStatus Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_SVC',
      );
    }
    return false;
  }
}
