import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/dispatch_verification_controller.dart';
import '../models/dispatch_verification_models.dart';
import '../widgets/dispatch_verification_dialogs.dart';

class DispatchVerificationDetailView extends StatelessWidget {
  const DispatchVerificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DispatchVerificationController>()
        ? Get.find<DispatchVerificationController>()
        : Get.put(DispatchVerificationController());

    final item =
        Get.arguments as DispatchItem? ?? controller.selectedItem.value;
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;

    void showSuccess(String title) =>
        DispatchVerificationSuccessDialog.show(context, title);

    final bundles = item?.bundleList ?? const [];

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
          padding: const EdgeInsets.all(24),
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
                  OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text(
                      'BACK',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    final isBusy = controller.isActionLoading.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: isBusy
                              ? null
                              : () async {
                                  final loadId = item?.loadId ?? '';
                                  if (loadId.isNotEmpty) {
                                    await controller.confirmDispatch(
                                      loadId,
                                      packingListId: item?.packingListNo,
                                    );
                                    showSuccess(
                                      'Dispatch Confirmed\nsuccessfully',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF7C3AED,
                            ), // Vibrant purple matching Web Panel
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'CONFIRM DISPATCH',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: isBusy
                              ? null
                              : () async {
                                  final loadId = item?.loadId ?? '';
                                  if (loadId.isNotEmpty) {
                                    await controller.verifyDispatch(loadId);
                                    showSuccess(
                                      'Load Marked Verified\nsuccessfully',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF4F46E5,
                            ), // Indigo blue matching Web Panel
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'VERIFY LOAD',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 28),

              // Load Information & Verification Section matching Image 2
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Load Information
                  Expanded(
                    flex: 5,
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
                        const SizedBox(height: 16),
                        _infoRow('LOAD ID', item?.loadId ?? '—'),
                        _infoRow('PACKING LIST NO', item?.packingListNo ?? '—'),
                        _infoRow(
                          'PROJECT',
                          '${item?.project ?? "—"} (${item?.jobId ?? "—"})',
                        ),
                        _infoRow('TRUCK', item?.truck ?? '—'),
                        _infoRow('DESTINATION', item?.destination ?? '—'),
                        _infoRow('STATUS', item?.statusText ?? '—'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),

                  // Right Column: Weight Verification & Loading Verification
                  Expanded(
                    flex: 5,
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
                        const SizedBox(height: 16),
                        _infoRow('PLANNED WEIGHT', item?.totalWeight ?? '—'),
                        const SizedBox(height: 4),
                        const _CheckRow(
                          label: 'Weight verified',
                          checked: true,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Loading Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _CheckRow(
                          label: 'Loading Verified',
                          checked: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Bundle Verification List Table matching Image 2
              const Text(
                'Bundle Verification List',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Dark Header matching Image 2
                    Container(
                      color: const Color(0xFF1E293B), // Slate dark header
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
                            flex: 2,
                            child: Text(
                              'BUNDLE NO',
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
                              'BUNDLE ID',
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
                          Expanded(
                            flex: 2,
                            child: Text(
                              'VERIFIED',
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
                    // Data Rows for this load
                    if (bundles.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No bundles assigned to this load.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...bundles.map(
                        (b) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
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
                                  '${b.index}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  b.bundleNo,
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
                                  b.bundleId,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  b.weight,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  b.status,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  b.isVerified ? 'Verified' : 'Unverified',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: b.isVerified
                                        ? const Color(0xFF22C55E)
                                        : AppColors.textSecondary,
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
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, this.checked = true});
  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: checked ? const Color(0xFFE2E8F0) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: checked
                ? const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
