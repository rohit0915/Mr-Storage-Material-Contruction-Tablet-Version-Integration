import 'package:get/get.dart';
import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';
import '../models/label_printing_models.dart';

class LabelPrintingService {
  LabelPrintingService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchLabelsData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = ApiConstants.labelsUrl(page: page, limit: limit);
      final res = await _apiClient.get(url);
      AppLogger.i('Fetch labels response ($url): $res', tag: 'LABEL_PRINTING');

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
        } else if (target['labels'] is List) {
          rawList = target['labels'];
        } else if (target['bundles'] is List) {
          rawList = target['bundles'];
        } else if (target['items'] is List) {
          rawList = target['items'];
        }

        if (target['stats'] is Map) {
          stats = Map<String, dynamic>.from(target['stats'] as Map);
        } else {
          stats = {
            'total':
                target['total'] ?? target['totalBundles'] ?? rawList.length,
            'printed': target['printed'] ?? target['labelsPrinted'] ?? 0,
            'pending': target['pending'] ?? target['labelsPending'] ?? 0,
            'printedToday':
                target['printedToday'] ?? target['labelsPrintedToday'] ?? 0,
          };
        }
      } else if (res is List) {
        rawList = res;
      }

      final items = rawList
          .whereType<Map>()
          .map(
            (item) => LabelBundleItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      return {
        'items': items,
        'stats': stats,
        'total': target['total'] ?? target['totalBundles'] ?? items.length,
      };
    } catch (e, st) {
      AppLogger.e(
        'Error fetching labels from API',
        error: e,
        stackTrace: st,
        tag: 'LABEL_PRINTING',
      );
    }
    return {
      'items': <LabelBundleItem>[],
      'stats': <String, dynamic>{},
      'total': 0,
    };
  }

  Future<bool> printLabel(List<String> bundleIds) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.labelPrint,
        body: {'bundleIds': bundleIds, 'action': 'print'},
      );
      AppLogger.i('Print label response: $res', tag: 'LABEL_PRINTING');
      return true;
    } catch (e, st) {
      AppLogger.e(
        'Error printing labels via API',
        error: e,
        stackTrace: st,
        tag: 'LABEL_PRINTING',
      );
      return false;
    }
  }
}
