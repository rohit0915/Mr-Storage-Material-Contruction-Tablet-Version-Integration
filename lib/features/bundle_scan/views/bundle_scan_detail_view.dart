import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../models/bundle_scan_models.dart';
import '../widgets/bundle_scan_dialogs.dart';

class BundleScanDetailView extends StatelessWidget {
  const BundleScanDetailView({super.key});

  static const _bundleListItems = [
    ('1', 'BND-001', 'STL-B12 × 30', '10:32 AM', '3600 IBS', 'Staged'),
    ('2', 'BND-001', 'STL-B12 × 30', '-', '2400 IBS', 'Pending'),
    ('3', 'BND-001', 'STL-B12 × 30', '-', '4500 IBS', 'Pending'),
    ('4', 'BND-001', 'STL-B12 × 30', '-', '2700 IBS', 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as BundleScanItem?;
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;

    void showSuccess(String title) =>
        BundleScanSuccessDialog.show(context, title);

    return AppScaffold(
      menuTitle: 'Bundle Scan',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, size.height * 0.014, padH, size.height * 0.02),
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
              // Top Action Bar matching Image 2
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
                        _ActionBtn(label: 'Download', onTap: () => showSuccess('Downloaded\nsuccessfully')),
                        _ActionBtn(label: 'Reprint Label', onTap: () => showSuccess('Reprint Label\nsuccessfully')),
                        _ActionBtn(label: 'Report Mismatch', onTap: () => showSuccess('Report Mismatch\nsuccessfully')),
                        _ActionBtn(label: 'Verify Bundle', onTap: () => showSuccess('Verify Bundle\nsuccessfully')),
                        _ActionBtn(label: 'Mark Loaded', onTap: () => showSuccess('Mark Loaded\nsuccessfully')),
                        _ActionBtn(label: 'Mark Staged', onTap: () => showSuccess('Mark Staged\nsuccessfully')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bundle Information & Bundle Details 2-Column Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoSection(
                      title: 'Bundle Information',
                      rows: [
                        ('Bundle ID', item?.bundleId ?? 'BND-001'),
                        ('Project', item?.project ?? 'Riverside Complex'),
                        ('Load ID', 'LOAD-001'),
                        ('Truck', 'TX-9876'),
                        ('Destination', item?.site ?? 'Construction Site A'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _InfoSection(
                      title: 'Bundle Details',
                      rows: [
                        ('Quantity', '30'),
                        ('Weight', '36,000 IBS'),
                        ('Length', '20 ft'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scanned QR Code & Bundle Verification Status Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left QR Code Preview
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scanned QR Code',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.cardBorder),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                AppAssets.qrCode,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'project=${item?.project ?? "RiversideComplex"}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const _QrDetailLine(label: 'Shipper :', value: 'shipper=SHP-1044'),
                                  const _QrDetailLine(label: 'Load :', value: 'load_id=LOAD-001'),
                                  _QrDetailLine(label: 'Bundle :', value: 'bundle_id=${item?.bundleId ?? "BND-001"}'),
                                  _QrDetailLine(label: 'Parts :', value: 'parts=${item?.parts ?? "STL-B12"}'),
                                  const _QrDetailLine(label: 'Weight :', value: 'weight=3600'),
                                  const _QrDetailLine(label: 'Length :', value: 'Length=20'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Right Verification & Load Context Section
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bundle Verification Status',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Text(
                              'Bundle assigned to load',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Spacer(),
                            Icon(Icons.check_rounded, size: 16, color: AppColors.textPrimary),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Load Context Panel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        const _ContextLine(label: 'Load ID', value: 'LOAD-001'),
                        const _ContextLine(label: 'Truck', value: 'TX-9876'),
                        const _ContextLine(label: 'Driver', value: 'John Miler'),
                        const _ContextLine(label: 'Total Products', value: '4'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bundle List Table Section
              const Text(
                'Bundle List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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
                    Container(
                      color: const Color(0xFF1A1A2E),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: const Row(
                        children: [
                          Expanded(flex: 1, child: Text('#', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 3, child: Text('Bundle ID', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 3, child: Text('Parts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Weight', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                          Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white))),
                        ],
                      ),
                    ),
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
                            Expanded(flex: 2, child: Text(r.$6, style: TextStyle(fontSize: 13, color: r.$6 == 'Staged' ? AppColors.textSecondary : AppColors.textSecondary))),
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
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.onTap,
  });

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
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ...rows.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(r.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ),
                const Spacer(),
                Text(
                  r.$2,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QrDetailLine extends StatelessWidget {
  const _QrDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _ContextLine extends StatelessWidget {
  const _ContextLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
