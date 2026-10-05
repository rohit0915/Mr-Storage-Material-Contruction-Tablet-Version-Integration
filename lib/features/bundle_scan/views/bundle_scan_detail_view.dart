import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/bundle_scan_detail_controller.dart';
import '../models/bundle_scan_models.dart';

class BundleScanDetailView extends StatelessWidget {
  const BundleScanDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered and initialized
    final controller = Get.isRegistered<BundleScanDetailController>()
        ? Get.find<BundleScanDetailController>()
        : Get.put(BundleScanDetailController());

    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;

    return AppScaffold(
      menuTitle: 'Bundle Scan',
      body: Obx(() {
        final item = controller.item.value;
        final isVerified = controller.isVerified.value;
        final isActionLoading = controller.isActionLoading.value;
        final actionMsg = controller.actionMessage.value;

        final bundleId = item?.bundleId ?? 'B-001';
        final project =
            item?.project.isNotEmpty == true ? item!.project : 'Storage 0011';
        final loadId =
            item?.loadId.isNotEmpty == true ? item!.loadId : 'LOAD-001';
        final truck = item?.truck.isNotEmpty == true ? item!.truck : 'TRK-980';
        final destination =
            item?.site.isNotEmpty == true ? item!.site : 'Site A';
        final quantity =
            item?.quantity.isNotEmpty == true ? item!.quantity : '4';
        final weight = item?.totalWeight.isNotEmpty == true
            ? item!.totalWeight
            : '4,319.1 LBS';
        final length =
            item?.length.isNotEmpty == true ? item!.length : '20 ft';
        final shipper =
            item?.shipper.isNotEmpty == true ? item!.shipper : 'SHP-1044';
        final driver =
            item?.driver.isNotEmpty == true ? item!.driver : 'John Miler';
        final totalProducts = item?.totalProducts.isNotEmpty == true
            ? item!.totalProducts
            : '4';
        final parts =
            item?.parts.isNotEmpty == true ? item!.parts : 'P-101, P-102';

        final qrPayload = '{"id":"${item?.realMongoId ?? ''}","bundleId":"$bundleId","project":"$project"}';

        final subItems = controller.subItems.isNotEmpty
            ? controller.subItems
            : [
                BundleSubItem(
                  index: '1',
                  bundleId: bundleId,
                  parts: parts,
                  time: item?.time ?? '11:25 AM',
                  weight: weight,
                  status: controller.currentStatusText.value.isNotEmpty
                      ? controller.currentStatusText.value
                      : 'Staged',
                ),
              ];

        return SingleChildScrollView(
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
                // Action Progress Indicator banner if an API action is ongoing
                if (isActionLoading) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.primaryBlue),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            actionMsg.isNotEmpty
                                ? actionMsg
                                : 'Processing request...',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Tier 1: Modern Header Bar (Back button, Title, Status Badge, Quick Meta)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text(
                        'Back',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.cardBorder),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      height: 28,
                      width: 1,
                      color: AppColors.cardBorder,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Bundle $bundleId',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusBgColor(controller.currentStatusText.value),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _statusBorderColor(controller.currentStatusText.value),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isVerified
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_checked,
                                  size: 13,
                                  color: _statusTextColor(controller.currentStatusText.value),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  controller.currentStatusText.value.isNotEmpty
                                      ? controller.currentStatusText.value.toUpperCase()
                                      : 'STAGED',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _statusTextColor(controller.currentStatusText.value),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Project: $project  •  Load: $loadId',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tier 2: Dedicated Actions Toolbar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Actions:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ActionBtn(
                                label: 'Download',
                                icon: Icons.download_rounded,
                                backgroundColor: const Color(0xFF334155),
                                isLoading: isActionLoading,
                                onTap: isActionLoading
                                    ? null
                                    : () => controller.downloadBundle(),
                              ),
                              const SizedBox(width: 8),
                              _ActionBtn(
                                label: 'Reprint Label',
                                icon: Icons.print_rounded,
                                backgroundColor: const Color(0xFF2563EB),
                                isLoading: isActionLoading,
                                onTap: isActionLoading
                                    ? null
                                    : () => controller.reprintLabel(),
                              ),
                              const SizedBox(width: 8),
                              _ActionBtn(
                                label: 'Report Mismatch',
                                icon: Icons.warning_amber_rounded,
                                backgroundColor: const Color(0xFFDC2626),
                                isOutlined: true,
                                isLoading: isActionLoading,
                                onTap: isActionLoading
                                    ? null
                                    : () => _showReportMismatchDialog(
                                        context, controller),
                              ),
                              const SizedBox(width: 8),
                              _ActionBtn(
                                label: 'Verify Bundle',
                                icon: isVerified
                                    ? Icons.verified_rounded
                                    : Icons.check_circle_outline_rounded,
                                backgroundColor: const Color(0xFF059669),
                                isLoading: isActionLoading,
                                onTap: isActionLoading
                                    ? null
                                    : () => controller.verifyBundle(),
                              ),
                              const SizedBox(width: 8),
                              _ActionBtn(
                                label: 'Mark Loaded',
                                icon: Icons.local_shipping_outlined,
                                backgroundColor: const Color(0xFFD97706),
                                isLoading: isActionLoading,
                                onTap: isActionLoading
                                    ? null
                                    : () => controller.markLoaded(),
                              ),
                              const SizedBox(width: 8),
                              _ActionBtn(
                                label: 'Mark Staged',
                                icon: Icons.inventory_2_outlined,
                                backgroundColor: const Color(0xFF7C3AED),
                                isLoading: isActionLoading,
                                onTap: isActionLoading
                                    ? null
                                    : () => controller.markStaged(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          ('Bundle ID', bundleId),
                          ('Project', project),
                          ('Load ID', loadId),
                          ('Truck', truck),
                          ('Destination', destination),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _InfoSection(
                        title: 'Bundle Details',
                        rows: [
                          ('Quantity', quantity),
                          ('Weight', weight),
                          ('Length', length),
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
                    // Left QR Code Preview (Real dynamic QR code using qr_flutter)
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scanned QR Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: AppColors.cardBorder),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: QrImageView(
                                  data: qrPayload,
                                  version: QrVersions.auto,
                                  size: 110,
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.textPrimary,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'project=$project',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _QrDetailLine(
                                      label: 'Shipper :',
                                      value: 'shipper=$shipper',
                                    ),
                                    _QrDetailLine(
                                      label: 'Load :',
                                      value: 'load_id=$loadId',
                                    ),
                                    _QrDetailLine(
                                      label: 'Bundle :',
                                      value: 'bundle_id=$bundleId',
                                    ),
                                    _QrDetailLine(
                                      label: 'Parts :',
                                      value: 'parts=$parts',
                                    ),
                                    _QrDetailLine(
                                      label: 'Weight :',
                                      value: 'weight=$weight',
                                    ),
                                    _QrDetailLine(
                                      label: 'Length :',
                                      value: 'length=$length',
                                    ),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                isVerified
                                    ? 'Bundle verified & assigned to load'
                                    : 'Bundle assigned to load',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isVerified
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isVerified
                                      ? const Color(0xFF059669)
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                isVerified
                                    ? Icons.check_circle_rounded
                                    : Icons.check_rounded,
                                size: 18,
                                color: isVerified
                                    ? const Color(0xFF059669)
                                    : AppColors.textPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Load Context Panel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _ContextLine(label: 'Load ID', value: loadId),
                          _ContextLine(label: 'Truck', value: truck),
                          _ContextLine(label: 'Driver', value: driver),
                          _ContextLine(
                            label: 'Total Products',
                            value: totalProducts,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

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
                                'Bundle ID',
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
                                'Parts',
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
                                'Time',
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
                                'Weight',
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
                                'Status',
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
                      ...subItems.map(
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
                                  r.index,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  r.bundleId,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  r.parts,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  r.time,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  r.weight,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusBgColor(r.status),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      r.status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _statusTextColor(r.status),
                                      ),
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
        );
      }),
    );
  }

  static Color _statusBgColor(String status) {
    final s = status.toUpperCase();
    if (s.contains('LOAD')) return const Color(0xFFFEF3C7); // Amber 100
    if (s.contains('STAG')) return const Color(0xFFEDE9FE); // Purple 100
    if (s.contains('READY') || s.contains('VERIF')) {
      return const Color(0xFFD1FAE5); // Green 100
    }
    return const Color(0xFFF1F5F9); // Slate 100
  }

  static Color _statusTextColor(String status) {
    final s = status.toUpperCase();
    if (s.contains('LOAD')) return const Color(0xFFB45309); // Amber 700
    if (s.contains('STAG')) return const Color(0xFF6D28D9); // Purple 700
    if (s.contains('READY') || s.contains('VERIF')) {
      return const Color(0xFF047857); // Green 700
    }
    return const Color(0xFF475569); // Slate 700
  }

  static Color _statusBorderColor(String status) {
    final s = status.toUpperCase();
    if (s.contains('LOAD')) return const Color(0xFFFDE68A); // Amber 200
    if (s.contains('STAG')) return const Color(0xFFDDD6FE); // Purple 200
    if (s.contains('READY') || s.contains('VERIF')) {
      return const Color(0xFFA7F3D0); // Green 200
    }
    return const Color(0xFFE2E8F0); // Slate 200
  }

  void _showReportMismatchDialog(
    BuildContext context,
    BundleScanDetailController controller,
  ) {
    String selectedReason = 'Weight Mismatch';
    final notesController = TextEditingController();

    final reasons = [
      'Weight Mismatch',
      'Missing Parts',
      'Damaged Bundle',
      'Wrong Project / Job',
      'Label Illegible',
      'Other',
    ];

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Text(
                    'Report Mismatch for ${controller.item.value?.bundleId ?? "Bundle"}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discrepancy Reason',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedReason,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                      items: reasons
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedReason = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Notes & Observations',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'E.g. Weight differs by 45 lbs or parts count is incorrect...',
                        hintStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final notes = notesController.text.trim();
                    Navigator.of(ctx).pop();
                    controller.reportMismatch(selectedReason, notes);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: icon != null
            ? Icon(icon, size: 14, color: backgroundColor)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: backgroundColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: backgroundColor),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: icon != null
          ? Icon(icon, size: 14, color: Colors.white)
          : const SizedBox.shrink(),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...rows.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    r.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  r.$2,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
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
            width: 65,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
