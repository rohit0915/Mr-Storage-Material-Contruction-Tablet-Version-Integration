import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/delivery_tracking_controller.dart';
import '../widgets/delivery_card_list.dart';
import '../widgets/delivery_summary_cards.dart';

class DeliveryTrackingView extends GetView<DeliveryTrackingController> {
  const DeliveryTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    return AppScaffold(
      menuTitle: 'Delivery Tracking',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (Navigator.of(context).canPop()) ...[
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 12),
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
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.isProjectScoped &&
                                controller.scopedJobId.isNotEmpty
                            ? 'Delivery Tracking - ${controller.scopedJobId}'
                            : 'Delivery Tracking',
                        style: TextStyle(
                          fontSize: (size.width * 0.018).clamp(20.0, 26.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        controller.isProjectScoped
                            ? 'Deliveries routed for ${controller.scopedProject.isNotEmpty ? controller.scopedProject : controller.scopedJobId}'
                            : 'Read-only view of deliveries routed through plant/yard/warehouse',
                        style: TextStyle(
                          fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            const DeliverySummaryCards(),
            SizedBox(height: gap),

            // Search & Filter Action Bar
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearch,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search deliveries, drivers, vehicles...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
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
                const SizedBox(width: 10),
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All Statuses',
                            child: Text('All Statuses'),
                          ),
                          DropdownMenuItem(
                            value: 'IN TRANSIT',
                            child: Text('IN TRANSIT'),
                          ),
                          DropdownMenuItem(
                            value: 'STAGED',
                            child: Text('STAGED'),
                          ),
                          DropdownMenuItem(
                            value: 'READY',
                            child: Text('READY'),
                          ),
                          DropdownMenuItem(
                            value: 'DELIVERED',
                            child: Text('DELIVERED'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.setStatusFilter(val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
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
                const Spacer(),
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Last updated: Just now',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Project Scope Info & Fallback Banner
            if (controller.isProjectScoped)
              Obx(() {
                final hasProjectDels = controller.projectHasDeliveries;
                final isOnlyProj = controller.isFilterByProjectOnly.value;

              return Container(
                margin: EdgeInsets.only(bottom: gap),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: hasProjectDels
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasProjectDels
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasProjectDels
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      size: 18,
                      color: hasProjectDels
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hasProjectDels
                            ? 'Showing deliveries for ${controller.scopedJobId} (${controller.projectDeliveries.length} found)'
                            : 'Project ${controller.scopedJobId} has no specific deliveries in database. Showing all ${controller.deliveries.length} plant deliveries from API.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: hasProjectDels
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                    if (!hasProjectDels) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () =>
                            controller.toggleProjectFilter(!isOnlyProj),
                        icon: Icon(
                          isOnlyProj
                              ? Icons.visibility_rounded
                              : Icons.filter_alt_off_rounded,
                          size: 14,
                        ),
                        label: Text(
                          isOnlyProj
                              ? 'Show All Plant Deliveries (${controller.deliveries.length})'
                              : 'Filter ${controller.scopedJobId} (0)',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB45309),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(color: Color(0xFFFDE68A)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            // Read-Only Access Notice Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Read-Only Access',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'This is a read-only view for plant coordination. You can view deliveries routed through the plant/yard/warehouse but cannot modify delivery information.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: gap),

            // List of Delivery Cards
            const DeliveryCardList(),
          ],
        ),
      ),
    );
  }
}
