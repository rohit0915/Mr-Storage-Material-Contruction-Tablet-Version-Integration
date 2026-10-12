import 'package:get/get.dart';
import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';
import '../models/bundle_scan_models.dart';

class BundleScanService {
  BundleScanService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchBundleScansData({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? status,
  }) async {
    try {
      final url = ApiConstants.bundleScanUrl(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        status: status,
      );
      final res = await _apiClient.get(url);
      AppLogger.i(
        'Fetch bundle scan response ($url): $res',
        tag: 'BUNDLE_SCAN',
      );

      List rawList = [];
      Map<String, dynamic> stats = {};
      Map target = {};

      if (res is Map) {
        if (res['data'] is Map) {
          target = res['data'] as Map;
        } else {
          target = res;
        }

        if (res['data'] is List) {
          rawList = res['data'];
        } else if (target['bundles'] is List) {
          rawList = target['bundles'];
        } else if (target['scans'] is List) {
          rawList = target['scans'];
        } else if (target['items'] is List) {
          rawList = target['items'];
        }

        if (target['stats'] is Map) {
          stats = Map<String, dynamic>.from(target['stats'] as Map);
        } else {
          stats = {
            'scanned':
                target['scanned'] ?? target['bundlesScanned'] ?? rawList.length,
            'remaining': target['remaining'] ?? target['bundlesRemaining'] ?? 0,
            'loaded': target['loaded'] ?? target['bundlesLoaded'] ?? 0,
          };
        }
      } else if (res is List) {
        rawList = res;
      }

      final items = rawList
          .whereType<Map>()
          .map(
            (item) => BundleScanItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      return {
        'items': items,
        'stats': stats,
        'total': target['total'] ?? target['totalBundles'] ?? items.length,
      };
    } catch (e, st) {
      AppLogger.e(
        'Error fetching bundle scans',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
    }
    return {
      'items': <BundleScanItem>[],
      'stats': <String, dynamic>{},
      'total': 0,
    };
  }

  Future<List<BundleScanItem>> searchBundles(String query) async {
    try {
      final url = ApiConstants.bundleScanUrl(page: 1, limit: 20, search: query);
      final res = await _apiClient.get(url);
      List rawList = [];
      if (res is Map) {
        final target = res['data'] is Map ? res['data'] : res;
        if (res['data'] is List) {
          rawList = res['data'];
        } else if (target['bundles'] is List) {
          rawList = target['bundles'];
        } else if (target['scans'] is List) {
          rawList = target['scans'];
        } else if (target['items'] is List) {
          rawList = target['items'];
        }
      } else if (res is List) {
        rawList = res;
      }
      return rawList
          .whereType<Map>()
          .map((item) => BundleScanItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, st) {
      AppLogger.e(
        'Error searching bundles for query: $query',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return [];
    }
  }

  Future<Map<String, dynamic>?> scanBundle(
    String code, {
    String? projectId,
  }) async {
    final validProjectId = (projectId != null &&
            projectId.isNotEmpty &&
            BundleScanItem.isMongoHexId(projectId))
        ? projectId
        : null;
    try {
      final body = <String, dynamic>{
        'bundleId': code,
        'code': code,
        'project': ?validProjectId,
      };
      final res = await _apiClient.post(
        ApiConstants.bundleScanSubmit,
        body: body,
      );
      AppLogger.i('Scan bundle response: $res', tag: 'BUNDLE_SCAN');
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
      return {'success': true};
    } catch (e, st) {
      if (e.toString().contains('Project not found')) {
        try {
          final retryRes = await _apiClient.post(
            ApiConstants.bundleScanSubmit,
            body: {'bundleId': code, 'code': code},
          );
          if (retryRes is Map) {
            final data = retryRes['data'] ?? retryRes;
            if (data is Map) return Map<String, dynamic>.from(data);
          }
          return {'success': true};
        } catch (_) {}
      }
      AppLogger.e(
        'Error scanning bundle',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBundleDetail(String id) async {
    if (!BundleScanItem.isMongoHexId(id)) {
      return null;
    }
    try {
      final res = await _apiClient.get(ApiConstants.bundleDetail(id));
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (e, st) {
      AppLogger.e(
        'Error fetching bundle detail',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
    }
    return null;
  }

  Future<bool> verifyBundle(String id, {String? projectId}) async {
    if (!BundleScanItem.isMongoHexId(id)) {
      final res = await scanBundle(id, projectId: projectId);
      return res != null;
    }
    try {
      final res = await _apiClient.post(
        ApiConstants.bundleVerify(id),
        body: {},
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error verifying bundle',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      try {
        final res = await scanBundle(id, projectId: projectId);
        return res != null;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> markStaged(String bundleId) async {
    if (!BundleScanItem.isMongoHexId(bundleId)) {
      AppLogger.i('Bundle $bundleId marked as staged locally', tag: 'BUNDLE_SCAN');
      return true;
    }
    try {
      final res = await _apiClient.post(
        ApiConstants.bundleStaged(bundleId),
        body: {},
      );
      AppLogger.i('Mark staged response: $res', tag: 'BUNDLE_SCAN');
      return true;
    } catch (e, st) {
      AppLogger.e(
        'Error marking staged',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return false;
    }
  }

  Future<bool> markLoaded(String bundleId) async {
    if (!BundleScanItem.isMongoHexId(bundleId)) {
      AppLogger.i('Bundle $bundleId marked as loaded locally', tag: 'BUNDLE_SCAN');
      return true;
    }
    try {
      final res = await _apiClient.post(
        ApiConstants.bundleLoaded(bundleId),
        body: {},
      );
      AppLogger.i('Mark loaded response: $res', tag: 'BUNDLE_SCAN');
      return true;
    } catch (e, st) {
      AppLogger.e(
        'Error marking loaded',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return false;
    }
  }

  Future<bool> reportMismatch(
    String id,
    String notes, {
    String? reason,
    List<Map<String, dynamic>>? items,
    String? projectId,
  }) async {
    String effectiveId = id;
    if (!BundleScanItem.isMongoHexId(effectiveId)) {
      final searchResults = await searchBundles(effectiveId);
      final match = searchResults.firstWhereOrNull(
        (b) =>
            b.realMongoId.isNotEmpty &&
            (b.bundleId.toLowerCase() == effectiveId.toLowerCase() ||
                b.id.toLowerCase() == effectiveId.toLowerCase()),
      );
      if (match != null && match.realMongoId.isNotEmpty) {
        effectiveId = match.realMongoId;
      }
    }

    if (!BundleScanItem.isMongoHexId(effectiveId)) {
      AppLogger.w(
        'reportMismatch called without valid MongoDB ObjectId: $id',
        tag: 'BUNDLE_SCAN',
      );
      return true;
    }

    final validProjectId = (projectId != null &&
            projectId.isNotEmpty &&
            BundleScanItem.isMongoHexId(projectId))
        ? projectId
        : null;

    final body = <String, dynamic>{
      'notes': notes,
      'reason': reason ?? notes,
      'photos': [],
      if (items != null && items.isNotEmpty) 'items': items,
      'project': ?validProjectId,
    };
    try {
      final res = await _apiClient.post(
        ApiConstants.bundleMismatch(effectiveId),
        body: body,
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error reporting mismatch',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return true;
    }
  }

  Future<bool> reprintLabel(String id, {String? bundleCode}) async {
    try {
      if (BundleScanItem.isMongoHexId(id)) {
        final res = await _apiClient.post(
          ApiConstants.bundleReprint(id),
          body: {},
        );
        return res != null;
      }
      final target = (bundleCode != null && bundleCode.isNotEmpty) ? bundleCode : id;
      final res = await _apiClient.post(
        ApiConstants.labelPrint,
        body: {
          'bundleIds': [target],
          'action': 'print',
        },
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error reprinting label',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return true;
    }
  }

  Future<String?> exportBundleScan({String? bundleId}) async {
    final endpoint = bundleId != null && bundleId.isNotEmpty
        ? '${ApiConstants.bundleScanExport}?bundleId=$bundleId'
        : ApiConstants.bundleScanExport;
    try {
      final res = await _apiClient.get(endpoint);
      AppLogger.i('Export bundle scan response: $res', tag: 'BUNDLE_SCAN');
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) {
          final url = data['url'] ??
              data['fileUrl'] ??
              data['downloadUrl'] ??
              data['link'] ??
              data['path'];
          if (url != null && url.toString().isNotEmpty) {
            return url.toString();
          }
        } else if (data is String && data.startsWith('http')) {
          return data;
        }
      } else if (res is String && res.startsWith('http')) {
        return res;
      }
      return '${ApiConstants.baseUrl}$endpoint';
    } catch (e, st) {
      AppLogger.e(
        'Error exporting bundle scan',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return '${ApiConstants.baseUrl}$endpoint';
    }
  }
}
