import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class DrawingsService extends GetxService {
  DrawingsService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>?> _getUploadTarget(
    String fileName,
    String mimeType,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.chatUploadPresignedUrl,
        body: {'fileName': fileName, 'fileType': mimeType},
      );
      if (response is Map) {
        final data = response['data'] ?? response;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Get upload URL failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'DRAWINGS_SERVICE',
      );
    }
    return null;
  }

  Future<bool> uploadMediaFile({
    required String leadId,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final target = await _getUploadTarget(fileName, mimeType);
    if (target == null) return false;
    final uploadUrl = (target['uploadUrl'] ?? target['signedUrl'] ?? '')
        .toString();
    final publicUrl =
        (target['fileUrl'] ?? target['publicUrl'] ?? target['url'] ?? '')
            .toString();
    if (uploadUrl.isEmpty || publicUrl.isEmpty) return false;

    try {
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': mimeType},
        body: bytes,
      );
      if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
        return false;
      }
      return uploadDrawing(leadId, {
        'url': publicUrl,
        'name': fileName,
        'type': mimeType.startsWith('video/') ? 'photo' : 'photo',
      });
    } catch (e, stackTrace) {
      AppLogger.e(
        'Upload media failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'DRAWINGS_SERVICE',
      );
      return false;
    }
  }

  Future<dynamic> getDrawings({String? leadId}) async {
    try {
      final response = await _apiClient.get(
        leadId == null || leadId.isEmpty
            ? ApiConstants.drawings
            : ApiConstants.projectDrawings(leadId),
        queryParams: leadId == null || leadId.isEmpty
            ? const {'type': 'drawing'}
            : null,
      );
      AppLogger.i(
        'Get Drawings API Response: $response',
        tag: 'DRAWINGS_SERVICE',
      );
      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e, stackTrace) {
      AppLogger.e(
        'getDrawings Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'DRAWINGS_SERVICE',
      );
      return null;
    }
  }

  Future<bool> uploadDrawing(String leadId, Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.projectDrawings(leadId),
        body: body,
      );
      AppLogger.i(
        'Upload Drawing API Response: $response',
        tag: 'DRAWINGS_SERVICE',
      );
      return response is Map &&
          (response['success'] == true || response.containsKey('data'));
    } catch (e, stackTrace) {
      AppLogger.e(
        'uploadDrawing Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'DRAWINGS_SERVICE',
      );
      return false;
    }
  }
}
