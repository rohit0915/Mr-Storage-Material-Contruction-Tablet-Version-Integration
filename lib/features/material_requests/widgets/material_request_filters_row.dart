import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/material_requests_controller.dart';

class MaterialRequestFiltersRow extends StatefulWidget {
  const MaterialRequestFiltersRow({super.key});

  @override
  State<MaterialRequestFiltersRow> createState() =>
      _MaterialRequestFiltersRowState();
}

class _MaterialRequestFiltersRowState extends State<MaterialRequestFiltersRow> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  final MaterialRequestsController controller =
      Get.find<MaterialRequestsController>();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: controller.searchQuery.value,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      controller.setFilters(search: text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.008).clamp(8.0, 12.0);

    return Obx(() {
      final project = controller.selectedProject.value;
      final status = controller.selectedStatus.value;
      final priority = controller.selectedPriority.value;
      final dateRange = controller.dateRangeLabel;
      final hasDate = controller.hasDateFilter;
      final hasActive = controller.hasActiveFilters;
      final projectList = controller.projects.toList();
      final statusList = controller.statusList.toList();
      final priorityList = controller.priorityList.toList();

      // Sync search field if reset externally
      if (controller.searchQuery.value.isEmpty &&
          _searchController.text.isNotEmpty) {
        _searchController.clear();
      }

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SEARCH
                Expanded(
                  child: _SearchBox(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: () {
                      _debounce?.cancel();
                      _searchController.clear();
                      controller.setFilters(search: '');
                    },
                  ),
                ),
                SizedBox(width: gap),

                // 2. PROJECT
                Expanded(
                  child: _DropdownBox(
                    label: 'PROJECT',
                    value: project,
                    items: projectList,
                    onChanged: (v) => controller.setFilters(project: v),
                  ),
                ),
                SizedBox(width: gap),

                // 3. STATUS
                Expanded(
                  child: _DropdownBox(
                    label: 'STATUS',
                    value: status,
                    items: statusList,
                    onChanged: (v) => controller.setFilters(status: v),
                  ),
                ),
                SizedBox(width: gap),

                // 4. PRIORITY
                Expanded(
                  child: _DropdownBox(
                    label: 'PRIORITY',
                    value: priority,
                    items: priorityList,
                    onChanged: (v) => controller.setFilters(priority: v),
                  ),
                ),
                SizedBox(width: gap),

                // 5. DATE RANGE
                Expanded(
                  child: _DateRangeBox(
                    label: 'DATE RANGE',
                    value: dateRange,
                    hasDate: hasDate,
                    onTap: () => _showDateRangePickerDialog(context, controller),
                    onClear: () {
                      controller.clearDateRange();
                    },
                  ),
                ),
              ],
            ),

            if (hasActive) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    _debounce?.cancel();
                    _searchController.clear();
                    controller.resetFilters();
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Reset Filters',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SEARCH',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(
                Icons.search_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Request ID...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox(width: 8);
                  return InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final list = <String>[];
    for (final item in items) {
      if (!list.contains(item)) {
        list.add(item);
      }
    }
    final selectedVal = list.contains(value)
        ? value
        : (list.isNotEmpty ? list.first : value);
    if (!list.contains(selectedVal)) {
      list.insert(0, selectedVal);
    }

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
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          alignment: Alignment.center,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: ValueKey('$label-$selectedVal-${list.length}'),
              value: selectedVal,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
              dropdownColor: Colors.white,
              items: list
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DateRangeBox extends StatelessWidget {
  const _DateRangeBox({
    required this.label,
    required this.value,
    required this.hasDate,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String value;
  final bool hasDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
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
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasDate
                    ? AppColors.primaryBlue.withValues(alpha: 0.5)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: hasDate ? FontWeight.w700 : FontWeight.w600,
                      color: hasDate
                          ? AppColors.textPrimary
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                if (hasDate) ...[
                  InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showDateRangePickerDialog(
  BuildContext context,
  MaterialRequestsController controller,
) async {
  DateTime? startDate = controller.dateFrom.value;
  DateTime? endDate = controller.dateTo.value;

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
                        _presetChip(
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
                        _presetChip(
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
                        _presetChip(
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
                        _presetChip(
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
                          child: _datePickerField(
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
                          child: _datePickerField(
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
                            if (startDate != null && endDate != null) {
                              controller.setFilters(from: startDate, to: endDate);
                            } else if (startDate != null) {
                              controller.setFilters(from: startDate, to: startDate);
                            } else if (endDate != null) {
                              controller.setFilters(from: endDate, to: endDate);
                            } else {
                              controller.clearDateRange();
                            }
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

Widget _presetChip({
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

Widget _datePickerField({
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
              Expanded(
                child: Text(
                  valueText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                    color: hasValue
                        ? AppColors.textPrimary
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              if (hasValue) ...[
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
