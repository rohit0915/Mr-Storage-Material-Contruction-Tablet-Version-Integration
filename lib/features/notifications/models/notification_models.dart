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
}
