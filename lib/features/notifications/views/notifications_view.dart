import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_models.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);

    return AppScaffold(
      menuTitle: 'Notifications',
      body: RefreshIndicator(
        onRefresh: () => controller.fetchNotifications(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Subtitle + Mark All Read Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        'Stay updated with your latest activities and alerts',
                        style: TextStyle(
                          fontSize: subSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.markAllAsRead(),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Mark All as Read'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap * 1.2),

              // Dynamic Stat Cards Row
              Obx(() {
                final all = controller.allNotifications;
                final totalCount = all.length;
                final unreadCount = controller.unreadCount.value;
                final highCount = all
                    .where((n) => n.priority == NotificationPriority.high)
                    .length;
                final todayCount = all
                    .where(
                      (n) =>
                          n.timestamp.toLowerCase().contains('today') ||
                          n.timestamp.toLowerCase().contains('min') ||
                          n.timestamp.toLowerCase().contains('hour'),
                    )
                    .length;

                final card1 = _SolidStatCard(
                  title: 'Total',
                  value: '$totalCount',
                  bgColor: const Color(0xFF1E40AF),
                );
                final card2 = _SolidStatCard(
                  title: 'Unread',
                  value: '$unreadCount',
                  bgColor: const Color(0xFF16A34A),
                );
                final card3 = _SolidStatCard(
                  title: 'High Priority',
                  value: '$highCount',
                  bgColor: const Color(0xFFEAB308),
                );
                final card4 = _SolidStatCard(
                  title: 'Today',
                  value: '$todayCount',
                  bgColor: const Color(0xFFF97316),
                );

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape = constraints.maxWidth > 700;
                    if (isLandscape) {
                      return Row(
                        children: [
                          Expanded(child: card1),
                          const SizedBox(width: 12),
                          Expanded(child: card2),
                          const SizedBox(width: 12),
                          Expanded(child: card3),
                          const SizedBox(width: 12),
                          Expanded(child: card4),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: card1),
                            const SizedBox(width: 12),
                            Expanded(child: card2),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: card3),
                            const SizedBox(width: 12),
                            Expanded(child: card4),
                          ],
                        ),
                      ],
                    );
                  },
                );
              }),
              SizedBox(height: gap * 1.2),

              // Filter Toolbar Row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Text(
                      'Filter by:',
                      style: TextStyle(
                        fontSize: subSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(() {
                          final active = controller.activeFilter.value;
                          final all = controller.allNotifications;
                          final unread = all.where((n) => n.isUnread).length;
                          final leads = all
                              .where(
                                (n) => n.category == NotificationCategory.leads,
                              )
                              .length;
                          final tasks = all
                              .where(
                                (n) => n.category == NotificationCategory.tasks,
                              )
                              .length;
                          final meetings = all
                              .where(
                                (n) =>
                                    n.category == NotificationCategory.meetings,
                              )
                              .length;
                          final escalations = all
                              .where(
                                (n) =>
                                    n.category ==
                                    NotificationCategory.escalations,
                              )
                              .length;

                          return Row(
                            children: [
                              _FilterChip(
                                label: 'All (${all.length})',
                                selected: active == NotificationFilter.all,
                                onTap: () => controller.setFilter(
                                  NotificationFilter.all,
                                ),
                              ),
                              _FilterChip(
                                label: 'Unread ($unread)',
                                selected: active == NotificationFilter.unread,
                                onTap: () => controller.setFilter(
                                  NotificationFilter.unread,
                                ),
                              ),
                              _FilterChip(
                                label: 'Leads ($leads)',
                                selected: active == NotificationFilter.leads,
                                onTap: () => controller.setFilter(
                                  NotificationFilter.leads,
                                ),
                              ),
                              _FilterChip(
                                label: 'Tasks ($tasks)',
                                selected: active == NotificationFilter.tasks,
                                onTap: () => controller.setFilter(
                                  NotificationFilter.tasks,
                                ),
                              ),
                              _FilterChip(
                                label: 'Meetings ($meetings)',
                                selected: active == NotificationFilter.meetings,
                                onTap: () => controller.setFilter(
                                  NotificationFilter.meetings,
                                ),
                              ),
                              _FilterChip(
                                label: 'Escalations ($escalations)',
                                selected:
                                    active == NotificationFilter.escalations,
                                onTap: () => controller.setFilter(
                                  NotificationFilter.escalations,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: gap * 1.2),

              // Notifications List / Loading / Empty Container
              Obx(() {
                if (controller.isLoading.value) {
                  return const AppShimmerTable(rowCount: 5, rowHeight: 60);
                }

                final items = controller.filteredNotifications;
                if (items.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Notifications Found',
                          style: TextStyle(
                            fontSize: subSize + 2,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You have no notifications under this category.',
                          style: TextStyle(
                            fontSize: subSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.cardBorder),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      return _NotificationTile(
                        item: n,
                        fontSize: subSize,
                        onTap: () => controller.markAsRead(n.id),
                        onDelete: () => controller.removeNotification(n.id),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SolidStatCard extends StatelessWidget {
  const _SolidStatCard({
    required this.title,
    required this.value,
    required this.bgColor,
  });

  final String title;
  final String value;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: bgColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.fontSize,
    required this.onTap,
    required this.onDelete,
  });
  final NotificationItem item;
  final double fontSize;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isUnread ? const Color(0xFFF0F9FF) : Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: fontSize + 1,
                            fontWeight: item.isUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        item.timestamp,
                        style: TextStyle(
                          fontSize: fontSize - 1,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _PriorityBadge(priority: item.priority),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.categoryLabel,
                          style: TextStyle(
                            fontSize: fontSize - 2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final NotificationPriority priority;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (priority) {
      NotificationPriority.high => (
        'High priority',
        const Color(0xFFFEE2E2),
        const Color(0xFFEF4444),
      ),
      NotificationPriority.medium => (
        'medium priority',
        const Color(0xFFFEF3C7),
        const Color(0xFFD97706),
      ),
      NotificationPriority.low => (
        'low priority',
        const Color(0xFFDCFCE7),
        const Color(0xFF16A34A),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
