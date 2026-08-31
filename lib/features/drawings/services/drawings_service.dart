import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class DrawingsService extends GetxService {
  DrawingsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<dynamic> getDrawings() async {
    try {
      final response = await _apiClient.get(ApiConstants.drawings);
      AppLogger.i('Get Drawings API Response: $response', tag: 'DRAWINGS_SERVICE');
      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e, stackTrace) {
      AppLogger.e('getDrawings Exception', error: e, stackTrace: stackTrace, tag: 'DRAWINGS_SERVICE');
      return null;
    }
  }

  Future<bool> uploadDrawing(Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.post(ApiConstants.drawings, body: body);
      AppLogger.i('Upload Drawing API Response: $response', tag: 'DRAWINGS_SERVICE');
      return response is Map && (response['success'] == true || response.containsKey('data'));
    } catch (e, stackTrace) {
      AppLogger.e('uploadDrawing Exception', error: e, stackTrace: stackTrace, tag: 'DRAWINGS_SERVICE');
      return false;
    }
  }
}
