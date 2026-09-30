import 'package:get/get.dart';
import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';
import '../models/packing_list_models.dart';

class PackingListService {
  PackingListService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchPackingListsData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = ApiConstants.packingListsUrl(page: page, limit: limit);
      final res = await _apiClient.get(url);
      AppLogger.i(
        'Fetch packing lists response ($url): $res',
        tag: 'PACKING_LIST',
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
        } else if (target['packingLists'] is List) {
          rawList = target['packingLists'];
        } else if (target['lists'] is List) {
          rawList = target['lists'];
        } else if (target['items'] is List) {
          rawList = target['items'];
        }

        if (target['stats'] is Map) {
          stats = Map<String, dynamic>.from(target['stats'] as Map);
        } else {
          stats = {
            'total':
                target['total'] ?? target['totalPackingList'] ?? rawList.length,
            'ready': target['ready'] ?? target['loadsReadyForDispatch'] ?? 0,
            'bundlesAssigned': target['bundlesAssigned'] ?? 0,
            'dispatchToday':
                target['dispatchToday'] ?? target['loadsDispatchToday'] ?? 0,
          };
        }
      } else if (res is List) {
        rawList = res;
      }

      final items = rawList
          .whereType<Map>()
          .map(
            (item) => PackingListItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      return {
        'items': items,
        'stats': stats,
        'total': target['total'] ?? target['totalPackingList'] ?? items.length,
      };
    } catch (e, st) {
      AppLogger.e(
        'Error fetching packing lists',
        error: e,
        stackTrace: st,
        tag: 'PACKING_LIST',
      );
    }
    return {
      'items': <PackingListItem>[],
      'stats': <String, dynamic>{},
      'total': 0,
    };
  }

  Future<Map<String, dynamic>?> fetchPackingListDetail(String id) async {
    try {
      final res = await _apiClient.get(ApiConstants.packingListDetail(id));
      AppLogger.i(
        'Fetch packing list detail response: $res',
        tag: 'PACKING_LIST',
      );
      if (res is Map) {
        if (res['data'] is Map)
          return Map<String, dynamic>.from(res['data'] as Map);
        return Map<String, dynamic>.from(res);
      }
    } catch (e, st) {
      AppLogger.e(
        'Error fetching packing list detail',
        error: e,
        stackTrace: st,
        tag: 'PACKING_LIST',
      );
    }
    return null;
  }

  Future<String?> exportPackingLists() async {
    try {
      final res = await _apiClient.get(ApiConstants.packingListExport);
      if (res is Map && res['url'] != null) {
        return res['url'].toString();
      }
    } catch (e, st) {
      AppLogger.e(
        'Error exporting packing lists',
        error: e,
        stackTrace: st,
        tag: 'PACKING_LIST',
      );
    }
    return null;
  }

  Future<String?> downloadPackingListPdf(String id) async {
    try {
      final res = await _apiClient.get(ApiConstants.packingListDownloadPdf(id));
      if (res is Map && res['url'] != null) {
        return res['url'].toString();
      }
    } catch (e, st) {
      AppLogger.e(
        'Error downloading packing list PDF',
        error: e,
        stackTrace: st,
        tag: 'PACKING_LIST',
      );
    }
    return null;
  }

  Future<bool> markReady(String id) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.packingListMarkReady(id),
        body: {},
      );
      AppLogger.i('Mark ready response: $res', tag: 'PACKING_LIST');
      return true;
    } catch (e, st) {
      AppLogger.e(
        'Error marking ready',
        error: e,
        stackTrace: st,
        tag: 'PACKING_LIST',
      );
      return false;
    }
  }

  Future<bool> markLoading(String id) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.packingListMarkLoading(id),
        body: {},
      );
      AppLogger.i('Mark loading response: $res', tag: 'PACKING_LIST');
      return true;
    } catch (e, st) {
      AppLogger.e(
        'Error marking loading',
        error: e,
        stackTrace: st,
        tag: 'PACKING_LIST',
      );
      return false;
    }
  }

  Future<bool> markDispatch(String id) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.packingListMarkDispatch(id),
        body: {},
      );
      AppLogger.i('Mark dispatch response: $res', tag: 'PACKING_LIST');
      return true;
    } catch (e, st) {
      AppLogger.e(
        'Error marking dispatch',
        error: e,
        stackTrace: st,
        tag: 'PACKING_LIST',
      );
      return false;
    }
  }
}
