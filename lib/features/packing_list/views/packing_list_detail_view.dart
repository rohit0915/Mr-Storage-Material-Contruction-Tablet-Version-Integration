import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../models/packing_list_models.dart';
import '../controllers/packing_list_controller.dart';
import '../widgets/packing_list_dialogs.dart';

class PackingListDetailView extends StatelessWidget {
  const PackingListDetailView({super.key});

  static const _bundleListItems =
      <(String, String, String, String, String, String, String)>[];

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as PackingListItem?;
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;

    final controller = Get.find<PackingListController>();

    final pklId = item?.packingListId ?? '—';
    final jobId = item?.jobId.isNotEmpty == true ? item!.jobId : '—';
    final project = item?.project.isNotEmpty == true ? item!.project : '—';
    final truck = item?.truck.isNotEmpty == true ? item!.truck : '—';
    final destination = item?.destination.isNotEmpty == true
        ? item!.destination
        : '—';
    final statusStr = item?.statusText.isNotEmpty == true
        ? item!.statusText
        : '—';
    final weightStr = item?.totalWeight.isNotEmpty == true
        ? item!.totalWeight
        : '—';
    final bundlesCount = item?.bundles ?? 0;

    return AppScaffold(
      menuTitle: 'Packing List',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          padH,
          size.height * 0.014,
          padH,
          size.height * 0.02,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Bar
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.end,
                      children: [
                        _ActionBtn(
                          label: 'DOWNLOAD PDF',
                          onTap: item == null
                              ? null
                              : () async {
                                  final url = await controller.downloadPdf(
                                    item.id,
                                  );
                                  if (url != null && context.mounted) {
                                    await PackingListSuccessDialog.show(
                                      context,
                                      'Packing List\nDownloaded',
                                    );
                                  }
                                },
                        ),
                        _ActionBtn(label: 'PRINT PACKING LIST', onTap: null),
                        _ActionBtn(
                          label: 'EXPORT EXCEL',
                          onTap: () async {
                            final url = await controller.exportExcel();
                            if (url != null && context.mounted) {
                              await PackingListSuccessDialog.show(
                                context,
                                'Exported Excel\nsuccessfully',
                              );
                            }
                          },
                        ),
                        _ActionBtn(
                          label: 'MARK READY',
                          onTap: item == null
                              ? null
                              : () async {
                                  final success = await controller
                                      .markReadyForDispatch(item.id);
                                  if (success && context.mounted) {
                                    await PackingListSuccessDialog.show(
                                      context,
                                      'Marked Ready\nsuccessfully',
                                    );
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Load Information & Packing Summary / Loading Verification Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Load Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Load Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _infoRow('PACKING LIST ID', pklId),
                        _infoRow('JOB ID', jobId),
                        _infoRow('PROJECT', project),
                        _infoRow('TRUCK', truck),
                        _infoRow('DESTINATION', destination),
                        _infoRow('STATUS', statusStr),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Right Column: Packing Summary & Loading Verification
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Packing Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _summaryRow('TOTAL BUNDLES', '$bundlesCount'),
                        _summaryRow('TOTAL ITEMS', '—'),
                        _summaryRow('TOTAL WEIGHT', weightStr),
                        const SizedBox(height: 20),
                        const Text(
                          'Loading Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _CheckRow(label: 'All Bundles Present'),
                        const _CheckRow(label: 'QR Labels Verified'),
                        const _CheckRow(label: 'Packing List Matches Load'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Bundle List Table Section
              const Text(
                'Bundle List',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Dark Header
                    Container(
                      color: const Color(0xFF1A1A2E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '#',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'BUNDLE ID',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'PART CODE / DESCRIPTION',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'QUANTITY',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'LENGTH',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'WEIGHT',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'STATUS',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Data Rows
                    ..._bundleListItems.map(
                      (r) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                r.$1,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                r.$2,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                r.$3,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                r.$4,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                r.$5,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                r.$6,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  r.$7,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
