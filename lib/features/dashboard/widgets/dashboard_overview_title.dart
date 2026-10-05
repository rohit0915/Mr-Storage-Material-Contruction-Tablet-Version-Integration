import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/get_builder_ids.dart';
import '../controllers/dashboard_controller.dart';

import '../../../app/theme/app_colors.dart';
import '../models/dashboard_models.dart';

class DashboardOverviewTitle extends StatelessWidget {
  const DashboardOverviewTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.018).clamp(18.0, 24.0);
    final subSize = (size.width * 0.011).clamp(12.0, 14.0);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.chartTeal,
                ),
              ),
              SizedBox(height: size.height * 0.004),
              Text(
                'Construction Department Performance',
                style: TextStyle(
                  fontSize: subSize,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GetBuilder<DashboardController>(
          id: AppGetIds.dashboardMetrics,
          builder: (controller) => ElevatedButton.icon(
            onPressed:
                controller.isLoading ||
                    controller.isExporting ||
                    !controller.hasLoadedData ||
                    controller.errorMessage.isNotEmpty
                ? null
                : controller.exportReport,
            icon: controller.isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded, size: 18),
            label: Text(
              controller.isExporting ? 'Exporting…' : 'Export Report',
              style: TextStyle(
                fontSize: (size.width * 0.011).clamp(12.0, 14.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.014,
                vertical: size.height * 0.014,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DashboardGap.radius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
