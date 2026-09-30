import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
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
              Text(
                'View All',
                style: TextStyle(
                  fontSize: itemSize,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),
          GetBuilder<DashboardController>(
            id: AppGetIds.upcomingDeadlines,
            builder: (controller) {
              final list = controller.deadlines;
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No upcoming deadlines',
                      style: TextStyle(
                        fontSize: itemSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: list.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: gap),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.project,
                                style: TextStyle(
                                  fontSize: itemSize,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: size.height * 0.003),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.005),
                                  Text(
                                    item.location,
                                    style: TextStyle(
                                      fontSize: itemSize - 1,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.date,
                              style: TextStyle(
                                fontSize: itemSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                              ),
                            ),
                            Text(
                              item.daysLeft,
                              style: TextStyle(
                                fontSize: itemSize - 1,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
