import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'donut_chart.dart';
import 'section_card.dart';

class DeliveryOverviewCard extends GetView<DashboardController> {
  const DeliveryOverviewCard({super.key});

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
          Center(
            child: DonutChart(
              slices: controller.deliverySlices,
              centerTitle: "Today's Deliveries",
              centerValue: '28',
            ),
          ),
          SizedBox(height: DashboardGap.section(context)),
          ChartLegend(slices: controller.deliverySlices),
        ],
      ),
    );
  }
}
