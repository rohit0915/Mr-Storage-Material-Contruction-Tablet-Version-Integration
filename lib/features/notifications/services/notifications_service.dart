import 'package:get/get.dart';
import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';
import '../models/notification_models.dart';

class NotificationsService {
  NotificationsService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = ApiConstants.notificationsUrl(page: page, limit: limit);
      final res = await _apiClient.get(url);
      AppLogger.i(
        'Get notifications response: $res',
        tag: 'NOTIFICATIONS_SERVICE',
      );

      List rawList = [];
      int total = 0;
      int unread = 0;

      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map) {
          if (data['notifications'] is List) {
            rawList = data['notifications'];
          } else if (data['items'] is List) {
            rawList = data['items'];
          }
          total = (data['total'] as num?)?.toInt() ?? rawList.length;
          unread = (data['unreadCount'] as num?)?.toInt() ?? 0;
        } else if (data is List) {
          rawList = data;
          total = rawList.length;
        }
      } else if (res is List) {
        rawList = res;
        total = rawList.length;
      }

      final items = rawList
          .whereType<Map>()
          .map(
            (item) =>
                NotificationItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      return {'items': items, 'total': total, 'unreadCount': unread};
    } catch (e, st) {
      AppLogger.e(
        'Error fetching notifications',
        error: e,
        stackTrace: st,
        tag: 'NOTIFICATIONS_SERVICE',
      );
      return {'items': <NotificationItem>[], 'total': 0, 'unreadCount': 0};
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _apiClient.get(ApiConstants.notificationUnreadCount);
      if (res is Map) {
        final data = res['data'] ?? res;
        if (data is Map && data.containsKey('unreadCount')) {
          return (data['unreadCount'] as num).toInt();
        } else if (data is num) {
          return data.toInt();
        }
      }
    } catch (e) {
      AppLogger.w('getUnreadCount error: $e', tag: 'NOTIFICATIONS_SERVICE');
    }
    return 0;
  }

  Future<bool> markOneRead(String id) async {
    try {
      final res = await _apiClient.put(
        ApiConstants.notificationMarkRead(id),
        body: {},
      );
      return res != null;
    } catch (e) {
      AppLogger.w('markOneRead error: $e', tag: 'NOTIFICATIONS_SERVICE');
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      final res = await _apiClient.put(
        ApiConstants.notificationMarkAllRead,
        body: {},
      );
      return res != null;
    } catch (e) {
      AppLogger.w('markAllRead error: $e', tag: 'NOTIFICATIONS_SERVICE');
      return false;
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      final res = await _apiClient.delete(ApiConstants.notificationDetail(id));
      return res != null;
    } catch (e) {
      AppLogger.w('deleteNotification error: $e', tag: 'NOTIFICATIONS_SERVICE');
      return false;
    }
  }
}
