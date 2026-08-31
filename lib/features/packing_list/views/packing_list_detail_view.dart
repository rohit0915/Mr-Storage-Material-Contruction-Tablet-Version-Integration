import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../models/packing_list_models.dart';
import '../widgets/packing_list_dialogs.dart';

class PackingListDetailView extends StatelessWidget {
  const PackingListDetailView({super.key});

  static const _bundleListItems = [
    ('1', 'BND-001', 'STL-B12', '30', '20 ft', '3600 IBS', 'Staged'),
    ('2', 'BND-002', 'STL-B13', '40', '30 ft', '2400 IBS', 'Ready'),
    ('3', 'BND-003', 'STL-B14', '50', '15 ft', '4500 IBS', 'Staged'),
  ];

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as PackingListItem?;
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;

    void showSuccess(String title) =>
        PackingListSuccessDialog.show(context, title);

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
              // Top Action Bar matching Image 1
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.end,
                      children: [
                        _ActionBtn(
                          label: 'Download PDF',
                          onTap: () => showSuccess('Packing List\nDownloaded'),
                        ),
                        _ActionBtn(
                          label: 'Print Packing List',
                          onTap: () => showSuccess('Packing List\nDownloaded'),
                        ),
                        _ActionBtn(
                          label: 'Export Excel',
                          onTap: () => showSuccess('Exported Excel\nsuccessfully'),
                        ),
                        _ActionBtn(
                          label: 'Print Selected',
                          onTap: () => showSuccess('Printed Selected\nsuccessfully'),
                        ),
                        _ActionBtn(
                          label: 'Mark Ready',
                          onTap: () => showSuccess('Marked Ready\nsuccessfully'),
                        ),
                        _ActionBtn(
                          label: 'Mark Loading',
                          onTap: () => showSuccess('Mark Loading\nsuccessfully'),
                        ),
                        _ActionBtn(
                          label: 'Mark Dispatch',
                          onTap: () => showSuccess('Marked dispatch\nsuccessfully'),
                        ),
                      ],
                    ),
                   ),
                ],
              ),
              const SizedBox(height: 24),

              // Load Information & Packing Summary / Loading Verification Grid matching Image 1
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
                        _infoRow('Packing List ID', item?.packingListId ?? 'PKL-001'),
                        _infoRow('Load ID', item?.loadId ?? 'LOAD-001'),
                        _infoRow('Project', 'Riverside Complex'),
                        _infoRow('Truck', item?.truck ?? 'TX-9876'),
                        _infoRow('Driver', 'John Miler'),
                        _infoRow('Destination', item?.destination ?? 'Construction Site A'),
                        _infoRow('Dispatch Date', 'April 5'),
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
                        _summaryRow('Total Bundles', '${item?.bundles ?? 3}'),
                        _summaryRow('Total Items', '150'),
                        _summaryRow('Total weight', item?.totalWeight ?? '36,000 lbs'),
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

              // Bundle List Table Section matching Image 1
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: const Row(
                        children: [
                          Expanded(flex: 1, child: Text('#', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 3, child: Text('Bundle ID', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 3, child: Text('Part Number', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Length', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Weight', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                        ],
                      ),
                    ),
                    // Data Rows
                    ..._bundleListItems.map(
                      (r) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Text(r.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(flex: 3, child: Text(r.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                            Expanded(flex: 3, child: Text(r.$3, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text(r.$4, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text(r.$5, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text(r.$6, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: r.$7 == 'Ready' ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  r.$7,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: r.$7 == 'Ready' ? AppColors.success : AppColors.primaryBlue,
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

  static Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ],
        ),
      );

  static Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ],
        ),
      );
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
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED), // Vibrant purple
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
