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
      AppLogger.e(
        'getProjects Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROJECTS',
      );
      rethrow;
    }
  }

  /// Get details of a single project by leadId / id
  Future<Map<String, dynamic>?> getProjectDetails(String leadId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.projectDetails(leadId),
      );
      AppLogger.i(
        'Project Details API Response ($leadId): $response',
        tag: 'PROJECTS',
      );

      if (response is Map) {
        if (response['data'] is Map) {
          return Map<String, dynamic>.from(response['data'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'getProjectDetails Exception for $leadId',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROJECTS',
      );
      rethrow;
    }
  }

  /// Get BOM files for a project by leadId: GET /api/construction/projects/:leadId/bom
  Future<dynamic> getProjectBOM(String leadId) async {
    try {
      final response = await _apiClient.get(ApiConstants.projectBOM(leadId));
      AppLogger.i(
        'Project BOM API Response ($leadId): $response',
        tag: 'PROJECTS',
      );

      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e) {
      AppLogger.w(
        'getProjectBOM not available for $leadId (backend deployment pending): $e',
        tag: 'PROJECTS',
      );
      return null;
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
      AppLogger.e(
        'getProjectCalendar Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'CALENDAR',
      );
      rethrow;
    }
  }

  /// Get details of a single delivery by deliveryId or code
  Future<Map<String, dynamic>?> getDeliveryDetails(String deliveryId) async {
    try {
      // 1. If deliveryId is a 24-character Mongo ObjectId, try direct GET
      if (deliveryId.length == 24 && !deliveryId.contains('-')) {
        try {
          final response = await _apiClient.get(
            ApiConstants.deliveryDetail(deliveryId),
          );
          AppLogger.i(
            'Delivery Details Direct API Response ($deliveryId): $response',
            tag: 'DELIVERIES',
          );
          if (response is Map) {
            if (response['data'] is Map) {
              return Map<String, dynamic>.from(response['data'] as Map);
            }
            return Map<String, dynamic>.from(response);
          }
        } catch (e) {
          AppLogger.w(
            'Direct delivery detail fetch failed for $deliveryId: $e',
            tag: 'DELIVERIES',
          );
        }
      }

      // 2. If deliveryId is a code (e.g. CUST-DEL-101, DEL-0002) or direct call failed,
      // fetch list of deliveries to find matching MongoDB _id or delivery Map
      AppLogger.i(
        'Fetching deliveries list to resolve deliveryId/code: $deliveryId',
        tag: 'DELIVERIES',
      );
      final listRes = await _apiClient.get(ApiConstants.deliveries);
      List itemsList = [];
      if (listRes is Map) {
        if (listRes['deliveries'] is List) {
          itemsList = listRes['deliveries'] as List;
        } else if (listRes['data'] is List) {
          itemsList = listRes['data'] as List;
        } else if (listRes['data'] is Map &&
            listRes['data']['deliveries'] is List) {
          itemsList = listRes['data']['deliveries'] as List;
        }
      } else if (listRes is List) {
        itemsList = listRes;
      }

      for (final item in itemsList) {
        if (item is Map) {
          final iMap = Map<String, dynamic>.from(item);
          final mId = (iMap['_id'] ?? iMap['id'] ?? '').toString();
          final code =
              (iMap['deliveryNumber'] ??
                      iMap['code'] ??
                      iMap['deliveryCode'] ??
                      mId)
                  .toString();

          if (mId == deliveryId ||
              code == deliveryId ||
              code.contains(deliveryId) ||
              deliveryId.contains(code)) {
            AppLogger.i(
              'Matched delivery in list for $deliveryId! Mongo _id: $mId',
              tag: 'DELIVERIES',
            );

            // If we have a valid 24-character Mongo _id, try detail endpoint with real Mongo _id
            if (mId.length == 24 && !mId.contains('-')) {
              try {
                final detailRes = await _apiClient.get(
                  ApiConstants.deliveryDetail(mId),
                );
                if (detailRes is Map) {
                  if (detailRes['data'] is Map) {
                    return Map<String, dynamic>.from(detailRes['data'] as Map);
                  }
                  return Map<String, dynamic>.from(detailRes);
                }
              } catch (_) {}
            }
            return iMap;
          }
        }
      }

      // 3. Fallback: try direct call anyway
      final response = await _apiClient.get(
        ApiConstants.deliveryDetail(deliveryId),
      );
      if (response is Map) {
        if (response['data'] is Map) {
          return Map<String, dynamic>.from(response['data'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'getDeliveryDetails Exception for $deliveryId',
        error: e,
        stackTrace: stackTrace,
        tag: 'DELIVERIES',
      );
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
        'notes': description != null && description.isNotEmpty
            ? description
            : title,
        'requiredDate': date.toIso8601String(),
        'siteLocation': location,
        'requestedItems': [
          {
            'name': title.isNotEmpty ? title : 'Delivery Material',
            'quantity': 1,
            'unit': 'pkg',
          },
        ],
        'priority': 'medium',
      };

      final response = await _apiClient.post(
        ApiConstants.materialRequests,
        body: body,
      );

      AppLogger.i('Create Delivery API Response: $response', tag: 'DELIVERIES');
      if (response is Map &&
          (response['success'] == true || response.containsKey('data'))) {
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.e(
        'createDelivery Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'DELIVERIES',
      );
      return false;
    }
  }
}
