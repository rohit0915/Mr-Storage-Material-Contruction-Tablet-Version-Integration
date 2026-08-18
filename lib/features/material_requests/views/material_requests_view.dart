import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../tasks/widgets/task_success_dialog.dart';
import '../controllers/material_requests_controller.dart';
import '../widgets/add_material_request_dialog.dart';
import '../widgets/material_request_filters_row.dart';
import '../widgets/material_request_summary_cards.dart';
import '../widgets/material_request_table.dart';

class MaterialRequestsView extends GetView<MaterialRequestsController> {
  const MaterialRequestsView({super.key});

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
      menuTitle: 'Material Request',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Material Requests',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        'View & Manage all additional material requests raised by construction teams.',
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
                ElevatedButton.icon(
                  onPressed: () async {
                    await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const AddMaterialRequestDialog(),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    '+ Requests Material',
                    style: TextStyle(
                      fontSize: btnSize,
                      fontWeight: FontWeight.w700,
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            const MaterialRequestFiltersRow(),
            SizedBox(height: gap),
            const MaterialRequestSummaryCards(),
            SizedBox(height: gap),
            const MaterialRequestTable(),
          ],
        ),
      ),
    );
  }
}
