import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    String? buildingLabel,
    String? status,
    String? fromDate,
    String? toDate,
    String? startDate,
    String? endDate,
    int? taskDeadlineDays,
    int? taskLimit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (projectId != null && projectId.isNotEmpty) {
        queryParams['projectId'] = projectId;
      }
      if (buildingId != null && buildingId.isNotEmpty) {
        queryParams['buildingId'] = buildingId;
      }
      if (buildingLabel != null && buildingLabel.isNotEmpty) {
        queryParams['buildingLabel'] = buildingLabel;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      final sDate = startDate ?? fromDate;
      if (sDate != null && sDate.isNotEmpty) {
        queryParams['startDate'] = sDate;
        queryParams['fromDate'] = sDate;
      }
      final eDate = endDate ?? toDate;
      if (eDate != null && eDate.isNotEmpty) {
        queryParams['endDate'] = eDate;
        queryParams['toDate'] = eDate;
      }
      if (taskDeadlineDays != null && taskDeadlineDays > 0) {
        queryParams['taskDeadlineDays'] = taskDeadlineDays.toString();
      }
      if (taskLimit != null && taskLimit > 0) {
        queryParams['taskLimit'] = taskLimit.toString();
      }

      dynamic response;
      try {
        response = await _apiClient.get(
          ApiConstants.adminOverview,
          queryParams: queryParams.isNotEmpty ? queryParams : null,
        );
      } catch (err) {
        AppLogger.w(
          'adminOverview request failed ($err), falling back to ApiConstants.dashboard',
          tag: 'DASHBOARD',
        );
        response = await _apiClient.get(
          ApiConstants.dashboard,
          queryParams: queryParams.isNotEmpty ? queryParams : null,
        );
      }

      if (response is Map) {
        // Print the full response from API for debugging
        try {
          final prettyJson =
              const JsonEncoder.withIndent('  ').convert(response);
          debugPrint('================ [DASHBOARD API RESPONSE] ================');
          for (final line in prettyJson.split('\n')) {
            // ignore: avoid_print
            print(line);
          }
          debugPrint('==========================================================');
          AppLogger.i(
            'Dashboard API Response received with keys: ${(response as Map).keys.toList()}',
            tag: 'DASHBOARD',
          );
        } catch (_) {
          // ignore: avoid_print
          print('[DASHBOARD API RESPONSE RAW]: $response');
          AppLogger.i('Dashboard API Response: $response', tag: 'DASHBOARD');
        }

        if (response['success'] == false) {
          throw const FormatException('Dashboard API returned a failure');
        }
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
