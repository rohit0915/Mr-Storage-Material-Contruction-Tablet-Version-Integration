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
  }) async {
    try {
      final url = ApiConstants.bundleScanUrl(page: page, limit: limit);
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

  Future<bool> scanBundle(String code) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.bundleScanSubmit,
        body: {'code': code},
      );
      AppLogger.i('Scan bundle response: $res', tag: 'BUNDLE_SCAN');
      return true;
    } catch (e, st) {
      AppLogger.e(
        'Error scanning bundle',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> getBundleDetail(String id) async {
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

  Future<bool> verifyBundle(String id) async {
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
      return false;
    }
  }

  Future<bool> markStaged(String bundleId) async {
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

  Future<bool> reportMismatch(String id, String reason) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.bundleMismatch(id),
        body: {'reason': reason},
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error reporting mismatch',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return false;
    }
  }

  Future<bool> reprintLabel(String id) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.bundleReprint(id),
        body: {},
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error reprinting label',
        error: e,
        stackTrace: st,
        tag: 'BUNDLE_SCAN',
      );
      return false;
    }
  }
}
