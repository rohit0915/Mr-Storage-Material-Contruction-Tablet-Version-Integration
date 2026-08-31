import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'donut_chart.dart';
import 'section_card.dart';

class MaterialRequestCard extends StatelessWidget {
  const MaterialRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final linkSize = (size.width * 0.009).clamp(10.0, 12.0);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Material Request Overview',
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
                  fontSize: linkSize,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),
          GetBuilder<DashboardController>(
            id: AppGetIds.materialOverview,
            builder: (controller) {
              final pendingCount = controller.materialSlices
                  .fold<double>(0, (sum, item) => sum + item.percent)
                  .round();

              return Column(
                children: [
                  Center(
                    child: DonutChart(
                      slices: controller.materialSlices,
                      centerTitle: 'Pending Approval',
                      centerValue: '$pendingCount',
                    ),
                  ),
                  SizedBox(height: DashboardGap.section(context)),
                  ChartLegend(slices: controller.materialSlices),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
