import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class MaterialRequestsService extends GetxService {
  MaterialRequestsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>?> getMaterialRequests({
    String? leadId,
    String? department,
    String? status,
    String? requestedBy,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final query = <String, String>{};
      if (leadId != null && leadId.isNotEmpty && leadId != 'All Projects') {
        query['leadId'] = leadId;
      }
      if (department != null && department.isNotEmpty && department != 'All Departments') {
        query['department'] = department;
      }
      if (status != null && status.isNotEmpty && status != 'All Status') {
        query['status'] = status.toLowerCase();
      }
      if (requestedBy != null && requestedBy.isNotEmpty && requestedBy != 'All') {
        query['requestedBy'] = requestedBy;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) query['dateFrom'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) query['dateTo'] = dateTo;

      final res = await _apiClient.get(ApiConstants.materialRequests, queryParams: query);
      if (res is Map && res['data'] is Map) {
        return Map<String, dynamic>.from(res['data'] as Map);
      }
    } catch (e, stackTrace) {
      AppLogger.e('getMaterialRequests Error', error: e, stackTrace: stackTrace, tag: 'MAT_REQ_SVC');
    }
    return null;
  }

  Future<bool> createMaterialRequest(Map<String, dynamic> payload) async {
    try {
      final res = await _apiClient.post(ApiConstants.materialRequests, body: payload);
      return res != null && (res['success'] == true || res['_id'] != null || res['data'] != null);
    } catch (e, stackTrace) {
      AppLogger.e('createMaterialRequest Error', error: e, stackTrace: stackTrace, tag: 'MAT_REQ_SVC');
    }
    return false;
  }

  Future<bool> updateMaterialRequestStatus(String requestId, String status, String reviewNotes) async {
    try {
      final res = await _apiClient.put(
        ApiConstants.materialRequestStatus(requestId),
        body: {'status': status, 'reviewNotes': reviewNotes},
      );
      return res != null;
    } catch (e, stackTrace) {
      AppLogger.e('updateMaterialRequestStatus Error', error: e, stackTrace: stackTrace, tag: 'MAT_REQ_SVC');
    }
    return false;
  }
}
