import 'package:flutter/material.dart';

enum NotificationFilter { all, unread, leads, tasks, meetings, escalations }

enum NotificationCategory { leads, tasks, meetings, escalations }

enum NotificationPriority { high, medium, low }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.category,
    required this.priority,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.categoryLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final String timestamp;
  final NotificationCategory category;
  final NotificationPriority priority;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String categoryLabel;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? timestamp,
    NotificationCategory? category,
    NotificationPriority? priority,
    bool? isUnread,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    String? categoryLabel,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isUnread: isUnread ?? this.isUnread,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      categoryLabel: categoryLabel ?? this.categoryLabel,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    final title = json['title'] ?? json['type'] ?? 'Notification';
    final subtitle =
        json['message'] ??
        json['body'] ??
        json['subtitle'] ??
        json['description'] ??
        '';
    final isRead = json['isRead'] ?? json['read'] ?? false;
    final createdAt =
        json['createdAt'] ?? json['timestamp'] ?? json['time'] ?? '';

    String catStr = (json['category'] ?? json['type'] ?? '')
        .toString()
        .toLowerCase();
    NotificationCategory cat = NotificationCategory.tasks;
    String catLabel = 'Task';
    IconData icon = Icons.assignment_outlined;
    Color iconColor = const Color(0xFFD97706);
    Color iconBgColor = const Color(0xFFFEF3C7);

    if (catStr.contains('lead')) {
      cat = NotificationCategory.leads;
      catLabel = 'Lead';
      icon = Icons.person_add_alt_1_rounded;
      iconColor = const Color(0xFF2563EB);
      iconBgColor = const Color(0xFFDBEAFE);
    } else if (catStr.contains('meeting') || catStr.contains('calendar')) {
      cat = NotificationCategory.meetings;
      catLabel = 'Meeting';
      icon = Icons.calendar_today_rounded;
      iconColor = const Color(0xFF2563EB);
      iconBgColor = const Color(0xFFDBEAFE);
    } else if (catStr.contains('escalation') ||
        catStr.contains('alert') ||
        catStr.contains('warning')) {
      cat = NotificationCategory.escalations;
      catLabel = 'Escalation';
      icon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFDC2626);
      iconBgColor = const Color(0xFFFEE2E2);
    }

    String prioStr = (json['priority'] ?? '').toString().toLowerCase();
    NotificationPriority priority = NotificationPriority.medium;
    if (prioStr == 'high' || prioStr == 'urgent') {
      priority = NotificationPriority.high;
    } else if (prioStr == 'low') {
      priority = NotificationPriority.low;
    }

    return NotificationItem(
      id: rawId.toString(),
      title: title.toString(),
      subtitle: subtitle.toString(),
      timestamp: createdAt.toString().isNotEmpty
          ? createdAt.toString()
          : 'Just now',
      category: cat,
      priority: priority,
      isUnread: !isRead,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      categoryLabel: catLabel,
    );
  }
}
