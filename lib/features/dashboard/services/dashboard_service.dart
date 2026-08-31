import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class DashboardService extends GetxService {
  DashboardService({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>?> getDashboardData({
    String? project,
    String? building,
    String? status,
    String? dateRange,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (project != null && project.isNotEmpty && project != 'All Projects') {
        queryParams['project'] = project;
      }
      if (building != null && building.isNotEmpty && building != 'All Buildings') {
        queryParams['building'] = building;
      }
      if (status != null && status.isNotEmpty && status != 'All Status') {
        queryParams['status'] = status;
      }
      if (dateRange != null && dateRange.isNotEmpty) {
        queryParams['dateRange'] = dateRange;
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
      AppLogger.e('Dashboard API Exception', error: e, stackTrace: stackTrace, tag: 'DASHBOARD');
      rethrow;
    }
  }
}


