import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text(
                    'EXPORT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
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
              ],
            ),
            SizedBox(height: gap),
            const DeliverySummaryCards(),
            SizedBox(height: gap),

            // Search & Filter Action Bar
            Row(
              children: [
                Expanded(
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
                        hintText:
                            'Search delivery #, project, material, description...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: Obx(
                          () => controller.searchQuery.value.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    controller.searchController.clear();
                                    controller.onSearch('');
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : const SizedBox.shrink(),
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
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
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
                // SORT: Latest Dropdown
                Obx(
                  () => Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SORT: ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedSort.value,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Latest',
                                child: Text('Latest'),
                              ),
                              DropdownMenuItem(
                                value: 'Oldest',
                                child: Text('Oldest'),
                              ),
                              DropdownMenuItem(
                                value: 'Delivery Date',
                                child: Text('Delivery Date'),
                              ),
                              DropdownMenuItem(
                                value: 'Quantity',
                                child: Text('Quantity'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) controller.setSort(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // FILTERS Button
                Obx(() {
                  final isOpen = controller.isAdvancedFiltersVisible.value;
                  final activeCount = controller.activeFiltersCount;
                  return InkWell(
                    onTap: () {
                      controller.isAdvancedFiltersVisible.value = !isOpen;
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isOpen || activeCount > 0
                            ? const Color(0xFFEFF6FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isOpen || activeCount > 0
                              ? AppColors.primaryBlue
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            size: 16,
                            color: isOpen || activeCount > 0
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FILTERS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isOpen || activeCount > 0
                                  ? AppColors.primaryBlue
                                  : AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (activeCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$activeCount',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            Obx(
              () => controller.isAdvancedFiltersVisible.value
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: gap),
                        _AdvancedFiltersPanel(controller: controller),
                      ],
                    )
                  : const SizedBox.shrink(),
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

class _AdvancedFiltersPanel extends StatelessWidget {
  const _AdvancedFiltersPanel({required this.controller});

  final DeliveryTrackingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: ADVANCED FILTERS and CLOSE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ADVANCED FILTERS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  controller.isAdvancedFiltersVisible.value = false;
                },
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'CLOSE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Responsive grid / rows
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 650;
              if (isWide) {
                return Column(
                  children: [
                    // Row 1: PROJECT, MATERIAL TYPE, SITE DESTINATION, TRANSPORTER
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProjectField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMaterialTypeField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDestinationField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTransporterField()),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Row 2: DRIVER / CONTACT, DELIVERY DATE FROM, DELIVERY DATE TO, CLEAR ALL
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDriverField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDateFromField(context)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDateToField(context)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildClearAllButton()),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProjectField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMaterialTypeField()),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDestinationField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTransporterField()),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDriverField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildClearAllButton()),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDateFromField(context)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDateToField(context)),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectField() {
    return Obx(() {
      final items = controller.availableProjects;
      final val = items.contains(controller.selectedProject.value)
          ? controller.selectedProject.value
          : 'All Projects';
      return _FilterColumn(
        label: 'PROJECT',
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: val,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              items: items
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newVal) {
                if (newVal != null) controller.setProject(newVal);
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMaterialTypeField() {
    return _FilterColumn(
      label: 'MATERIAL TYPE',
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller.materialTypeController,
          onChanged: controller.setMaterialType,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Steel, Roof Panels',
            hintStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            suffixIcon: Obx(
              () => controller.materialTypeQuery.value.isNotEmpty
                  ? InkWell(
                      onTap: () => controller.setMaterialType(''),
                      child: const Icon(
                        Icons.clear,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationField() {
    return Obx(() {
      final items = controller.availableDestinations;
      final val = items.contains(controller.selectedDestination.value)
          ? controller.selectedDestination.value
          : 'All Destinations';
      return _FilterColumn(
        label: 'SITE DESTINATION',
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: val,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              items: items
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(
                        d,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newVal) {
                if (newVal != null) controller.setDestination(newVal);
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTransporterField() {
    return Obx(() {
      final items = controller.availableTransporters;
      final val = items.contains(controller.selectedTransporter.value)
          ? controller.selectedTransporter.value
          : 'All Transporters';
      return _FilterColumn(
        label: 'TRANSPORTER',
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: val,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              items: items
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newVal) {
                if (newVal != null) controller.setTransporter(newVal);
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDriverField() {
    return Obx(() {
      final items = controller.availableDrivers;
      final val = items.contains(controller.selectedDriver.value)
          ? controller.selectedDriver.value
          : 'All Drivers';
      return _FilterColumn(
        label: 'DRIVER / CONTACT',
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: val,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              items: items
                  .map(
                    (dr) => DropdownMenuItem(
                      value: dr,
                      child: Text(
                        dr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newVal) {
                if (newVal != null) controller.setDriver(newVal);
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDateFromField(BuildContext context) {
    return Obx(() {
      final dt = controller.deliveryDateFrom.value;
      final text = dt != null
          ? DateFormat('dd/MM/yyyy').format(dt)
          : 'dd/mm/yyyy';
      return _FilterColumn(
        label: 'DELIVERY DATE FROM',
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dt ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (picked != null) {
              controller.setDeliveryDateFrom(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          dt != null ? FontWeight.w600 : FontWeight.w400,
                      color: dt != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (dt != null)
                  InkWell(
                    onTap: () => controller.setDeliveryDateFrom(null),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.clear,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDateToField(BuildContext context) {
    return Obx(() {
      final dt = controller.deliveryDateTo.value;
      final text = dt != null
          ? DateFormat('dd/MM/yyyy').format(dt)
          : 'dd/mm/yyyy';
      return _FilterColumn(
        label: 'DELIVERY DATE TO',
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dt ??
                  (controller.deliveryDateFrom.value ?? DateTime.now()),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (picked != null) {
              controller.setDeliveryDateTo(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          dt != null ? FontWeight.w600 : FontWeight.w400,
                      color: dt != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (dt != null)
                  InkWell(
                    onTap: () => controller.setDeliveryDateTo(null),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.clear,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildClearAllButton() {
    return _FilterColumn(
      label: ' ',
      child: InkWell(
        onTap: controller.clearAllFilters,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 6),
              Text(
                'CLEAR ALL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterColumn extends StatelessWidget {
  const _FilterColumn({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
