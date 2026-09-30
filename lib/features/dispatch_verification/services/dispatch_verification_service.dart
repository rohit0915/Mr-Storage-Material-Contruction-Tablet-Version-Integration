import 'package:get/get.dart';
import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';
import '../models/dispatch_verification_models.dart';

class DispatchVerificationService {
  DispatchVerificationService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchDispatchVerificationsData() async {
    List rawList = [];
    Map<String, dynamic> stats = {
      'loadsReady': 0,
      'bundlesVerified': 0,
      'bundlesMissing': 0,
      'dispatchedToday': 0,
    };

    try {
      final res = await _apiClient.get(ApiConstants.dispatchVerification);
      AppLogger.i(
        'Fetch dispatch verification response: $res',
        tag: 'DISPATCH_VERIFICATION',
      );

      if (res is Map) {
        final data = res['data'];
        if (data is Map) {
          if (data['loads'] is List) {
            rawList = data['loads'];
          } else if (data['dispatches'] is List) {
            rawList = data['dispatches'];
          } else if (data['items'] is List) {
            rawList = data['items'];
          }
          if (data['stats'] is Map) {
            final s = data['stats'] as Map;
            stats['loadsReady'] =
                s['loadsReady'] ?? s['readyForDispatch'] ?? s['total'] ?? 0;
            stats['bundlesVerified'] =
                s['bundlesVerified'] ?? s['verified'] ?? 0;
            stats['bundlesMissing'] = s['bundlesMissing'] ?? s['missing'] ?? 0;
            stats['dispatchedToday'] = s['dispatchedToday'] ?? s['today'] ?? 0;
          }
        } else if (data is List) {
          rawList = data;
        }

        if (res['loads'] is List) rawList = res['loads'];
        if (res['dispatches'] is List) rawList = res['dispatches'];
      } else if (res is List) {
        rawList = res;
      }
    } catch (e, st) {
      AppLogger.e(
        'Error fetching dispatch verifications from /dispatch-verification',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
    }

    // Fallback: If /construction/dispatch-verification returned no items, fetch the confirmed loads from /construction/packing-lists
    if (rawList.isEmpty) {
      try {
        final pklRes = await _apiClient.get(
          ApiConstants.packingListsUrl(page: 1, limit: 50),
        );
        AppLogger.i(
          'Dispatch fallback to packing-lists response: $pklRes',
          tag: 'DISPATCH_VERIFICATION',
        );
        if (pklRes is Map) {
          final data = pklRes['data'];
          if (data is Map) {
            if (data['packingLists'] is List) {
              rawList = data['packingLists'];
            } else if (data['items'] is List) {
              rawList = data['items'];
            }
          } else if (data is List) {
            rawList = data;
          }
          if (pklRes['packingLists'] is List) rawList = pklRes['packingLists'];
        } else if (pklRes is List) {
          rawList = pklRes;
        }
      } catch (e, st) {
        AppLogger.e(
          'Error fetching fallback packing lists for dispatch',
          error: e,
          stackTrace: st,
          tag: 'DISPATCH_VERIFICATION',
        );
      }
    }

    final items = rawList
        .whereType<Map>()
        .map((item) => DispatchItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    if (items.isNotEmpty) {
      stats['loadsReady'] = items.length;
    }

    return {'items': items, 'stats': stats};
  }

  Future<List<DispatchItem>> fetchDispatchVerifications() async {
    final res = await fetchDispatchVerificationsData();
    return (res['items'] as List<DispatchItem>?) ?? [];
  }

  Future<Map<String, dynamic>?> getDispatchLoadDetail(String loadId) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.dispatchVerificationDetail(loadId),
      );
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (e, st) {
      AppLogger.e(
        'Error fetching dispatch load detail',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
    }
    return null;
  }

  Future<bool> verifyLoad(String loadId, {double? actualWeight}) async {
    try {
      AppLogger.i(
        'Calling verifyLoad API for loadId: $loadId',
        tag: 'DISPATCH_VERIFICATION',
      );
      final body = actualWeight != null
          ? {'actualWeight': actualWeight}
          : {'actualWeight': 11137.4};
      final res = await _apiClient.post(
        ApiConstants.dispatchVerificationVerify(loadId),
        body: body,
      );
      AppLogger.i('Verify load response: $res', tag: 'DISPATCH_VERIFICATION');
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error verifying load: $e',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
      return false;
    }
  }

  Future<bool> confirmDispatch(String loadId, {String? packingListId}) async {
    try {
      AppLogger.i(
        'Calling confirmDispatch API for loadId: $loadId',
        tag: 'DISPATCH_VERIFICATION',
      );
      final res = await _apiClient.post(
        ApiConstants.dispatchVerificationConfirm(loadId),
        body: {},
      );
      AppLogger.i(
        'Confirm dispatch response: $res',
        tag: 'DISPATCH_VERIFICATION',
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error confirming dispatch on /dispatch-verification: $e',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
      final targetId = (packingListId != null && packingListId.isNotEmpty)
          ? packingListId
          : loadId;
      try {
        AppLogger.i(
          'Trying fallback mark-dispatch API for packingListId: $targetId',
          tag: 'DISPATCH_VERIFICATION',
        );
        final res2 = await _apiClient.post(
          ApiConstants.packingListMarkDispatch(targetId),
          body: {},
        );
        AppLogger.i(
          'Fallback mark-dispatch response: $res2',
          tag: 'DISPATCH_VERIFICATION',
        );
        return res2 != null;
      } catch (e2, st2) {
        AppLogger.e(
          'Error on fallback mark-dispatch: $e2',
          error: e2,
          stackTrace: st2,
          tag: 'DISPATCH_VERIFICATION',
        );
        return false;
      }
    }
  }
}
