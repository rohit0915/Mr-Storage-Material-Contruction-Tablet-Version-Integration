import 'package:get/get.dart';
import '../models/notification_models.dart';
import '../services/notifications_service.dart';

class NotificationsController extends GetxController {
  NotificationsController({NotificationsService? service})
    : _service = service ?? NotificationsService();

  final NotificationsService _service;
  final activeFilter = NotificationFilter.all.obs;
  final isLoading = false.obs;
  final allNotifications = <NotificationItem>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final res = await _service.getNotifications();
      final items = res['items'] as List<NotificationItem>? ?? [];
      allNotifications.assignAll(items);
      unreadCount.value =
          res['unreadCount'] ?? items.where((n) => n.isUnread).length;
    } finally {
      isLoading.value = false;
    }
  }

  List<NotificationItem> get filteredNotifications {
    switch (activeFilter.value) {
      case NotificationFilter.unread:
        return allNotifications.where((n) => n.isUnread).toList();
      case NotificationFilter.leads:
        return allNotifications
            .where((n) => n.category == NotificationCategory.leads)
            .toList();
      case NotificationFilter.tasks:
        return allNotifications
            .where((n) => n.category == NotificationCategory.tasks)
            .toList();
      case NotificationFilter.meetings:
        return allNotifications
            .where((n) => n.category == NotificationCategory.meetings)
            .toList();
      case NotificationFilter.escalations:
        return allNotifications
            .where((n) => n.category == NotificationCategory.escalations)
            .toList();
      case NotificationFilter.all:
        return allNotifications;
    }
  }

  void setFilter(NotificationFilter filter) {
    activeFilter.value = filter;
  }

  Future<void> markAsRead(String id) async {
    final idx = allNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      allNotifications[idx] = allNotifications[idx].copyWith(isUnread: false);
      allNotifications.refresh();
      if (unreadCount.value > 0) unreadCount.value--;
      await _service.markOneRead(id);
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < allNotifications.length; i++) {
      allNotifications[i] = allNotifications[i].copyWith(isUnread: false);
    }
    allNotifications.refresh();
    unreadCount.value = 0;
    await _service.markAllRead();
  }

  Future<void> removeNotification(String id) async {
    allNotifications.removeWhere((n) => n.id == id);
    unreadCount.value = allNotifications.where((n) => n.isUnread).length;
    await _service.deleteNotification(id);
  }
}
