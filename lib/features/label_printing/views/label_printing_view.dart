import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../../tasks/widgets/task_success_dialog.dart';
import '../controllers/label_printing_controller.dart';
import '../widgets/label_print_success_dialog.dart';
import '../widgets/label_printing_summary_cards.dart';
import '../widgets/label_printing_table.dart';
import '../widgets/label_printing_toolbar.dart';

class LabelPrintingView extends GetView<LabelPrintingController> {
  const LabelPrintingView({super.key});

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
      menuTitle: 'Label Printing',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (Navigator.of(context).canPop()) ...[
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Label Printing',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        'Generate and reprint QR labels for bundles to ensure accurate tracking during staging, loading, and dispatch.',
                        style: TextStyle(
                          fontSize: subSize,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const TaskSuccessDialog(
                        title: 'File exported Successfully',
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    'Export',
                    style: TextStyle(
                      fontSize: btnSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.014,
                      vertical: size.height * 0.014,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.008),
                Obx(() {
                  final count = controller.selectedCount;
                  return ElevatedButton(
                    onPressed: count == 0
                        ? () async {
                            await LabelPrintSuccessDialog.show(
                              title: '20 Labels Printed successfully',
                            );
                          }
                        : () async {
                            final printCount = count;
                            controller.markSelectedAsPrinted();
                            await LabelPrintSuccessDialog.show(
                              title: '$printCount Labels Printed successfully',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF7C3AED,
                      ), // Vibrant purple matching Image 1
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.014,
                        vertical: size.height * 0.014,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Print Selected',
                      style: TextStyle(
                        fontSize: btnSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ],
            ),
            SizedBox(height: gap),
            const LabelPrintingSummaryCards(),
            SizedBox(height: gap),
            const LabelPrintingToolbar(),
            SizedBox(height: gap),
            Obx(
              () => controller.isLoading.value
                  ? const AppShimmerTable(rowCount: 6)
                  : const LabelPrintingTable(),
            ),
          ],
        ),
      ),
    );
  }
}
