import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'section_card.dart';
import 'status_badge.dart';

class ActiveSitesCard extends GetView<DashboardController> {
  const ActiveSitesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final headerSize = (size.width * 0.009).clamp(10.0, 12.0);
    final cellSize = (size.width * 0.009).clamp(10.0, 12.0);
    final gap = DashboardGap.item(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Active Construction Sites',
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
                  fontSize: headerSize,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.006,
              vertical: size.height * 0.008,
            ),
            decoration: BoxDecoration(
              color: AppColors.tableHeader,
              borderRadius: BorderRadius.circular(DashboardGap.radius),
            ),
            child: Row(
              children: [
                _Header('Project', flex: 3, size: headerSize),
                _Header('Progress', flex: 3, size: headerSize),
                _Header('Deadline', flex: 2, size: headerSize),
                _Header('Delivery Status', flex: 2, size: headerSize),
              ],
            ),
          ),
          SizedBox(height: gap),
          ...controller.sites.map((site) {
            return Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site.project,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: cellSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.chartTeal,
                          ),
                        ),
                        Text(
                          site.location,
                          style: TextStyle(
                            fontSize: cellSize - 1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(site.progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: cellSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: size.height * 0.004),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: site.progress,
                            minHeight: 6,
                            backgroundColor: AppColors.chartTealSoft,
                            valueColor: AlwaysStoppedAnimation(site.barColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      site.deadline,
                      style: TextStyle(
                        fontSize: cellSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(
                        label: site.status,
                        color: site.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text, {required this.flex, required this.size});

  final String text;
  final int flex;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
