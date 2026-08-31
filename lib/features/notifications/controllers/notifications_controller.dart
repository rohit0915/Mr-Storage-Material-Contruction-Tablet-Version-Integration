import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_models.dart';

class NotificationsController extends GetxController {
  final activeFilter = NotificationFilter.all.obs;

  final allNotifications = const <NotificationItem>[
    NotificationItem(
      id: '1',
      title: 'New lead assigned',
      subtitle: 'Alice Johnson from tech solutions has been assigned to you.',
      timestamp: '2 minutes ago',
      category: NotificationCategory.leads,
      priority: NotificationPriority.high,
      isUnread: true,
      icon: Icons.person_add_alt_1_rounded,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFDBEAFE),
      categoryLabel: 'Meeting',
    ),
    NotificationItem(
      id: '2',
      title: 'Task Reminder',
      subtitle: 'Follow up with Bob Smith is due in 30 minutes',
      timestamp: '30 minutes ago',
      category: NotificationCategory.tasks,
      priority: NotificationPriority.high,
      isUnread: true,
      icon: Icons.assignment_outlined,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFEF3C7),
      categoryLabel: 'Lead',
    ),
    NotificationItem(
      id: '3',
      title: 'AI escalation assigned',
      subtitle: 'Customer support case ESC-001 requires your attention',
      timestamp: '1 hour ago',
      category: NotificationCategory.escalations,
      priority: NotificationPriority.high,
      isUnread: true,
      icon: Icons.warning_amber_rounded,
      iconColor: Color(0xFFDC2626),
      iconBgColor: Color(0xFFFEE2E2),
      categoryLabel: 'Task',
    ),
    NotificationItem(
      id: '4',
      title: 'Meeting scheduled',
      subtitle: 'Meeting with Design studio confirmed for tomorrow at 2 pm',
      timestamp: '2 hours ago',
      category: NotificationCategory.meetings,
      priority: NotificationPriority.medium,
      isUnread: false,
      icon: Icons.calendar_today_rounded,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFDBEAFE),
      categoryLabel: 'Meeting',
    ),
    NotificationItem(
      id: '5',
      title: 'New lead assigned',
      subtitle: 'Alice Johnson from tech solutions has been assigned to you.',
      timestamp: '30 minutes ago',
      category: NotificationCategory.leads,
      priority: NotificationPriority.high,
      isUnread: false,
      icon: Icons.person_add_alt_1_rounded,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFDBEAFE),
      categoryLabel: 'Lead',
    ),
    NotificationItem(
      id: '6',
      title: 'Task Reminder',
      subtitle: 'Follow up with Bob Smith is due in 30 minutes',
      timestamp: '1 hour ago',
      category: NotificationCategory.tasks,
      priority: NotificationPriority.high,
      isUnread: false,
      icon: Icons.assignment_outlined,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFEF3C7),
      categoryLabel: 'Task',
    ),
    NotificationItem(
      id: '7',
      title: 'Meeting scheduled',
      subtitle: 'Meeting with Structural Team confirmed for Friday at 10 am',
      timestamp: '3 hours ago',
      category: NotificationCategory.meetings,
      priority: NotificationPriority.medium,
      isUnread: false,
      icon: Icons.calendar_today_rounded,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFDBEAFE),
      categoryLabel: 'Meeting',
    ),
    NotificationItem(
      id: '8',
      title: 'New lead assigned',
      subtitle: 'Alice Johnson from tech solutions has been assigned to you.',
      timestamp: '4 hours ago',
      category: NotificationCategory.leads,
      priority: NotificationPriority.high,
      isUnread: false,
      icon: Icons.person_add_alt_1_rounded,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFDBEAFE),
      categoryLabel: 'Task',
    ),
  ];

  List<NotificationItem> get filteredNotifications {
    switch (activeFilter.value) {
      case NotificationFilter.unread:
        return allNotifications.where((n) => n.isUnread).toList();
      case NotificationFilter.leads:
        return allNotifications.where((n) => n.category == NotificationCategory.leads).toList();
      case NotificationFilter.tasks:
        return allNotifications.where((n) => n.category == NotificationCategory.tasks).toList();
      case NotificationFilter.meetings:
        return allNotifications.where((n) => n.category == NotificationCategory.meetings).toList();
      case NotificationFilter.escalations:
        return allNotifications.where((n) => n.category == NotificationCategory.escalations).toList();
      case NotificationFilter.all:
        return allNotifications;
    }
  }

  void setFilter(NotificationFilter filter) {
    activeFilter.value = filter;
  }
}
