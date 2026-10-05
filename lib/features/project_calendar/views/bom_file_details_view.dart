import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/bom_file_details_controller.dart';
import '../models/bom_details_model.dart';

class BomFileDetailsView extends GetView<BomFileDetailsController> {
  const BomFileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<BomFileDetailsController>()
        ? Get.find<BomFileDetailsController>()
        : Get.put(BomFileDetailsController());

    final size = MediaQuery.sizeOf(context);
    final padH = (size.width * 0.02).clamp(16.0, 24.0);
    final gap = 16.0;

    return AppScaffold(
      menuTitle: 'Project & Calendar',
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: AppShimmerTable(rowCount: 6),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar (Back button, Title, Download button)
              Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'BOM Files Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Top Right Download Button
                  OutlinedButton.icon(
                    onPressed: ctrl.isDownloading.value ? null : () => ctrl.downloadBOM(),
                    icon: ctrl.isDownloading.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined, size: 16),
                    label: Text(
                      ctrl.isDownloading.value ? 'Downloading...' : 'Download',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main Card Container (White with rounded corners matching web)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle: Project: Storage 0011
                    Text(
                      'Project: ${ctrl.projectName.value.isNotEmpty ? ctrl.projectName.value : 'Storage 0011'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BOM Summary Card
                    _buildBomSummaryBox(ctrl),
                    const SizedBox(height: 28),

                    // Consolidated Bill of Materials Box (with border)
                    _buildConsolidatedHeaderBox(ctrl),
                    const SizedBox(height: 24),

                    // Consolidated BOM Table
                    _buildBomTable(ctrl),

                    // Attached BOM files download list (if available)
                    if (ctrl.bomFiles.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Divider(color: AppColors.cardBorder),
                      const SizedBox(height: 16),
                      Text(
                        'Attached Files (${ctrl.bomFiles.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: ctrl.bomFiles.map((f) {
                          return OutlinedButton.icon(
                            onPressed: () => ctrl.downloadBOM(f),
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                            label: Text(
                              f['name'] ?? 'BOM File.pdf',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.cardBorder),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBomSummaryBox(BomFileDetailsController ctrl) {
    final summary = ctrl.bomSummary.value ??
        const BomSummaryModel(
          totalItems: 40,
          totalWeight: '55,789.2 lbs',
          totalPanelsArea: '5,608.58 sqft',
          totalCost: '\$77,230.47',
        );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BOM Summary',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 14),
            _summaryRow('Total Items', '${summary.totalItems}', isBoldValue: false),
            const SizedBox(height: 10),
            _summaryRow('Total Weight', summary.totalWeight, isBoldValue: true),
            const SizedBox(height: 10),
            _summaryRow('Total Panels Area', summary.totalPanelsArea, isBoldValue: true),
            const SizedBox(height: 10),
            _summaryRow('Total Cost', summary.totalCost, isBoldValue: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBoldValue = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildConsolidatedHeaderBox(BomFileDetailsController ctrl) {
    const borderColor = Colors.black;
    const borderWidth = 1.2;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor, width: borderWidth)),
                  ),
                  child: Image.asset(
                    AppAssets.logo,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'STEEL BUILDING DEPOT',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E3A8A)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor, width: borderWidth)),
                  ),
                  child: const Text(
                    'CONSOLIDATED BILL OF MATERIALS',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
                _tableKeyValueRow('Customer:', ctrl.customerName.value.isNotEmpty ? ctrl.customerName.value : 'Namra', borderColor, borderWidth),
                _tableKeyValueRow('Project Name:', ctrl.projectName.value.isNotEmpty ? ctrl.projectName.value : 'Storage 0011', borderColor, borderWidth),
                _tableKeyValueRow('Date:', ctrl.date.value.isNotEmpty ? ctrl.date.value : '01/10/26', borderColor, borderWidth),
                _tableKeyValueRow('Job Id:', ctrl.jobId.value.isNotEmpty ? ctrl.jobId.value : '2026014', borderColor, borderWidth, isLast: true),
              ],
            );
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Logo Cell
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: borderColor, width: borderWidth)),
                    ),
                    child: Image.asset(
                      AppAssets.logo,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'STEEL BUILDING DEPOT',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E3A8A)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // Middle: CONSOLIDATED BILL OF MATERIALS + Customer + Project
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Container(
                        height: 38,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: borderColor, width: borderWidth)),
                        ),
                        child: const Text(
                          'CONSOLIDATED BILL OF MATERIALS',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: borderColor, width: borderWidth)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(right: BorderSide(color: borderColor, width: borderWidth)),
                                ),
                                child: const Text('Customer:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    ctrl.customerName.value.isNotEmpty ? ctrl.customerName.value : 'Namra',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: borderColor, width: borderWidth)),
                              ),
                              child: const Text('Project Name:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  ctrl.projectName.value.isNotEmpty ? ctrl.projectName.value : 'Storage 0011',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Metadata: Date & Job Id
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: borderColor, width: borderWidth)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: borderColor, width: borderWidth)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    border: Border(right: BorderSide(color: borderColor, width: borderWidth)),
                                  ),
                                  child: const Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      ctrl.date.value.isNotEmpty ? ctrl.date.value : '01/10/26',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(right: BorderSide(color: borderColor, width: borderWidth)),
                                ),
                                child: const Text('Job Id', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    ctrl.jobId.value.isNotEmpty ? ctrl.jobId.value : '2026014',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tableKeyValueRow(String key, String value, Color borderCol, double bWidth, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: borderCol, width: bWidth)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildBomTable(BomFileDetailsController ctrl) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < 1050 ? 1050.0 : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                  ),
                  child: Row(
                    children: [
                      _th(ctrl, 'QTY', flex: 1, sortable: true),
                      _th(ctrl, 'Mark', flex: 2, sortable: true),
                      _th(ctrl, 'Description', flex: 3, sortable: true),
                      _th(ctrl, 'Part Code', flex: 2, sortable: true),
                      _th(ctrl, 'Color', flex: 1, sortable: true),
                      _th(ctrl, 'Category', flex: 3, sortable: true),
                      _th(ctrl, 'Bldg', flex: 1),
                      _th(ctrl, 'Length', flex: 2, sortable: true),
                      _th(ctrl, 'Weight (lbs)', flex: 2, sortable: true),
                      _th(ctrl, 'Cost', flex: 2, sortable: true),
                    ],
                  ),
                ),

                // Table Rows
                Obx(() {
                  final items = ctrl.items;
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No BOM items found.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
                        ),
                        child: Row(
                          children: [
                            // QTY
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${item.qty}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)),
                              ),
                            ),
                            // Mark
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.mark,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)),
                              ),
                            ),
                            // Description
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.description,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ),
                            // Part Code
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.partCode,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155)),
                              ),
                            ),
                            // Color
                            Expanded(
                              flex: 1,
                              child: Text(
                                item.color,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ),
                            // Category
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.category,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569)),
                              ),
                            ),
                            // Bldg
                            Expanded(
                              flex: 1,
                              child: Text(
                                item.bldg,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ),
                            // Length
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.length,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                              ),
                            ),
                            // Weight (lbs)
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.weight,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ),
                            // Cost
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.cost,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _th(BomFileDetailsController ctrl, String label, {required int flex, bool sortable = false}) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: sortable ? () => ctrl.sort(label) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (sortable) ...[
              const SizedBox(width: 4),
              const Icon(Icons.unfold_more, size: 13, color: Color(0xFF94A3B8)),
            ],
          ],
        ),
      ),
    );
  }
}
