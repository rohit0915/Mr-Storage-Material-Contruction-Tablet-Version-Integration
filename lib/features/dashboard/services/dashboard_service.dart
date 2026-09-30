import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class DashboardService extends GetxService {
  DashboardService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>?> getDashboardData({
    String? projectId,
    String? buildingId,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (projectId != null && projectId.isNotEmpty) {
        queryParams['projectId'] = projectId;
      }
      if (buildingId != null && buildingId.isNotEmpty) {
        queryParams['buildingId'] = buildingId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['fromDate'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['toDate'] = toDate;
      }

      final response = await _apiClient.get(
        ApiConstants.dashboard,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      AppLogger.i('Dashboard API Response: $response', tag: 'DASHBOARD');

      if (response is Map) {
        if (response['success'] == true && response['data'] is Map) {
          return Map<String, dynamic>.from(response['data'] as Map);
        } else if (response['data'] is Map) {
          return Map<String, dynamic>.from(response['data'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Dashboard API Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'DASHBOARD',
      );
      rethrow;
    }
  }
}
