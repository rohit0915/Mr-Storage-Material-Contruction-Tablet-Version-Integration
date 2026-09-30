import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/bom_file_details_controller.dart';

class BomFileDetailsView extends GetView<BomFileDetailsController> {
  const BomFileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final ctrl = Get.isRegistered<BomFileDetailsController>()
        ? Get.find<BomFileDetailsController>()
        : Get.put(BomFileDetailsController());

    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    return AppScaffold(
      menuTitle: 'BOM File Details',
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: AppShimmerTable(rowCount: 6),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Navigation & Action Button
              Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 38,
                      height: 38,
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
                  SizedBox(width: size.width * 0.01),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BOM File Details',
                          style: TextStyle(
                            fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ctrl.projectName.value.isNotEmpty
                              ? ctrl.projectName.value
                              : 'Project Details',
                          style: TextStyle(
                            fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: ctrl.bomFiles.isEmpty
                        ? null
                        : () => ctrl.downloadBOM(),
                    icon: ctrl.isDownloading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.download_outlined, size: 18),
                    label: Text(
                      ctrl.isDownloading.value
                          ? 'Downloading...'
                          : 'Download BOM',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),

              // Top Overview Cards Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Overview Card
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'PROJECT OVERVIEW',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              if (ctrl.status.value.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.softBlueBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ctrl.status.value,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ctrl.projectName.value.isNotEmpty
                                ? ctrl.projectName.value
                                : '—',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ctrl.jobId.value.isNotEmpty
                                ? '# ${ctrl.jobId.value}'
                                : '—',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (ctrl.customerName.value.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Customer: ${ctrl.customerName.value}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (ctrl.location.value.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ctrl.location.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ctrl.date.value.isNotEmpty
                                    ? ctrl.date.value
                                    : 'Active Project',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.014),

                  // BOM Summary Card
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BOM SUMMARY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatBox(
                                  label: 'BOM Files',
                                  value: '${ctrl.bomFiles.length}',
                                  unit: 'attached',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatBox(
                                  label: 'Building Type',
                                  value: ctrl.buildingType.value.isNotEmpty
                                      ? ctrl.buildingType.value
                                      : 'Commercial',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatBox(
                                  label: 'Items Count',
                                  value: ctrl.materialItems.isNotEmpty
                                      ? '${ctrl.materialItems.length}'
                                      : 'Available',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),

              // Attached BOM Files Section (Direct from API)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: AppColors.primaryBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PROJECT BOM FILES (${ctrl.bomFiles.length})',
                          style: TextStyle(
                            fontSize: (size.width * 0.014).clamp(15.0, 18.0),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (ctrl.buildingType.value.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ctrl.buildingType.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ctrl.customerName.value.isNotEmpty
                          ? 'Customer: ${ctrl.customerName.value}'
                          : 'Official confirmed BOM documents from Engineering & Plant panel',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (ctrl.bomFiles.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.softBlueBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Center(
                          child: Text(
                            'No BOM files uploaded for this project yet in the API response.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ctrl.bomFiles.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final file = ctrl.bomFiles[index];
                          final fileName = file['name'] ?? 'Project BOM.pdf';
                          final fileUrl = file['url'] ?? '';
                          final isSelected = ctrl.selectedFile.value == file;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.softBlueBg : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.cardBorder,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        fileUrl.isNotEmpty
                                            ? fileUrl
                                            : 'Document link verified',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => ctrl.downloadBOM(file),
                                  icon: const Icon(Icons.download_rounded, size: 16),
                                  label: const Text('Download / View'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: gap),

              // Storage Materials / Line Items Table (from API if available)
              if (ctrl.materialItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'STORAGE MATERIALS (${ctrl.materialItems.length})',
                            style: TextStyle(
                              fontSize: (size.width * 0.014).clamp(15.0, 18.0),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Container(
                              color: AppColors.tableHeader,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _TableHeaderCell(text: 'QTY'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: _TableHeaderCell(text: 'Item / Code'),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: _TableHeaderCell(text: 'Description'),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: _TableHeaderCell(text: 'Unit / Spec'),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.cardBorder),
                            ...ctrl.materialItems.map((item) {
                              final qty = (item['quantity'] ?? item['qty'] ?? '1').toString();
                              final mark = (item['mark'] ?? item['code'] ?? item['partCode'] ?? item['name'] ?? '—').toString();
                              final desc = (item['description'] ?? item['notes'] ?? item['category'] ?? item['name'] ?? 'Material item').toString();
                              final part = (item['part'] ?? item['unit'] ?? item['spec'] ?? 'pkg').toString();

                              return Column(
                                children: [
                                  _TableRowItem(
                                    qty: qty,
                                    mark: mark,
                                    desc: desc,
                                    part: part,
                                  ),
                                  const Divider(height: 1, color: AppColors.cardBorder),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlueBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  const _TableRowItem({
    required this.qty,
    required this.mark,
    required this.desc,
    required this.part,
  });

  final String qty;
  final String mark;
  final String desc;
  final String part;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              qty,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              mark,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              desc,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              part,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
