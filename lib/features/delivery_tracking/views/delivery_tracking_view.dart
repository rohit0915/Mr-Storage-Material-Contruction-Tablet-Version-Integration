import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../features/tasks/widgets/task_success_dialog.dart';
import '../controllers/delivery_tracking_controller.dart';
import '../widgets/delivery_card_list.dart';
import '../widgets/delivery_summary_cards.dart';

class DeliveryTrackingView extends GetView<DeliveryTrackingController> {
  const DeliveryTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.011).clamp(12.0, 14.0);
    final btnSize = (size.width * 0.010).clamp(12.0, 14.0);

    return AppScaffold(
      menuTitle: 'Delivery Tracking',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page header — title + subtitle
            Text(
              'Delivery Tracking',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.004),
            Text(
              'Read-only view of deliveries routed through plant/yard/warehouse',
              style: TextStyle(
                fontSize: subSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: gap),
            // Summary cards
            const DeliverySummaryCards(),
            SizedBox(height: gap),
            // Filter / Export / Last updated row (below summary cards)
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Filter',
                      'Filter options coming soon.',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  icon: const Icon(Icons.filter_list_rounded, size: 15),
                  label: Text('Filter',
                      style: TextStyle(
                          fontSize: btnSize, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.012,
                      vertical: size.height * 0.010,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(width: size.width * 0.007),
                OutlinedButton.icon(
                  onPressed: () async {
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const TaskSuccessDialog(
                          title: 'File exported Successfully'),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 15),
                  label: Text('Export',
                      style: TextStyle(
                          fontSize: btnSize, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.012,
                      vertical: size.height * 0.010,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const Spacer(),
                Row(children: [
                  const Icon(Icons.access_time_rounded,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Last updated: Just now',
                      style: TextStyle(
                          fontSize: (size.width * 0.008).clamp(10.0, 12.0),
                          color: AppColors.textSecondary)),
                ]),
              ],
            ),
            SizedBox(height: gap),
            // Read-only notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Read-Only Access',
                          style: TextStyle(
                              fontSize: (size.width * 0.010).clamp(12.0, 14.0),
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue)),
                      Text(
                        'This is a read-only view for plant coordination. You can view deliveries routed through the plant/yard/warehouse but cannot modify delivery information. For delivery management operations, please contact the Construction or Sales team.',
                        style: TextStyle(
                            fontSize: (size.width * 0.009).clamp(11.0, 12.0),
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            SizedBox(height: gap),
            // Delivery cards
            const DeliveryCardList(),
          ],
        ),
      ),
    );
  }
}
