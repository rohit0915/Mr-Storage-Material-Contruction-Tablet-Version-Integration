import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';
import '../models/chat_models.dart';

class ChatService {
  ChatService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> uploadAttachment(
    String name,
    String type,
    Uint8List bytes,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.chatUploadPresignedUrl,
      body: {'fileName': name, 'fileType': type, 'folder': 'chat-attachments'},
    );
    final data = response is Map ? response['data'] ?? response : null;
    if (data is! Map) throw const FormatException('Invalid upload response');
    final uploadUrl = (data['uploadUrl'] ?? data['signedUrl'] ?? '').toString();
    final fileUrl = (data['fileUrl'] ?? data['publicUrl'] ?? data['url'] ?? '')
        .toString();
    if (uploadUrl.isEmpty || fileUrl.isEmpty) {
      throw const FormatException('Missing upload URL');
    }
    final result = await http
        .put(Uri.parse(uploadUrl), headers: {'Content-Type': type}, body: bytes)
        .timeout(const Duration(minutes: 2));
    if (result.statusCode < 200 || result.statusCode >= 300) {
      throw Exception('Upload failed');
    }
    return {'url': fileUrl, 'name': name, 'type': type, 'size': bytes.length};
  }

  Future<List<DirectContact>> searchUsers(String query) async {
    try {
      final res = await _apiClient.get(ApiConstants.chatUsersUrl(query));

      List rawList = [];
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['users'] is List) {
          rawList = data['users'];
        }
      } else if (res is List) {
        rawList = res;
      }

      return rawList
          .whereType<Map>()
          .map(
            (item) => DirectContact.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e) {
      AppLogger.w(
        'searchUsers note (backend deployment pending): $e',
        tag: 'CHAT_SERVICE',
      );
      return [];
    }
  }

  Future<Map<String, dynamic>> getConversations() async {
    final response = await _apiClient.get(ApiConstants.chatConversations);
    final data = response is Map ? response['data'] ?? response : response;
    final raw = data is List
        ? data
        : data is Map
        ? data['conversations']
        : null;
    if (raw is! List) {
      throw const FormatException('Invalid conversations response');
    }
    final groups = <DepartmentChannel>[];
    final direct = <DirectContact>[];
    for (final item in raw.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      if (map['type'] == 'group') groups.add(DepartmentChannel.fromJson(map));
      if (map['type'] == 'direct') direct.add(DirectContact.fromJson(map));
    }
    return {'groups': groups, 'direct': direct};
  }

  String get currentUserId {
    final user = _apiClient.getUserData() ?? {};
    return (user['_id'] ?? user['id'] ?? '').toString();
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _apiClient.get(ApiConstants.chatUnreadCount);
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) {
          return int.tryParse(
                '${data['count'] ?? data['total'] ?? data['unreadCount'] ?? 0}',
              ) ??
              0;
        }
      }
    } catch (e) {
      AppLogger.w('getUnreadCount error: $e', tag: 'CHAT_SERVICE');
    }
    return 0;
  }

  Future<List<ChatMessage>> getDirectMessages(
    String userId, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.chatDirectMessages(userId, page: page, limit: limit),
      );

      List rawList = [];
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['messages'] is List) {
          rawList = data['messages'];
        }
      } else if (res is List) {
        rawList = res;
      }

      return rawList
          .whereType<Map>()
          .map(
            (item) => ChatMessage.fromJson(
              Map<String, dynamic>.from(item),
              currentUserId: currentUserId,
            ),
          )
          .toList();
    } catch (e, st) {
      AppLogger.e(
        'Error in getDirectMessages',
        error: e,
        stackTrace: st,
        tag: 'CHAT_SERVICE',
      );
      rethrow;
    }
  }

  Future<bool> sendDirectMessage(
    String userId,
    String content, {
    String? attachmentUrl,
    String? fileName,
  }) async {
    try {
      final body = {
        'content': content,
        'attachmentUrl': ?attachmentUrl,
        'fileName': ?fileName,
      };
      final res = await _apiClient.post(
        ApiConstants.chatDirectMessages(userId).split('?').first,
        body: body,
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error in sendDirectMessage',
        error: e,
        stackTrace: st,
        tag: 'CHAT_SERVICE',
      );
      return false;
    }
  }

  Future<String?> getPresignedUrl(String fileName, String fileType) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.chatUploadPresignedUrl,
        body: {'fileName': fileName, 'fileType': fileType},
      );
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) {
          return data['uploadUrl'] ?? data['url'];
        }
      }
    } catch (e, st) {
      AppLogger.e(
        'Error getting presigned URL',
        error: e,
        stackTrace: st,
        tag: 'CHAT_SERVICE',
      );
    }
    return null;
  }

  Future<DepartmentChannel?> createGroup(
    String name,
    String description,
    List<String> memberIds,
  ) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.chatGroups,
        body: {'name': name, 'description': description, 'members': memberIds},
      );
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) {
          return DepartmentChannel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e, st) {
      AppLogger.e(
        'Error in createGroup',
        error: e,
        stackTrace: st,
        tag: 'CHAT_SERVICE',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> getGroupDetail(String groupId) async {
    try {
      final res = await _apiClient.get(ApiConstants.chatGroupDetail(groupId));
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) {
          return Map<String, dynamic>.from(
            data['group'] is Map ? data['group'] : data,
          );
        }
      }
    } catch (e, st) {
      AppLogger.e(
        'Error in getGroupDetail',
        error: e,
        stackTrace: st,
        tag: 'CHAT_SERVICE',
      );
    }
    return null;
  }

  Future<bool> updateGroupMembers(
    String groupId,
    List<String> memberIds,
  ) async {
    try {
      final res = await _apiClient.put(
        ApiConstants.chatGroupMembers(groupId),
        body: {'members': memberIds},
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error in updateGroupMembers',
        error: e,
        stackTrace: st,
        tag: 'CHAT_SERVICE',
      );
      return false;
    }
  }

  Future<List<ChatMessage>> getGroupMessages(
    String groupId, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiConstants.chatGroupMessages(groupId, page: page, limit: limit),
      );

      List rawList = [];
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['messages'] is List) {
          rawList = data['messages'];
        }
      } else if (res is List) {
        rawList = res;
      }

      return rawList
          .whereType<Map>()
          .map(
            (item) => ChatMessage.fromJson(
              Map<String, dynamic>.from(item),
              currentUserId: currentUserId,
            ),
          )
          .toList();
    } catch (e, st) {
      AppLogger.e(
        'Error in getGroupMessages',
        error: e,
        stackTrace: st,
        tag: 'CHAT_SERVICE',
      );
      rethrow;
    }
  }

  Future<bool> sendGroupMessage(
    String groupId,
    String content, {
    String? attachmentUrl,
    String? fileName,
  }) async {
    try {
      final body = {
        'content': content,
        'attachmentUrl': ?attachmentUrl,
        'fileName': ?fileName,
      };
      final res = await _apiClient.post(
        ApiConstants.chatGroupMessages(groupId).split('?').first,
        body: body,
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error in sendGroupMessage',
        error: e,
        stackTrace: st,
        tag: 'CHAT_SERVICE',
      );
      return false;
    }
  }
}
