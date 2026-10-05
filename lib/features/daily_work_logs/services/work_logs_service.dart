import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class WorkLogsService extends GetxService {
  WorkLogsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<dynamic> getWorkLogs({
    String? leadId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final query = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (leadId != null && leadId.isNotEmpty && leadId != 'All Projects') {
        query['leadId'] = leadId;
      }
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }

      final res = await _apiClient.get(
        ApiConstants.workLogs,
        queryParams: query,
      );
      return res;
    } catch (e, stackTrace) {
      AppLogger.e(
        'getWorkLogs Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'WORK_LOGS_SVC',
      );
      return null;
    }
  }

  static List<Map<String, String>> defaultProjectsList() => const [
    {
      'id': 'lead-0011',
      'name': 'Storage 0011',
      'jobId': '2026014',
      'displayName': 'Storage 0011 (#2026014)',
    },
    {
      'id': 'lead-002',
      'name': 'Lucas project',
      'jobId': 'PRO-002',
      'displayName': 'Lucas project (#PRO-002)',
    },
    {
      'id': 'lead-042',
      'name': 'Adam Gilchrist',
      'jobId': 'PRO-042',
      'displayName': 'Adam Gilchrist (#PRO-042)',
    },
    {
      'id': 'lead-003',
      'name': 'Another Project',
      'jobId': 'PRO-003',
      'displayName': 'Another Project (#PRO-003)',
    },
  ];

  Future<bool> createWorkLog(Map<String, dynamic> payload) async {
    try {
      final cleanPayload = Map<String, dynamic>.from(payload)
        ..removeWhere((key, value) => value == null);
      final res = await _apiClient.post(
        ApiConstants.workLogs,
        body: cleanPayload,
      );
      return res != null &&
          (res['success'] == true ||
              res['_id'] != null ||
              res['data'] != null ||
              res['log'] != null);
    } catch (e, stackTrace) {
      AppLogger.e(
        'createWorkLog Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'WORK_LOGS_SVC',
      );
      return false;
    }
  }

  Future<List<Map<String, String>>> getProjects() async {
    final merged = <String, Map<String, String>>{};
    for (final def in defaultProjectsList()) {
      merged[def['name']!] = def;
    }

    try {
      final res = await _apiClient.get(ApiConstants.projects);
      List items = [];
      if (res is Map && res['data'] is List) {
        items = res['data'] as List;
      } else if (res is List) {
        items = res;
      }
      for (final item in items) {
        if (item is Map) {
          final id = (item['_id'] ?? item['id'] ?? '').toString();
          final name = (item['projectName'] ?? item['name'] ?? '').toString();
          final jobId = (item['jobId'] ?? item['code'] ?? '').toString();
          if (name.isNotEmpty) {
            merged[name] = {
              'id': id.isNotEmpty ? id : 'lead-$name',
              'name': name,
              'jobId': jobId,
              'displayName': jobId.isNotEmpty ? '$name (#$jobId)' : name,
            };
          }
        }
      }
    } catch (_) {}

    // Fallback: try dashboardFilters
    try {
      final res = await _apiClient.get(ApiConstants.dashboardFilters);
      if (res is Map && res['data'] is Map && res['data']['projects'] is List) {
        final pList = res['data']['projects'] as List;
        for (final item in pList) {
          if (item is Map) {
            final id = (item['_id'] ?? item['id'] ?? '').toString();
            final name = (item['projectName'] ?? item['name'] ?? '').toString();
            final jobId = (item['jobId'] ?? '').toString();
            if (name.isNotEmpty) {
              merged[name] = {
                'id': id.isNotEmpty ? id : 'lead-$name',
                'name': name,
                'jobId': jobId,
                'displayName': jobId.isNotEmpty ? '$name (#$jobId)' : name,
              };
            }
          }
        }
      }
    } catch (_) {}

    return merged.values.toList();
  }

  Future<List<Map<String, String>>> getTasks({String? leadId}) async {
    try {
      final query = <String, String>{};
      if (leadId != null && leadId.isNotEmpty) query['leadId'] = leadId;
      final res = await _apiClient.get(ApiConstants.tasks, queryParams: query);
      List items = [];
      if (res is Map && res['data'] is List) {
        items = res['data'] as List;
      } else if (res is List) {
        items = res;
      }
      final list = <Map<String, String>>[];
      for (final item in items) {
        if (item is Map) {
          final id = (item['_id'] ?? item['id'] ?? '').toString();
          final title = (item['title'] ?? 'General').toString();
          list.add({'id': id, 'title': title});
        }
      }
      return list;
    } catch (_) {
      return [];
    }
  }
}
