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
    ('1', 'BND-001', 'STL-B12 + 30', '10:32 AM', '3800 lbs', 'Staged'),
    ('2', 'BND-001', 'STL-B12 + 30', '-', '2400 lbs', 'Pending'),
    ('3', 'BND-001', 'STL-B12 + 30', '-', '4500 lbs', 'Pending'),
    ('4', 'BND-001', 'STL-B12 + 30', '-', '2700 lbs', 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as BundleScanItem?;
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final labelSize = (size.width * 0.009).clamp(10.0, 12.0);
    final valueSize = (size.width * 0.010).clamp(12.0, 13.0);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);

    void showSuccess(String title) =>
        BundleScanSuccessDialog.show(context, title);

    return AppScaffold(
      menuTitle: 'Bundle Scan',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, size.height * 0.014, padH, size.height * 0.02),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.014,
            vertical: size.height * 0.014,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: Back + action buttons
              Row(
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          size: 13, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text('Back',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: [
                      _ActionBtn(label: 'Download', icon: Icons.download_rounded, onTap: () => showSuccess('Downloaded\nsuccessfully')),
                      _ActionBtn(label: 'Reprint Label', icon: Icons.print_outlined, onTap: () => showSuccess('Reprint Label\nsuccessfully')),
                      _ActionBtn(label: 'Report Mismatch', icon: Icons.warning_amber_rounded, onTap: () => showSuccess('Report Mismatch\nsuccessfully')),
                      _ActionBtn(label: 'Verify Bundle', icon: Icons.verified_outlined, onTap: () => showSuccess('Verify Bundle\nsuccessfully')),
                      _ActionBtn(label: 'Mark Loaded', icon: Icons.check_box_outlined, onTap: () => showSuccess('Mark Loaded\nsuccessfully')),
                      _ActionBtn(label: 'Mark Staged', icon: Icons.inventory_2_outlined, onTap: () => showSuccess('Mark Staged\nsuccessfully')),
                    ],
                  ),
                ),
              ],
              ),
              const SizedBox(height: 18),
              // Bundle Info + Details two-column
              Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoSection(title: 'Bundle Information', rows: [
                    ('Bundle ID', item?.bundleId ?? 'BND-001'),
                    ('Project', item?.project ?? 'Riverside Complex'),
                    ('Load ID', 'LOAD-001'),
                    ('Truck', 'TX-9876'),
                    ('Destination', item?.site ?? 'Construction Site A'),
                  ], labelSize: labelSize, valueSize: valueSize, titleSize: titleSize),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _InfoSection(title: 'Bundle Details', rows: [
                    ('Quantity', '30'),
                    ('Weight', '36,000 lbs'),
                    ('Length', '20 ft'),
                  ], labelSize: labelSize, valueSize: valueSize, titleSize: titleSize),
                ),
              ],
              ),
              const SizedBox(height: 20),
              // Scanned QR Code + Verification side by side
              Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scanned QR Code',
                          style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(AppAssets.qrCode,
                              width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('project=${item?.project ?? "RiversideComplex"}',
                                  style: TextStyle(
                                      fontSize: labelSize,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              _QrRow('Shipper', 'shipper=SHP-1044', labelSize),
                              _QrRow('Load', 'load_id=LOAD-001', labelSize),
                              _QrRow('Bundle', 'bundle_id=${item?.bundleId ?? "BND-001"}', labelSize),
                              _QrRow('Parts', 'parts=${item?.parts ?? "STL-B12"}', labelSize),
                              _QrRow('Weight', 'weight=3800', labelSize),
                              _QrRow('Length', 'Length=20', labelSize),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bundle Verification Status',
                          style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text('Bundle assigned to load',
                            style: TextStyle(
                                fontSize: labelSize,
                                color: AppColors.textSecondary)),
                        const SizedBox(width: 6),
                        const Icon(Icons.check_rounded,
                            size: 16, color: AppColors.success),
                      ]),
                      const SizedBox(height: 14),
                      Text('Load Context Panel',
                          style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      _CtxRow('Load ID', 'LOAD-001', labelSize),
                      _CtxRow('Truck', 'TX-9876', labelSize),
                      _CtxRow('Driver', 'John Miller', labelSize),
                      _CtxRow('Total Products', '4', labelSize),
                    ],
                  ),
                ),
              ],
              ),
              const SizedBox(height: 20),
              // Bundle List table
              Text('Bundle List',
                style: TextStyle(
                    fontSize: titleSize + 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(children: [
                      tableHead('#', 1, labelSize),
                      tableHead('Bundle ID', 3, labelSize),
                      tableHead('Parts', 3, labelSize),
                      tableHead('Time', 2, labelSize),
                      tableHead('Weight', 2, labelSize),
                      tableHead('Status', 2, labelSize),
                    ]),
                  ),
                  ..._bundleListItems.map((r) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppColors.cardBorder)),
                        ),
                        child: Row(children: [
                          tableData(r.$1, 1, labelSize),
                          tableData(r.$2, 3, labelSize, bold: true),
                          tableData(r.$3, 3, labelSize),
                          tableData(r.$4, 2, labelSize),
                          tableData(r.$5, 2, labelSize),
                          Expanded(
                            flex: 2,
                            child: _StatusPill(r.$6),
                          ),
                        ]),
                      )),
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

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fontSize =
        (MediaQuery.sizeOf(context).width * 0.008).clamp(10.0, 11.0);
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 12, color: Colors.white),
      label: Text(label,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.rows,
    required this.labelSize,
    required this.valueSize,
    required this.titleSize,
  });
  final String title;
  final List<(String, String)> rows;
  final double labelSize, valueSize, titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      ...rows.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(children: [
              SizedBox(
                width: 100,
                child: Text(r.$1,
                    style: TextStyle(
                        fontSize: labelSize,
                        color: AppColors.textSecondary)),
              ),
              Expanded(
                child: Text(r.$2,
                    style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
            ]),
          )),
    ]);
  }
}

class _QrRow extends StatelessWidget {
  const _QrRow(this.label, this.value, this.fontSize);
  final String label, value;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          SizedBox(
            width: 52,
            child: Text('$label:',
                style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _CtxRow extends StatelessWidget {
  const _CtxRow(this.label, this.value, this.fontSize);
  final String label, value;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    fontSize: fontSize, color: AppColors.textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      );
}

Widget tableHead(String t, int flex, double size) => Expanded(
    flex: flex,
    child: Text(t,
        style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: Colors.white)));

Widget tableData(String t, int flex, double size, {bool bold = false}) => Expanded(
    flex: flex,
    child: Text(t,
        style: TextStyle(
            fontSize: size,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary)));

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final isStaged = status == 'Staged';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isStaged
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isStaged ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}
