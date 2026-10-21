import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_toast.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../../bundle_scan/models/bundle_scan_models.dart';
import '../../bundle_scan/services/bundle_scan_service.dart';
import '../../bundle_scan/widgets/bundle_mismatch_dialog.dart';
import '../../bundle_scan/widgets/scanner_dialog.dart';
import '../controllers/dispatch_verification_controller.dart';
import '../models/dispatch_verification_models.dart';
import '../widgets/dispatch_verification_dialogs.dart';

class DispatchVerificationView extends GetView<DispatchVerificationController> {
  const DispatchVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      menuTitle: 'Dispatch Verification',
      body: Obx(() {
        final step = controller.currentStep.value;
        switch (step) {
          case 1:
            return _Step1ProjectListView(controller: controller);
          case 2:
            return _Step2PackingListView(controller: controller);
          case 3:
            return _Step3BundleListView(controller: controller);
          case 4:
            return _Step4BundleDetailView(controller: controller);
          default:
            return _Step1ProjectListView(controller: controller);
        }
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP HEADER ACTIONS (Reused across Steps 1, 2, 3)
// ─────────────────────────────────────────────────────────────────────────────

class _TopActionsRow extends StatelessWidget {
  const _TopActionsRow({
    required this.controller,
    required this.btnSize,
    required this.hPad,
    required this.vPad,
  });

  final DispatchVerificationController controller;
  final double btnSize;
  final double hPad;
  final double vPad;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Export Button
        OutlinedButton.icon(
          onPressed: () async {
            final path = await controller.exportExcel();
            if (path != null) {
              AppToast.showSuccess(
                title: 'Export Complete',
                description: 'Verifications exported successfully: $path',
              );
            } else {
              AppToast.showInfo(
                title: 'Export',
                description: 'Dispatch verifications exported.',
              );
            }
          },
          icon: const Icon(Icons.download_rounded, size: 14),
          label: Text(
            'Export',
            style: TextStyle(fontSize: btnSize, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.cardBorder),
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Scan QR Code
        ElevatedButton.icon(
          onPressed: () async {
            final scanned = await ScannerDialog.show(context);
            if (scanned != null && scanned.isNotEmpty) {
              final found = controller.findLoadById(scanned);
              if (found != null) {
                controller.selectLoad(found);
              } else {
                AppToast.showInfo(
                  title: 'Scanned QR',
                  description: 'Scanned: $scanned',
                );
              }
            }
          },
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
          label: Text(
            'Scan QR Code',
            style: TextStyle(fontSize: btnSize, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED), // Purple matching Figma
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Manual Entry
        ElevatedButton.icon(
          onPressed: () {
            DispatchLoadIdInputDialog.show(
              context,
              title: 'Manual Entry',
              actionButtonText: 'Search Load / Bundle',
              onSubmit: (val) {
                final found = controller.findLoadById(val);
                if (found != null) {
                  controller.selectLoad(found);
                } else {
                  AppToast.showInfo(
                    title: 'Manual Lookup',
                    description: 'Searched for: $val',
                  );
                }
              },
            );
          },
          icon: const Icon(Icons.keyboard_outlined, size: 16),
          label: Text(
            'Manual Entry',
            style: TextStyle(fontSize: btnSize, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1: PROJECT LIST (Image 1)
// ─────────────────────────────────────────────────────────────────────────────

class _Step1ProjectListView extends StatelessWidget {
  const _Step1ProjectListView({required this.controller});
  final DispatchVerificationController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);
    final btnSize = (size.width * 0.009).clamp(11.0, 13.0);
    final hPad = size.width * 0.012;
    final vPad = size.height * 0.010;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dispatch Verification',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.004),
                    Text(
                      'Verify bundles and truckload details before confirming dispatch from the plant.',
                      style: TextStyle(
                        fontSize: subSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _TopActionsRow(
                controller: controller,
                btnSize: btnSize,
                hPad: hPad,
                vPad: vPad,
              ),
            ],
          ),
          SizedBox(height: gap * 1.2),

          // Main Card Container with Project List Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header Row: "Project List" + Filters
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 820;

                      final searchBar = SizedBox(
                        width: isCompact ? 180 : (size.width * 0.18).clamp(180.0, 240.0),
                        height: 38,
                        child: TextField(
                          controller: controller.projectSearchController,
                          onChanged: controller.onProjectSearch,
                          style: TextStyle(
                            fontSize: subSize,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              fontSize: subSize,
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                          ),
                        ),
                      );

                      final allProjectsDropdown = Obx(() {
                        final projNames = [
                          'All Projects',
                          ...controller.projects
                              .map((p) => p.projectName)
                              .toSet(),
                        ];
                        return Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: projNames.contains(
                                    controller.selectedProjectFilter.value,
                                  )
                                  ? controller.selectedProjectFilter.value
                                  : 'All Projects',
                              icon: const Icon(
                                Icons.filter_list_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              style: TextStyle(
                                fontSize: subSize,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              items: projNames
                                  .map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.setProjectFilter(val);
                                }
                              },
                            ),
                          ),
                        );
                      });

                      final dateRangeButton = Obx(() {
                        final hasCustomDate = controller.projectDateFrom.value != null ||
                            controller.projectDateTo.value != null;
                        return InkWell(
                          onTap: () => _showDispatchDateRangePicker(context, controller),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: hasCustomDate
                                  ? AppColors.primaryBlue.withValues(alpha: 0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: hasCustomDate
                                    ? AppColors.primaryBlue
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 15,
                                  color: hasCustomDate
                                      ? AppColors.primaryBlue
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  controller.projectDateRange.value,
                                  style: TextStyle(
                                    fontSize: subSize,
                                    fontWeight: FontWeight.w600,
                                    color: hasCustomDate
                                        ? AppColors.primaryBlue
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                if (hasCustomDate) ...[
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      controller.setProjectDateRange(null, null);
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      });

                      if (isCompact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Project List',
                                  style: TextStyle(
                                    fontSize: (size.width * 0.013).clamp(16.0, 19.0),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Obx(() {
                                  final hasAnyFilter = controller.projectSearchQuery.value.isNotEmpty ||
                                      controller.selectedProjectFilter.value != 'All Projects' ||
                                      controller.projectDateFrom.value != null ||
                                      controller.projectDateTo.value != null;
                                  if (!hasAnyFilter) return const SizedBox.shrink();
                                  return InkWell(
                                    onTap: () {
                                      controller.projectSearchController.clear();
                                      controller.onProjectSearch('');
                                      controller.setProjectFilter('All Projects');
                                      controller.setProjectDateRange(null, null);
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF64748B)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Reset',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                searchBar,
                                allProjectsDropdown,
                                dateRangeButton,
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Text(
                            'Project List',
                            style: TextStyle(
                              fontSize: (size.width * 0.013).clamp(16.0, 19.0),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          searchBar,
                          const SizedBox(width: 10),
                          allProjectsDropdown,
                          const SizedBox(width: 10),
                          dateRangeButton,
                        ],
                      );
                    },
                  ),
                ),

                const Divider(height: 1, color: AppColors.cardBorder),

                // Table Rows
                Obx(() {
                  if (controller.isLoading.value) {
                    return const AppShimmerTable(rowCount: 6);
                  }
                  final projects = controller.pageProjects;
                  if (projects.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 42,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No projects found',
                              style: TextStyle(
                                fontSize: subSize,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final minTableWidth = constraints.maxWidth < 950.0
                          ? 950.0
                          : constraints.maxWidth;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: minTableWidth,
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                color: const Color(0xFFF8FAFC),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    _th('Project ID', flex: 3),
                                    _th('Project / Site Name', flex: 6),
                                    _th('Total Packing list', flex: 3),
                                    _th('Total Bundles', flex: 3),
                                    _th(
                                      'Actions',
                                      flex: 2,
                                      alignment: Alignment.center,
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: AppColors.cardBorder,
                              ),

                              // Rows
                              ...projects.asMap().entries.map((entry) {
                                final p = entry.value;
                                final isEven = entry.key % 2 == 0;
                                return Container(
                                  color: isEven
                                      ? Colors.white
                                      : const Color(0xFFFAFAFA),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Project ID
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          p.projectId,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),

                                      // Project / Site Name with Thumbnail
                                      Expanded(
                                        flex: 6,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFDBEAFE,
                                                  ),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.apartment_rounded,
                                                color: Color(0xFF2563EB),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.projectName,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    p.siteLocation,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Total Packing List
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${p.totalPackingList}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ),

                                      // Total Bundles
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${p.totalBundles}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ),

                                      // Actions [View]
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                controller.selectProject(p),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF7C3AED,
                                              ),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              minimumSize: Size.zero,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: const Text(
                                              'View',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                const Divider(height: 1, color: AppColors.cardBorder),

                // Footer Pagination
                _ProjectPaginationBar(controller: controller, fontSize: subSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(
    String label, {
    required int flex,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: PACKING LIST (Image 2)
// ─────────────────────────────────────────────────────────────────────────────

class _Step2PackingListView extends StatelessWidget {
  const _Step2PackingListView({required this.controller});
  final DispatchVerificationController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);
    final btnSize = (size.width * 0.009).clamp(11.0, 13.0);
    final hPad = size.width * 0.012;
    final vPad = size.height * 0.010;

    final projectName =
        controller.selectedProject.value?.projectName ??
        'Downtown Office Complex';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Back Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: controller.goBack,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Packing List - $projectName',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.004),
                    Text(
                      'Verify bundles and truckload details before confirming dispatch from the plant.',
                      style: TextStyle(
                        fontSize: subSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _TopActionsRow(
                controller: controller,
                btnSize: btnSize,
                hPad: hPad,
                vPad: vPad,
              ),
            ],
          ),
          SizedBox(height: gap),

          // 4 Stat Cards
          Obx(() {
            final card1 = _StatCard(
              label: 'Total Packing list',
              value: '${controller.step2TotalPackingList}',
              bgColor: const Color(0xFF7C3AED),
              icon: Icons.assignment_outlined,
            );
            final card2 = _StatCard(
              label: 'Loads Ready For Dispatch',
              value: '${controller.step2LoadsReady}',
              bgColor: const Color(0xFF16A34A),
              icon: Icons.check_circle_outline_rounded,
            );
            final card3 = _StatCard(
              label: 'Bundles Assigned',
              value: '${controller.step2BundlesAssigned}',
              bgColor: const Color(0xFFEAB308),
              icon: Icons.all_inbox_rounded,
            );
            final card4 = _StatCard(
              label: 'Loads Dispatch Today',
              value: '${controller.step2LoadsDispatched}',
              bgColor: const Color(0xFFEF4444),
              icon: Icons.local_shipping_outlined,
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 750) {
                  return Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 8),
                      Expanded(child: card2),
                      const SizedBox(width: 8),
                      Expanded(child: card3),
                      const SizedBox(width: 8),
                      Expanded(child: card4),
                    ],
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: card1),
                        const SizedBox(width: 8),
                        Expanded(child: card2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: card3),
                        const SizedBox(width: 8),
                        Expanded(child: card4),
                      ],
                    ),
                  ],
                );
              },
            );
          }),
          SizedBox(height: gap),

          // Search + Filter + Sort Row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearch,
                    style: TextStyle(
                      fontSize: subSize,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        fontSize: subSize,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.cardBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.cardBorder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedStatus.value,
                      icon: const Icon(
                        Icons.filter_list_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      style: TextStyle(
                        fontSize: subSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'All Statuses',
                          child: Text('All Statuses'),
                        ),
                        DropdownMenuItem(
                          value: 'verified',
                          child: Text('VERIFIED'),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('PENDING'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) controller.setStatusFilter(val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedSort.value,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      style: TextStyle(
                        fontSize: subSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Latest',
                          child: Text('Sort by : Latest'),
                        ),
                        DropdownMenuItem(
                          value: 'Oldest',
                          child: Text('Sort by : Oldest'),
                        ),
                        DropdownMenuItem(
                          value: 'Weight High to Low',
                          child: Text('Sort by : Weight High to Low'),
                        ),
                        DropdownMenuItem(
                          value: 'Weight Low to High',
                          child: Text('Sort by : Weight Low to High'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) controller.setSort(val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: gap),

          // Packing List Table
          Obx(() {
            if (controller.isLoading.value) {
              return const AppShimmerTable(rowCount: 6);
            }
            final items = controller.pageItems;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final minWidth = constraints.maxWidth < 1100.0
                      ? 1100.0
                      : constraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minWidth,
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            color: const Color(0xFFF8FAFC),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                _th('Packing List', flex: 3),
                                _th('Load', flex: 3),
                                _th('Truck', flex: 3),
                                _th('Bundles', flex: 2),
                                _th('Total Weight', flex: 3),
                                _th('Destination', flex: 4),
                                _th('Status', flex: 2, alignment: Alignment.center),
                                _th('Action', flex: 2, alignment: Alignment.center),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.cardBorder),

                          // Rows
                          ...items.asMap().entries.map((entry) {
                            final item = entry.value;
                            final isEven = entry.key % 2 == 0;
                            return Container(
                              color: isEven
                                  ? Colors.white
                                  : const Color(0xFFFAFAFA),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Packing List
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.packingListNo.isNotEmpty
                                          ? item.packingListNo
                                          : 'PKL-001',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                  // Load
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.displayLoadId,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  // Truck
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.truck,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  // Bundles
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.bundles}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  // Total Weight
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.totalWeight,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  // Destination
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      item.destination,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  // Status
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: _StatusBadge(status: item.status),
                                    ),
                                  ),
                                  // Action
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            controller.selectLoad(item),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF7C3AED,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          minimumSize: Size.zero,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 7,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        ),
                                        child: const Text(
                                          'View',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 8),
          _PaginationBar(controller: controller, fontSize: subSize),
        ],
      ),
    );
  }

  Widget _th(
    String label, {
    required int flex,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: BUNDLE LIST (Image 3)
// ─────────────────────────────────────────────────────────────────────────────

class _Step3BundleListView extends StatelessWidget {
  const _Step3BundleListView({required this.controller});
  final DispatchVerificationController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);
    final btnSize = (size.width * 0.009).clamp(11.0, 13.0);
    final hPad = size.width * 0.012;
    final vPad = size.height * 0.010;

    final projectName =
        controller.selectedProject.value?.projectName ??
        'Downtown Office Complex';
    final pkl =
        controller.selectedLoad.value?.packingListNo.isNotEmpty == true
            ? controller.selectedLoad.value!.packingListNo
            : 'PKL-001';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: controller.goBack,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bundle List - $projectName / $pkl',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.004),
                    Text(
                      'Verify bundles and truckload details before confirming dispatch from the plant.',
                      style: TextStyle(
                        fontSize: subSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _TopActionsRow(
                controller: controller,
                btnSize: btnSize,
                hPad: hPad,
                vPad: vPad,
              ),
            ],
          ),
          SizedBox(height: gap),

          // 3 Stat Cards
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Bundles Scanned',
                    value: '${controller.step3BundlesScanned}',
                    bgColor: const Color(0xFF0284C7),
                    icon: Icons.qr_code_2_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Bundles Remaining',
                    value: '${controller.step3BundlesRemaining}',
                    bgColor: const Color(0xFFF97316),
                    icon: Icons.hourglass_bottom_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Bundles Loaded',
                    value: '${controller.step3BundlesLoaded}',
                    bgColor: const Color(0xFF16A34A),
                    icon: Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap * 1.2),

          // Filter Row + Bundle scan History Title
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: controller.bundleSearchController,
                    onChanged: (val) => controller.bundleSearchQuery.value = val,
                    style: TextStyle(
                      fontSize: subSize,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search bundles...',
                      hintStyle: TextStyle(
                        fontSize: subSize,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.cardBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.cardBorder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedBundleStatus.value,
                      icon: const Icon(
                        Icons.filter_list_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      style: TextStyle(
                        fontSize: subSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Status - All Status',
                          child: Text('Status - All Status'),
                        ),
                        DropdownMenuItem(
                          value: 'ready',
                          child: Text('Ready'),
                        ),
                        DropdownMenuItem(
                          value: 'mismatch',
                          child: Text('Mismatch'),
                        ),
                        DropdownMenuItem(
                          value: 'staging',
                          child: Text('Staging'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedBundleStatus.value = val;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: gap),

          // Main Card Container with Bundle scan History
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Bundle scan History',
                    style: TextStyle(
                      fontSize: (size.width * 0.013).clamp(16.0, 19.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),

                Obx(() {
                  final bundles = controller.pageBundles;
                  if (bundles.isEmpty && controller.currentLoadBundles.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No bundles found for this load',
                          style: TextStyle(
                            fontSize: subSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final minWidth = constraints.maxWidth < 950.0
                          ? 950.0
                          : constraints.maxWidth;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: minWidth,
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                color: const Color(0xFFF8FAFC),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    _th('Bundle ID', flex: 3),
                                    _th('Parts', flex: 3),
                                    _th('Total Weight', flex: 3),
                                    _th('Time', flex: 3),
                                    _th(
                                      'Status',
                                      flex: 2,
                                      alignment: Alignment.center,
                                    ),
                                    _th(
                                      'Action',
                                      flex: 2,
                                      alignment: Alignment.center,
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: AppColors.cardBorder,
                              ),

                              // Rows
                              ...bundles.asMap().entries.map((entry) {
                                final b = entry.value;
                                final isEven = entry.key % 2 == 0;
                                final globalIdx = controller.bundlePageIndex.value * controller.bundlePageSize.value + entry.key;
                                return Container(
                                  color: isEven
                                      ? Colors.white
                                      : const Color(0xFFFAFAFA),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Bundle ID
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          (b.bundleId.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(b.bundleId))
                                              ? 'BND-${(globalIdx + 1).toString().padLeft(3, '0')}'
                                              : b.bundleId,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),
                                      // Parts
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          b.parts,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      // Total Weight
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          b.totalWeight,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      // Time
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          b.time,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      // Status Badge
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: _BundleStatusBadge(
                                            status: b.statusText,
                                          ),
                                        ),
                                      ),
                                      // Action [View]
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                controller.selectBundle(b),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF7C3AED,
                                              ),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              minimumSize: Size.zero,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 7,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: const Text(
                                              'View',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
                const Divider(height: 1, color: AppColors.cardBorder),
                _BundlePaginationBar(controller: controller, fontSize: subSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(
    String label, {
    required int flex,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: BUNDLE INFORMATION & VERIFICATION (Image 4)
// ─────────────────────────────────────────────────────────────────────────────

class _Step4BundleDetailView extends StatefulWidget {
  const _Step4BundleDetailView({required this.controller});
  final DispatchVerificationController controller;

  @override
  State<_Step4BundleDetailView> createState() => _Step4BundleDetailViewState();
}

class _Step4BundleDetailViewState extends State<_Step4BundleDetailView> {
  final BundleScanService _bundleService = BundleScanService();
  bool _isActionRunning = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);

    final item = widget.controller.selectedBundle.value;
    final load = widget.controller.selectedLoad.value;
    final project = widget.controller.selectedProject.value;

    final bundleId = item?.bundleId ?? 'BND-001';
    final projName = project?.projectName ?? (item?.project ?? 'Downtown Office Complex');
    final loadId = load?.displayLoadId ?? (item?.loadId ?? 'LOAD-101');
    final truck = load?.truck ?? (item?.truck ?? 'TRK-01 (Flatbed 48ft)');
    final destination = load?.destination ?? (item?.site ?? 'Site A - Austin, TX');
    final weight = item?.totalWeight ?? '18,500 LBS';
    final parts = item?.parts ?? 'STL-B12';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Back Button & Actions
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 1000;

              final backAndTitle = Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: widget.controller.goBack,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bundle Information & Verification',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: size.height * 0.004),
                        Text(
                          '$projName / $loadId / $bundleId',
                          style: TextStyle(
                            fontSize: subSize,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final actionButtons = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Download
                  OutlinedButton.icon(
                    onPressed: () {
                      AppToast.showSuccess(
                        title: 'Downloaded',
                        description: 'Bundle label downloaded.',
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 14),
                    label: const Text('Download', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),

                  // Reprint Label
                  OutlinedButton.icon(
                    onPressed: () {
                      AppToast.showInfo(
                        title: 'Print Label',
                        description: 'Printing label for $bundleId...',
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 14),
                    label: const Text('Reprint Label', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),

                  // Report Mismatch
                  OutlinedButton.icon(
                    onPressed: () {
                      if (item != null) {
                        BundleMismatchDialog.show(
                          context,
                          item: item,
                          onSubmit: (notes, mismatchItems) async {
                            AppToast.showSuccess(
                              title: 'Mismatch Reported',
                              description:
                                  'Mismatch report submitted to Plant manager.',
                            );
                          },
                        );
                      }
                    },
                    icon: const Icon(Icons.warning_amber_rounded, size: 14),
                    label: const Text(
                      'Report Mismatch',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      backgroundColor: const Color(0xFFFEF2F2),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                    ),
                  ),

                  // Verify Bundle
                  ElevatedButton.icon(
                    onPressed: _isActionRunning
                        ? null
                        : () async {
                            setState(() => _isActionRunning = true);
                            try {
                              await _bundleService.verifyBundle(bundleId);
                              AppToast.showSuccess(
                                title: 'Bundle Verified',
                                description: 'Bundle $bundleId marked as Verified ✓',
                              );
                            } finally {
                              if (mounted) setState(() => _isActionRunning = false);
                            }
                          },
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                    label: const Text('Verify Bundle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),

                  // Mark Loaded
                  ElevatedButton.icon(
                    onPressed: _isActionRunning
                        ? null
                        : () async {
                            setState(() => _isActionRunning = true);
                            try {
                              await _bundleService.markLoaded(bundleId);
                              AppToast.showSuccess(
                                title: 'Marked Loaded',
                                description: 'Bundle $bundleId is marked Loaded on truck.',
                              );
                            } finally {
                              if (mounted) setState(() => _isActionRunning = false);
                            }
                          },
                    icon: const Icon(Icons.local_shipping_outlined, size: 14),
                    label: const Text('Mark Loaded', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),

                  // Mark Staged
                  ElevatedButton.icon(
                    onPressed: _isActionRunning
                        ? null
                        : () async {
                            setState(() => _isActionRunning = true);
                            try {
                              await _bundleService.markStaged(bundleId);
                              AppToast.showSuccess(
                                title: 'Marked Staged',
                                description: 'Bundle $bundleId marked Staged in plant.',
                              );
                            } finally {
                              if (mounted) setState(() => _isActionRunning = false);
                            }
                          },
                    icon: const Icon(Icons.layers_outlined, size: 14),
                    label: const Text('Mark Staged', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    backAndTitle,
                    const SizedBox(height: 12),
                    actionButtons,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: backAndTitle),
                  const SizedBox(width: 16),
                  Flexible(child: actionButtons),
                ],
              );
            },
          ),
          SizedBox(height: gap * 1.2),

          // Two-column or Top/Bottom Layout matching Image 4
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: QR Code + Bundle Information
                    Expanded(
                      flex: 5,
                      child: _buildBundleInfoColumn(
                        bundleId: bundleId,
                        projName: projName,
                        loadId: loadId,
                        truck: truck,
                        destination: destination,
                        weight: weight,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Column: Load Context Panel & Driver Details
                    Expanded(
                      flex: 5,
                      child: _buildLoadContextColumn(
                        load: load,
                        item: item,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildBundleInfoColumn(
                    bundleId: bundleId,
                    projName: projName,
                    loadId: loadId,
                    truck: truck,
                    destination: destination,
                    weight: weight,
                  ),
                  const SizedBox(height: 14),
                  _buildLoadContextColumn(
                    load: load,
                    item: item,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: gap * 1.2),

          // Bundle Details / Sub-items Table matching Image 4
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Bundle Details',
                    style: TextStyle(
                      fontSize: (size.width * 0.013).clamp(16.0, 19.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),

                // Table Header
                Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _th('Bundle ID', flex: 3),
                      _th('Parts', flex: 3),
                      _th('Time', flex: 3),
                      _th('Weight', flex: 3),
                      _th('Status', flex: 2, alignment: Alignment.center),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),

                // Item Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          bundleId,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          parts,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 3,
                        child: Text(
                          '10:32 AM',
                          style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          weight,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Center(
                          child: _BundleStatusBadge(status: 'Ready'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String label, {required int flex, Alignment alignment = Alignment.centerLeft}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildBundleInfoColumn({
    required String bundleId,
    required String projName,
    required String loadId,
    required String truck,
    required String destination,
    required String weight,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Card top
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: QrImageView(
                    data: 'Bundle=$bundleId&Load=$loadId',
                    version: QrVersions.auto,
                    size: 130.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bundleId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Scan to verify bundle contents',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),

          // Key Value pairs
          _infoRow('Project', projName),
          _infoRow('Load', loadId),
          _infoRow('Truck', truck),
          _infoRow('Destination', destination),
          _infoRow('Quantity', '7'),
          _infoRow('Total Weight', weight),
          _infoRow('Length', '20 ft'),
        ],
      ),
    );
  }

  Widget _buildLoadContextColumn({
    required DispatchItem? load,
    required BundleScanItem? item,
  }) {
    final driver = load?.driver.isNotEmpty == true
        ? load!.driver
        : (item?.driver.isNotEmpty == true ? item!.driver : 'John Miller');
    final shipper = item?.shipper.isNotEmpty == true ? item!.shipper : 'SHP-1044';
    final totalProducts = item?.totalProducts.isNotEmpty == true ? item!.totalProducts : '4';
    final weight = load?.totalWeight.isNotEmpty == true ? load!.totalWeight : '37,700 LBS';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF7C3AED),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Load Context & Shipment',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),

          _infoRow('Shipper', shipper),
          _infoRow('Driver', driver),
          _infoRow('Total Products', totalProducts),
          _infoRow('Shipment Weight', weight),
          _infoRow('Staging Area', 'Bay 4 — South Plant'),
          _infoRow('Status', 'Ready for Loading', isHighlight: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
                color: isHighlight ? const Color(0xFF16A34A) : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGES & STAT CARDS
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: bgColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final DispatchStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      DispatchStatus.pending => (
        'Pending',
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
      ),
      DispatchStatus.verified => (
        'Verified',
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _BundleStatusBadge extends StatelessWidget {
  const _BundleStatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF475569);
    final s = status.toLowerCase();

    if (s.contains('ready') || s.contains('verified')) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF166534);
    } else if (s.contains('mismatch')) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
    } else if (s.contains('staging')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGINATION
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectPaginationBar extends StatelessWidget {
  const _ProjectPaginationBar({
    required this.controller,
    required this.fontSize,
  });

  final DispatchVerificationController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = controller.projectPageIndex.value;
      final pages = controller.totalProjectPages;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'Showing',
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.projectPageSize.value,
                  isDense: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  items: const [10, 15, 20, 25]
                      .map(
                        (val) => DropdownMenuItem(
                          value: val,
                          child: Text('$val'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) controller.setProjectPageSize(val);
                  },
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Results',
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _PageBtn(
              icon: Icons.chevron_left_rounded,
              enabled: page > 0,
              onTap: controller.prevProjectPage,
            ),
            const SizedBox(width: 4),
            ...List.generate(pages.clamp(0, 3), (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => controller.goToProjectPage(i),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == page
                          ? const Color(0xFF7C3AED)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: i == page
                          ? null
                          : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: i == page ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 4),
            _PageBtn(
              icon: Icons.chevron_right_rounded,
              enabled: page < pages - 1,
              onTap: controller.nextProjectPage,
            ),
          ],
        ),
      );
    });
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.controller, required this.fontSize});
  final DispatchVerificationController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = controller.pageIndex.value;
      final pages = controller.totalPages;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'Showing',
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.pageSize.value,
                  isDense: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  items: controller.pageSizeOptions
                      .map(
                        (val) => DropdownMenuItem(
                          value: val,
                          child: Text('$val'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) controller.setPageSize(val);
                  },
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Results',
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _PageBtn(
              icon: Icons.chevron_left_rounded,
              enabled: page > 0,
              onTap: controller.prevPage,
            ),
            const SizedBox(width: 4),
            ...List.generate(pages.clamp(0, 3), (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => controller.goToPage(i),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == page
                          ? const Color(0xFF7C3AED)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: i == page
                          ? null
                          : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: i == page ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 4),
            _PageBtn(
              icon: Icons.chevron_right_rounded,
              enabled: page < pages - 1,
              onTap: controller.nextPage,
            ),
          ],
        ),
      );
    });
  }
}

class _BundlePaginationBar extends StatelessWidget {
  const _BundlePaginationBar({required this.controller, required this.fontSize});
  final DispatchVerificationController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = controller.bundlePageIndex.value;
      final pages = controller.totalBundlePages;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'Showing',
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.bundlePageSize.value,
                  isDense: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  items: controller.bundlePageSizeOptions
                      .map(
                        (val) => DropdownMenuItem(
                          value: val,
                          child: Text('$val'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) controller.setBundlePageSize(val);
                  },
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Results',
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _PageBtn(
              icon: Icons.chevron_left_rounded,
              enabled: page > 0,
              onTap: controller.prevBundlePage,
            ),
            const SizedBox(width: 4),
            ...List.generate(pages.clamp(0, 5), (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => controller.goToBundlePage(i),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == page
                          ? const Color(0xFF7C3AED)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: i == page
                          ? null
                          : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: i == page ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 4),
            _PageBtn(
              icon: Icons.chevron_right_rounded,
              enabled: page < pages - 1,
              onTap: controller.nextBundlePage,
            ),
          ],
        ),
      );
    });
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Icon(
        icon,
        size: 18,
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
    ),
  );
}

Future<void> _showDispatchDateRangePicker(
  BuildContext context,
  DispatchVerificationController controller,
) async {
  DateTime? startDate = controller.projectDateFrom.value;
  DateTime? endDate = controller.projectDateTo.value;

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final fmt = DateFormat('dd/MM/yyyy');
          final hasSelection = startDate != null || endDate != null;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.date_range_rounded,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Filter by Date Range',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          splashRadius: 18,
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Presets
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _dispatchPresetChip(
                          label: 'All Dates',
                          onTap: () {
                            setState(() {
                              startDate = null;
                              endDate = null;
                            });
                          },
                        ),
                        _dispatchPresetChip(
                          label: 'Today',
                          onTap: () {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            setState(() {
                              startDate = today;
                              endDate = today;
                            });
                          },
                        ),
                        _dispatchPresetChip(
                          label: 'Last 7 Days',
                          onTap: () {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            setState(() {
                              endDate = today;
                              startDate = today.subtract(const Duration(days: 6));
                            });
                          },
                        ),
                        _dispatchPresetChip(
                          label: 'Last 30 Days',
                          onTap: () {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            setState(() {
                              endDate = today;
                              startDate = today.subtract(const Duration(days: 29));
                            });
                          },
                        ),
                        _dispatchPresetChip(
                          label: 'This Month',
                          onTap: () {
                            final now = DateTime.now();
                            setState(() {
                              startDate = DateTime(now.year, now.month, 1);
                              endDate = DateTime(now.year, now.month, now.day);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // From & To Date Pickers
                    Row(
                      children: [
                        Expanded(
                          child: _dispatchDatePickerField(
                            context: ctx,
                            label: 'FROM DATE',
                            valueText: startDate != null
                                ? fmt.format(startDate!)
                                : 'Select Date',
                            hasValue: startDate != null,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                                builder: (c, child) {
                                  return Theme(
                                    data: Theme.of(c).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primaryBlue,
                                        onPrimary: Colors.white,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  startDate = picked;
                                  if (endDate != null && endDate!.isBefore(picked)) {
                                    endDate = picked;
                                  }
                                });
                              }
                            },
                            onClear: () {
                              setState(() {
                                startDate = null;
                              });
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        Expanded(
                          child: _dispatchDatePickerField(
                            context: ctx,
                            label: 'TO DATE',
                            valueText: endDate != null
                                ? fmt.format(endDate!)
                                : 'Select Date',
                            hasValue: endDate != null,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: endDate ?? startDate ?? DateTime.now(),
                                firstDate: startDate ?? DateTime(2020),
                                lastDate: DateTime(2035),
                                builder: (c, child) {
                                  return Theme(
                                    data: Theme.of(c).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primaryBlue,
                                        onPrimary: Colors.white,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  endDate = picked;
                                });
                              }
                            },
                            onClear: () {
                              setState(() {
                                endDate = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        if (hasSelection)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                startDate = null;
                                endDate = null;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            controller.setProjectDateRange(startDate, endDate);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            'Apply Filter',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _dispatchPresetChip({
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    ),
  );
}

Widget _dispatchDatePickerField({
  required BuildContext context,
  required String label,
  required String valueText,
  required bool hasValue,
  required VoidCallback onTap,
  required VoidCallback onClear,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 5),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasValue
                  ? AppColors.primaryBlue.withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: hasValue
                    ? AppColors.primaryBlue
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                    color: hasValue
                        ? AppColors.textPrimary
                        : const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasValue)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.cancel_rounded,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
