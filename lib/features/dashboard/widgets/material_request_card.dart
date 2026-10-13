import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/routes/app_routes.dart';
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
      height: 400,
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
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.materialRequests),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: linkSize,
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
              id: AppGetIds.materialOverview,
              builder: (controller) {
                if (controller.materialSlices.isEmpty) {
                  return const Center(child: Text('No overview data available'));
                }
                final pendingCount = controller.materialPending.round();
                final totalCount = controller.materialTotal.round();

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: DonutChart(
                          slices: controller.materialSlices,
                          centerTitle: '$pendingCount Pending',
                          centerValue: '$totalCount',
                        ),
                      ),
                    ),
                    SizedBox(height: DashboardGap.section(context)),
                    ChartLegend(
                      slices: controller.materialSlices,
                      totalOverride: totalCount.toDouble(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
