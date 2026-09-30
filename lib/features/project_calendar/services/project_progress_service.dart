import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

/// API coverage for project progress, milestones, and customer-tracking steps.
class ProjectProgressService extends GetxService {
  ProjectProgressService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>?> getProjectProgress(String leadId) async {
    try {
      return _mapData(
        await _apiClient.get(ApiConstants.projectProgress(leadId)),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'getProjectProgress Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROGRESS_SVC',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> createMilestone(
    String leadId,
    Map<String, dynamic> payload,
  ) async {
    try {
      return _mapData(
        await _apiClient.post(
          ApiConstants.projectMilestones(leadId),
          body: payload,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'createMilestone Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROGRESS_SVC',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateMilestone(
    String milestoneId,
    Map<String, dynamic> payload,
  ) async {
    try {
      return _mapData(
        await _apiClient.put(
          ApiConstants.milestoneDetail(milestoneId),
          body: payload,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'updateMilestone Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROGRESS_SVC',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProjectStep({
    required String leadId,
    required String stepKey,
    required Map<String, dynamic> payload,
  }) async {
    try {
      return _mapData(
        await _apiClient.put(
          ApiConstants.projectStep(leadId, stepKey),
          body: payload,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'updateProjectStep Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROGRESS_SVC',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> addProjectStepAttachment({
    required String leadId,
    required String stepKey,
    required String name,
    required String url,
  }) async {
    try {
      return _mapData(
        await _apiClient.post(
          ApiConstants.projectStepAttachments(leadId, stepKey),
          body: {'name': name, 'url': url},
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'addProjectStepAttachment Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROGRESS_SVC',
      );
      return null;
    }
  }

  Map<String, dynamic>? _mapData(dynamic response) {
    if (response is! Map) return null;
    final data = response['data'] ?? response;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
