import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class ProjectCalendarService extends GetxService {
  ProjectCalendarService({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  /// Get list of all construction projects
  Future<dynamic> getProjects({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        ApiConstants.projects,
        queryParams: queryParams,
      );

      AppLogger.i('Projects API Response: $response', tag: 'PROJECTS');

      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e, stackTrace) {
      AppLogger.e('getProjects Exception', error: e, stackTrace: stackTrace, tag: 'PROJECTS');
      rethrow;
    }
  }

  /// Get details of a single project by leadId / id
  Future<Map<String, dynamic>?> getProjectDetails(String leadId) async {
    try {
      final response = await _apiClient.get(ApiConstants.projectDetails(leadId));
      AppLogger.i('Project Details API Response ($leadId): $response', tag: 'PROJECTS');

      if (response is Map) {
        if (response['data'] is Map) {
          return Map<String, dynamic>.from(response['data'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('getProjectDetails Exception for $leadId', error: e, stackTrace: stackTrace, tag: 'PROJECTS');
      rethrow;
    }
  }

  /// Get project calendar events for a specified month and year
  Future<dynamic> getProjectCalendar({
    required int month,
    required int year,
    String? leadId,
  }) async {
    try {
      final queryParams = <String, String>{
        'month': month.toString(),
        'year': year.toString(),
      };
      if (leadId != null && leadId.isNotEmpty) {
        queryParams['leadId'] = leadId;
      }

      final response = await _apiClient.get(
        ApiConstants.projectCalendar,
        queryParams: queryParams,
      );

      AppLogger.i('Calendar API Response: $response', tag: 'CALENDAR');

      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e, stackTrace) {
      AppLogger.e('getProjectCalendar Exception', error: e, stackTrace: stackTrace, tag: 'CALENDAR');
      rethrow;
    }
  }

  /// Get details of a single delivery by deliveryId
  Future<Map<String, dynamic>?> getDeliveryDetails(String deliveryId) async {
    try {
      final response = await _apiClient.get(ApiConstants.deliveryDetail(deliveryId));
      AppLogger.i('Delivery Details API Response ($deliveryId): $response', tag: 'DELIVERIES');

      if (response is Map) {
        if (response['data'] is Map) {
          return Map<String, dynamic>.from(response['data'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('getDeliveryDetails Exception for $deliveryId', error: e, stackTrace: stackTrace, tag: 'DELIVERIES');
      return null;
    }
  }

  /// Create a new delivery / material request on backend API
  Future<bool> createDelivery({
    required String leadId,
    required String title,
    required String location,
    required DateTime date,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{
        'leadId': leadId,
        'notes': description != null && description.isNotEmpty ? description : title,
        'requiredDate': date.toIso8601String(),
        'siteLocation': location,
        'requestedItems': [
          {
            'name': title.isNotEmpty ? title : 'Delivery Material',
            'quantity': 1,
            'unit': 'pkg',
          }
        ],
        'priority': 'medium',
      };

      final response = await _apiClient.post(
        ApiConstants.materialRequests,
        body: body,
      );

      AppLogger.i('Create Delivery API Response: $response', tag: 'DELIVERIES');
      if (response is Map && (response['success'] == true || response.containsKey('data'))) {
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.e('createDelivery Exception', error: e, stackTrace: stackTrace, tag: 'DELIVERIES');
      return false;
    }
  }
}

