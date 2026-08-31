import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../models/dispatch_verification_models.dart';
import '../widgets/dispatch_verification_dialogs.dart';

class DispatchVerificationDetailView extends StatelessWidget {
  const DispatchVerificationDetailView({super.key});

  static const _bundleVerificationItems = [
    ('1', 'BND-001', 'Yes', 'Yes', '3600 IBS', 'Verified'),
  ];

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as DispatchItem?;
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;

    void showSuccess(String title) =>
        DispatchVerificationSuccessDialog.show(context, title);

    return AppScaffold(
      menuTitle: 'Dispatch Verification',
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
              // Top Action Bar matching Image 4
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
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => showSuccess('Dispatch Confirmed\nsuccessfully'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED), // Vibrant purple
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Confirm Dispatch', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => showSuccess('Load Marked Verified\nsuccessfully'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED), // Vibrant purple
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Verify Load', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Load Information & Weight / Loading Verification Grid matching Image 4
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
                        _infoRow('Load ID', item?.loadId ?? 'LOAD-001'),
                        _infoRow('Project', 'Riverside Complex'),
                        _infoRow('Truck', item?.truck ?? 'TX-9876'),
                        _infoRow('Driver', item?.driver ?? 'John Miler'),
                        _infoRow('Destination', item?.destination ?? 'Construction Site A'),
                        _infoRow('Dispatch Date', 'April 5'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Right Column: Weight Verification & Loading Verification
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weight Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _summaryRow('Planned Weight', '36000 lbs'),
                        _summaryRow('Actual Weight', '35900 lbs'),
                        const _CheckRow(label: 'Weight verified'),
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
                        const _CheckRow(label: 'All Bundles assigned to truck are present'),
                        const _CheckRow(label: 'Packing list verified'),
                        const _CheckRow(label: 'Total weight matches load plan'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Bundle Verification List Section matching Image 4
              const Text(
                'Bundle Verification List',
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
                          Expanded(flex: 2, child: Text('Expected', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Scanned', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Weight', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                        ],
                      ),
                    ),
                    // Data Rows
                    ..._bundleVerificationItems.map(
                      (r) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Text(r.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(flex: 3, child: Text(r.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                            Expanded(flex: 2, child: Text(r.$3, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text(r.$4, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text(r.$5, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Expanded(flex: 2, child: Text(r.$6, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
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
