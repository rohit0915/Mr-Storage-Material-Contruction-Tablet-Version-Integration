import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'donut_chart.dart';
import 'section_card.dart';

class DeliveryOverviewCard extends StatelessWidget {
  const DeliveryOverviewCard({super.key});

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
                  'Delivery Overview',
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
          Expanded(
            child: GetBuilder<DashboardController>(
              id: AppGetIds.deliveryOverview,
              builder: (controller) {
                if (controller.deliverySlices.isEmpty) {
                  return const Center(child: Text('No overview data available'));
                }
                final totalCount = controller.deliveryTotal.round();

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: DonutChart(
                          slices: controller.deliverySlices,
                          centerTitle: "Today's Deliveries",
                          centerValue: '$totalCount',
                        ),
                      ),
                    ),
                    SizedBox(height: DashboardGap.section(context)),
                    ChartLegend(
                      slices: controller.deliverySlices,
                      totalOverride: controller.deliveryTotal,
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
