import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class TasksService extends GetxService {
  TasksService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>?> getTaskStats() async {
    try {
      final res = await _apiClient.get(ApiConstants.taskStats);
      if (res is Map && res['data'] is Map) {
        return Map<String, dynamic>.from(res['data'] as Map);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getTaskStats Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'TASKS_SVC',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> getTasks({
    String? leadId,
    String? status,
    String? priority,
  }) async {
    try {
      final query = <String, String>{};
      if (leadId != null && leadId.isNotEmpty) query['leadId'] = leadId;
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (priority != null && priority.isNotEmpty) query['priority'] = priority;

      final res = await _apiClient.get(ApiConstants.tasks, queryParams: query);
      if (res is Map && res['data'] is Map) {
        return Map<String, dynamic>.from(res['data'] as Map);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getTasks Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'TASKS_SVC',
      );
    }
    return null;
  }

  Future<bool> createTask(Map<String, dynamic> payload) async {
    try {
      final res = await _apiClient.post(ApiConstants.tasks, body: payload);
      return res != null &&
          (res['success'] == true || res['_id'] != null || res['data'] != null);
    } catch (e, stackTrace) {
      AppLogger.e(
        'createTask Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'TASKS_SVC',
      );
    }
    return false;
  }

  Future<bool> updateTask(String taskId, Map<String, dynamic> payload) async {
    try {
      final res = await _apiClient.put(
        ApiConstants.taskDetail(taskId),
        body: payload,
      );
      return res != null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'updateTask Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'TASKS_SVC',
      );
    }
    return false;
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      final res = await _apiClient.delete(ApiConstants.taskDetail(taskId));
      return res != null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'deleteTask Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'TASKS_SVC',
      );
    }
    return false;
  }

  Future<Map<String, dynamic>?> getWorkLogs({String? leadId}) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.workLogs,
        queryParams: leadId == null || leadId.isEmpty
            ? null
            : {'leadId': leadId},
      );
      if (res is Map && res['data'] is Map) {
        return Map<String, dynamic>.from(res['data'] as Map);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'getWorkLogs Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'TASKS_SVC',
      );
    }
    return null;
  }

  Future<bool> createWorkLog(Map<String, dynamic> payload) async {
    try {
      final res = await _apiClient.post(ApiConstants.workLogs, body: payload);
      return res != null;
    } catch (e, stackTrace) {
      AppLogger.e(
        'createWorkLog Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'TASKS_SVC',
      );
    }
    return false;
  }
}
