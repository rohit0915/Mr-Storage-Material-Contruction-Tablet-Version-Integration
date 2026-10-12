import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_toast.dart';
import '../controllers/dispatch_verification_controller.dart';
import '../models/dispatch_verification_models.dart';
import '../widgets/dispatch_verification_dialogs.dart';

class DispatchVerificationDetailView extends StatefulWidget {
  const DispatchVerificationDetailView({super.key, this.item});

  final DispatchItem? item;

  @override
  State<DispatchVerificationDetailView> createState() =>
      _DispatchVerificationDetailViewState();
}

class _DispatchVerificationDetailViewState
    extends State<DispatchVerificationDetailView> {
  late final DispatchVerificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<DispatchVerificationController>()
        ? Get.find<DispatchVerificationController>()
        : Get.put(DispatchVerificationController());

    final initialItem = widget.item ??
        (Get.arguments as DispatchItem?) ??
        controller.selectedItem.value;

    if (initialItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchLoadDetail(initialItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    void showSuccess(String title) =>
        DispatchVerificationSuccessDialog.show(context, title);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: (size.width * 0.7).clamp(800.0, 1200.0),
          maxHeight: size.height * 0.85,
        ),
        child: Obx(() {
          final currentItem = controller.selectedItem.value ??
              widget.item ??
              (Get.arguments as DispatchItem?);

          final bundles = currentItem?.bundleList ?? const [];
          final isVerified = currentItem?.status == DispatchStatus.verified ||
              (currentItem?.weightVerified == true &&
                  currentItem?.loadingVerified == true);
          final isBusy = controller.isActionLoading.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header padding
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: isBusy
                              ? null
                              : () async {
                                  if (!isVerified) {
                                    AppToast.showError(
                                      title: 'Verification Required',
                                      description:
                                          'First verify load, then confirm dispatch.',
                                    );
                                    return;
                                  }
                                  final loadId = currentItem?.mongoId.isNotEmpty == true
                                      ? currentItem!.mongoId
                                      : (currentItem?.loadId ?? '');
                                  if (loadId.isNotEmpty) {
                                    final success =
                                        await controller.confirmDispatch(
                                      loadId,
                                      packingListId: currentItem
                                                  ?.packingListMongoId
                                                  .isNotEmpty ==
                                              true
                                          ? currentItem?.packingListMongoId
                                          : currentItem?.packingListNo,
                                    );
                                    if (success) {
                                      showSuccess(
                                        'Dispatch Confirmed\nsuccessfully',
                                      );
                                    }
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
                                  final loadId = currentItem?.mongoId.isNotEmpty == true
                                      ? currentItem!.mongoId
                                      : (currentItem?.loadId ?? '');
                                  if (loadId.isNotEmpty) {
                                    final success =
                                        await controller.verifyDispatch(loadId);
                                    if (success) {
                                      showSuccess(
                                        'Load Marked Verified\nsuccessfully',
                                      );
                                    }
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
                    ),
                  ],
                ),
              ),
              // Body Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                _infoRow(
                                  'LOAD ID',
                                  currentItem?.displayLoadId.isNotEmpty == true
                                      ? currentItem!.displayLoadId
                                      : (currentItem?.loadId ?? '—'),
                                ),
                                _infoRow(
                                  'PACKING LIST NO',
                                  currentItem?.packingListNo ?? '—',
                                ),
                                _infoRow(
                                  'PROJECT',
                                  '${currentItem?.project ?? "—"} (${currentItem?.jobId ?? "—"})',
                                ),
                                _infoRow('TRUCK', currentItem?.truck ?? '—'),
                                _infoRow(
                                  'DESTINATION',
                                  currentItem?.destination ?? '—',
                                ),
                                _infoRow(
                                  'STATUS',
                                  currentItem?.statusText ?? '—',
                                ),
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
                                _infoRow(
                                  'PLANNED WEIGHT',
                                  currentItem?.totalWeight ?? '—',
                                ),
                                const SizedBox(height: 4),
                                _CheckRow(
                                  label: 'Weight verified',
                                  checked: isVerified,
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
                                _CheckRow(
                                  label: 'Loading Verified',
                                  checked: isVerified,
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
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E293B), // Slate dark header
                              border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1.5)),
                            ),
                            child: Row(
                              children: [
                                _thCell('#', 1),
                                _thCell('BUNDLE NO', 2),
                                _thCell('BUNDLE ID', 4),
                                _thCell('WEIGHT', 2),
                                _thCell('STATUS', 3),
                                _thCell('VERIFIED', 2, isLast: true),
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
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...bundles.map(
                              (b) => Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _tdCell(
                                      Text(
                                        '${b.index}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      1,
                                    ),
                                    _tdCell(
                                      Text(
                                        b.bundleNo,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      2,
                                    ),
                                    _tdCell(
                                      Text(
                                        b.bundleId,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      4,
                                    ),
                                    _tdCell(
                                      Text(
                                        b.weight,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      2,
                                    ),
                                    _tdCell(
                                      Text(
                                        b.status,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      3,
                                    ),
                                    _tdCell(
                                      Text(
                                        b.isVerified
                                            ? 'Verified'
                                            : 'Unverified',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: b.isVerified
                                              ? const Color(0xFF22C55E)
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      2,
                                      isLast: true,
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
          ],
        );
      }),
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

  static Widget _thCell(String text, int flex, {bool isLast = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  right: BorderSide(
                    color: Color(0xFF334155),
                    width: 1.0,
                  ),
                ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static Widget _tdCell(Widget child, int flex, {bool isLast = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  right: BorderSide(
                    color: AppColors.cardBorder,
                    width: 1.0,
                  ),
                ),
        ),
        child: child,
      ),
    );
  }
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
