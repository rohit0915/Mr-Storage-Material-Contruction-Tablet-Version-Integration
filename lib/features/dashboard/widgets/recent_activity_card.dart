import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'section_card.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final itemSize = (size.width * 0.010).clamp(11.0, 13.0);
    final gap = DashboardGap.item(context);
    final iconBox = (size.width * 0.028).clamp(30.0, 36.0);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.01,
                    vertical: size.height * 0.008,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DashboardGap.radius),
                  ),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: itemSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),
          GetBuilder<DashboardController>(
            id: AppGetIds.recentActivities,
            builder: (controller) {
              final list = controller.activities;
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: TextStyle(fontSize: itemSize, color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return Column(
                children: list.map((item) {
                  return Container(
                    margin: EdgeInsets.only(bottom: gap),
                    padding: EdgeInsets.only(bottom: gap),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          item.iconAsset,
                          width: iconBox,
                          height: iconBox,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: size.width * 0.008),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: itemSize,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.008),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: itemSize - 1,
                            color: AppColors.textSecondary,
                          ),
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
