import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'section_card.dart';

class DeadlinesCard extends StatelessWidget {
  const DeadlinesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final itemSize = (size.width * 0.010).clamp(11.0, 13.0);
    final gap = DashboardGap.item(context);

    return SectionCard(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Upcoming Project Deadlines',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.projectCalendar),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: itemSize,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),
          Expanded(
            child: GetBuilder<DashboardController>(
              id: AppGetIds.upcomingDeadlines,
              builder: (controller) {
                final list = controller.deadlines;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No upcoming project deadlines',
                      style: TextStyle(
                        fontSize: itemSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => Divider(
                    height: gap * 1.4,
                    thickness: 1,
                    color: AppColors.cardBorder.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return InkWell(
                      onTap: () {
                        if (item.leadId.isNotEmpty) {
                          Get.toNamed(
                            AppRoutes.projectDetails,
                            arguments: {
                              'id': item.leadId,
                              'title': item.project,
                              'location': item.location,
                              'jobId': item.jobId,
                              'status': item.status,
                              'fromProject': true,
                            },
                          );
                        } else {
                          Get.toNamed(AppRoutes.projectCalendar);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Task Title + Badge Pill
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title.isNotEmpty
                                        ? item.title
                                        : item.project,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: itemSize,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.badgeBgColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: item.badgeDotColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        item.badgeLabel,
                                        style: TextStyle(
                                          fontSize: (itemSize - 2)
                                              .clamp(10.0, 12.0),
                                          fontWeight: FontWeight.w700,
                                          color: item.badgeTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.004),

                            // Subtitle: Project Name • JobId • Location
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    [
                                      item.project,
                                      if (item.jobId.isNotEmpty) item.jobId,
                                      if (item.location.isNotEmpty &&
                                          item.location != '—')
                                        item.location,
                                    ].join(' • '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: itemSize - 1,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.005),

                            // Bottom Row: Dates (Start / Est. End / Completed) & Days Left Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.completedDate != null
                                        ? 'Start: ${item.startDate} • Est: ${item.date} • Done: ${item.completedDate}'
                                        : (item.startDate != '—'
                                            ? 'Start: ${item.startDate} • Est: ${item.date}'
                                            : 'Est End: ${item.date}'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: (itemSize - 1.5)
                                          .clamp(10.0, 12.0),
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.daysLeft,
                                  style: TextStyle(
                                    fontSize: (itemSize - 1).clamp(10.0, 12.0),
                                    fontWeight: FontWeight.w700,
                                    color: (item.daysLeftNumber != null &&
                                                item.daysLeftNumber! < 0) ||
                                            item.badgeTone == 'danger'
                                        ? AppColors.danger
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
