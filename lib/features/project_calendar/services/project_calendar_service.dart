import 'dart:typed_data';

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

  /// Get all available projects without tight pagination (for dropdowns / selectors)
  Future<List<Map<String, dynamic>>> getAllProjects() async {
    try {
      final res = await getProjects(page: 1, limit: 100);
      List items = [];
      if (res is Map) {
        if (res['projects'] is List) {
          items = res['projects'] as List;
        } else if (res['data'] is List) {
          items = res['data'] as List;
        } else if (res['items'] is List) {
          items = res['items'] as List;
        }
      } else if (res is List) {
        items = res;
      }
      final list = <Map<String, dynamic>>[];
      for (final it in items) {
        if (it is Map) {
          list.add(Map<String, dynamic>.from(it));
        }
      }
      if (list.isNotEmpty) return list;
    } catch (e) {
      AppLogger.w('getAllProjects initial fetch failed, trying fallback: $e', tag: 'PROJECTS');
    }

    // Fallback: try dashboardFilters
    try {
      final res = await _apiClient.get(ApiConstants.dashboardFilters);
      if (res is Map && res['data'] is Map && res['data']['projects'] is List) {
        final pList = res['data']['projects'] as List;
        final list = <Map<String, dynamic>>[];
        for (final item in pList) {
          if (item is Map) {
            list.add(Map<String, dynamic>.from(item));
          }
        }
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}

    return [];
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

  /// Get consolidated BOM for a project: GET /api/construction/projects/:leadId/consolidated-bom
  Future<dynamic> getConsolidatedBOM(String leadId) async {
    try {
      final response = await _apiClient.get(ApiConstants.consolidatedBOM(leadId));
      AppLogger.i(
        'Consolidated BOM API Response ($leadId): $response',
        tag: 'PROJECTS',
      );

      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e) {
      AppLogger.w(
        'getConsolidatedBOM not available for $leadId: $e',
        tag: 'PROJECTS',
      );
      return null;
    }
  }

  /// Get BOM files for a project: GET /api/construction/projects/:leadId/bom-files
  Future<dynamic> getBOMFiles(String leadId) async {
    try {
      final response = await _apiClient.get(ApiConstants.bomFiles(leadId));
      AppLogger.i(
        'BOM Files API Response ($leadId): $response',
        tag: 'PROJECTS',
      );

      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e) {
      AppLogger.w(
        'getBOMFiles not available for $leadId: $e',
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
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      final startDateStr =
          '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-01';
      final endDateStr =
          '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}';

      final queryParams = <String, String>{
        'month': month.toString(),
        'year': year.toString(),
        'startDate': startDateStr,
        'endDate': endDateStr,
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

  /// Create a new delivery on backend API: POST /construction/deliveries
  Future<Map<String, dynamic>> createDelivery({
    required String leadId,
    required String title,
    String? sectionLocation,
    required DateTime deliveryDate,
    String? description,
    String? notes,
    List<String>? attachments,
  }) async {
    final dateStr =
        '${deliveryDate.year.toString().padLeft(4, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}';

    final body = <String, dynamic>{
      'title': title,
      'leadId': leadId,
      'deliveryDate': dateStr,
    };

    if (sectionLocation != null && sectionLocation.trim().isNotEmpty) {
      body['sectionLocation'] = sectionLocation.trim();
    }
    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }
    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }
    if (attachments != null && attachments.isNotEmpty) {
      body['attachments'] = attachments;
    }

    AppLogger.i(
      'Calling POST ${ApiConstants.deliveries} with body: $body',
      tag: 'DELIVERIES',
    );

    final response = await _apiClient.post(
      ApiConstants.deliveries,
      body: body,
    );

    AppLogger.i('Create Delivery API Response: $response', tag: 'DELIVERIES');

    if (response is Map) {
      if (response['success'] == false) {
        final msg = response['message']?.toString() ??
            response['error']?.toString() ??
            'Failed to add delivery';
        throw ApiException(msg, 400, response);
      }
      if (response['data'] is Map) {
        return Map<String, dynamic>.from(response['data'] as Map);
      }
      return Map<String, dynamic>.from(response);
    }
    return <String, dynamic>{};
  }

  Future<Uint8List?> downloadPackingListBytes(String deliveryId) async {
    try {
      return await _apiClient.getBytes(
        ApiConstants.deliveryDownloadPackingList(deliveryId),
      );
    } catch (e) {
      AppLogger.w(
        'downloadPackingListBytes failed for $deliveryId: $e',
        tag: 'DELIVERIES',
      );
    }
    return null;
  }

  Future<Uint8List?> downloadBillOfLadingBytes(String deliveryId) async {
    try {
      return await _apiClient.getBytes(
        ApiConstants.deliveryDownloadBillOfLading(deliveryId),
      );
    } catch (e) {
      AppLogger.w(
        'downloadBillOfLadingBytes failed for $deliveryId: $e',
        tag: 'DELIVERIES',
      );
    }
    return null;
  }

  /// Download packing list for a delivery: GET /construction/deliveries/:deliveryId/download/packing-list
  Future<String?> downloadPackingList(String deliveryId) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.deliveryDownloadPackingList(deliveryId),
      );
      AppLogger.i('downloadPackingList API Response: $res', tag: 'DELIVERIES');
      if (res is Map) {
        final url = res['url'] ??
            res['downloadUrl'] ??
            res['fileUrl'] ??
            res['data']?['url'];
        if (url != null && url.toString().isNotEmpty) {
          return url.toString();
        }
      } else if (res is String && res.startsWith('http')) {
        return res;
      }
    } catch (e) {
      AppLogger.w(
        'downloadPackingList failed for $deliveryId: $e',
        tag: 'DELIVERIES',
      );
    }
    return null;
  }

  /// Download bill of lading for a delivery: GET /construction/deliveries/:deliveryId/download/bill-of-lading
  Future<String?> downloadBillOfLading(String deliveryId) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.deliveryDownloadBillOfLading(deliveryId),
      );
      AppLogger.i('downloadBillOfLading API Response: $res', tag: 'DELIVERIES');
      if (res is Map) {
        final url = res['url'] ??
            res['downloadUrl'] ??
            res['fileUrl'] ??
            res['data']?['url'];
        if (url != null && url.toString().isNotEmpty) {
          return url.toString();
        }
      } else if (res is String && res.startsWith('http')) {
        return res;
      }
    } catch (e) {
      AppLogger.w(
        'downloadBillOfLading failed for $deliveryId: $e',
        tag: 'DELIVERIES',
      );
    }
    return null;
  }

  /// Get timeline tasks for a project: GET /construction/projects/:leadId/timeline-tasks
  Future<List<Map<String, dynamic>>> getTimelineTasks(String leadId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.projectTimelineTasks(leadId),
      );
      AppLogger.i('Timeline Tasks API Response ($leadId): $response', tag: 'TASKS');
      if (response is Map) {
        if (response['data'] is Map && response['data']['timelineTasks'] is List) {
          final list = response['data']['timelineTasks'] as List;
          return list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
        } else if (response['timelineTasks'] is List) {
          final list = response['timelineTasks'] as List;
          return list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
        } else if (response['data'] is List) {
          final list = response['data'] as List;
          return list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
        }
      } else if (response is List) {
        return response.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      }
      return [];
    } catch (e, stackTrace) {
      AppLogger.e('getTimelineTasks Exception for $leadId', error: e, stackTrace: stackTrace, tag: 'TASKS');
      return [];
    }
  }

  /// Get task detail by taskId: GET /construction/tasks/:taskId
  Future<Map<String, dynamic>?> getTaskDetail(String taskId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.taskDetail(taskId),
      );
      AppLogger.i('Task Detail API Response ($taskId): $response', tag: 'TASKS');
      if (response is Map) {
        if (response['data'] is Map) {
          final d = response['data'] as Map;
          if (d['task'] is Map) {
            return Map<String, dynamic>.from(d['task'] as Map);
          }
          return Map<String, dynamic>.from(d);
        }
        if (response['task'] is Map) {
          return Map<String, dynamic>.from(response['task'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('getTaskDetail Exception for $taskId', error: e, stackTrace: stackTrace, tag: 'TASKS');
      return null;
    }
  }

  /// Create timeline task: POST /construction/tasks
  Future<Map<String, dynamic>?> createTimelineTask(Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.tasks,
        body: body,
      );
      AppLogger.i('Create Task API Response: $response', tag: 'TASKS');
      if (response is Map) {
        if (response['data'] is Map) {
          final d = response['data'] as Map;
          if (d['task'] is Map) {
            return Map<String, dynamic>.from(d['task'] as Map);
          }
          return Map<String, dynamic>.from(d);
        }
        if (response['task'] is Map) {
          return Map<String, dynamic>.from(response['task'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('createTimelineTask Exception', error: e, stackTrace: stackTrace, tag: 'TASKS');
      rethrow;
    }
  }

  /// Mark task complete: PUT /construction/tasks/:taskId/complete
  Future<bool> completeTask(
    String taskId, {
    DateTime? completedAt,
    String? workDescription,
    List<String>? attachments,
  }) async {
    try {
      final body = <String, dynamic>{
        'completedAt': (completedAt ?? DateTime.now()).toUtc().toIso8601String(),
        if (workDescription != null && workDescription.isNotEmpty) 'workDescription': workDescription,
        if (attachments != null && attachments.isNotEmpty) 'attachments': attachments,
      };
      final response = await _apiClient.put(
        ApiConstants.completeTask(taskId),
        body: body,
      );
      AppLogger.i('Complete Task API Response ($taskId): $response', tag: 'TASKS');
      return response is Map && (response['success'] == true || response.containsKey('data'));
    } catch (e, stackTrace) {
      AppLogger.e('completeTask Exception for $taskId', error: e, stackTrace: stackTrace, tag: 'TASKS');
      return false;
    }
  }

  /// Delete task: DELETE /construction/tasks/:taskId
  Future<bool> deleteTimelineTask(String taskId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.taskDetail(taskId),
      );
      AppLogger.i('Delete Task API Response ($taskId): $response', tag: 'TASKS');
      return response is Map && (response['success'] == true || response.containsKey('data'));
    } catch (e, stackTrace) {
      AppLogger.e('deleteTimelineTask Exception for $taskId', error: e, stackTrace: stackTrace, tag: 'TASKS');
      return false;
    }
  }
}
